/*
Consider the event E: for a given (team, year), the team has more than 5 distinct
players win an award and some manager has won an award in the same year.

For all active leagues, find the teams where the event E has happened more than once.

Order the results by the number of event E occurrences from most to least, and then by
team name alphabetically.

Hints: You might find Correlated Subqueries and CTEs in DuckDB useful. Consider
breaking the problem into sub-problems and combining their results.

Your output should look like this:

league|team_name|distinct_years

One of the rows in the output looks like the following:

National League|Atlanta Braves|3

1.
For the event E count of all teams, I need to filter out all teams where
E has occured less than than twice. Then order by event E count and team name.

-- Specifically for part E for players
I need to group players onto the teams they played on in a year.

I need to only keep distinct players that won an award on a (team, year) combination.

I need to count the number of players that won an award on that (team, year) combination.

I need to keep (team, year) combinations where the count of players that won an award is > 5.

-- Specifically for part E for manager
I need to track (manager, year) pairs who've won at least 1 award


2.
The grain of my final solution needs to be (league, team, count)

3.
To find players that played on a team in a year, I can use the appearances table (distinct by player ID, team, and year). I can then
group by those same attributes.  --> playerID, team, year (t1)

To keep only distinct players, I can add distinct as a keyword so as to not duplicate. Will I lose players who played on multiple teams? No, because the distinct keyword is on all three attributes. You'd lose players if you only made the playerID distinct.

To find the players that won an award on a specific (year, team), I'll join t1 against awardsplayers on player and year. This will keep only the (playerID, team, year) tuples representing players who won awards. (t2)

To find the # of players that won an award on a specific (year, team), I'll group by (team, year) from t2 which'll give me the players that won an award on a (team, year) combo and only keep the groups having count(player) > 5 (t3) --> teamID, yearID. This will effectively be event E, for players, for all (team, year) combos.

-- for managers
I'll join the managers table against awardsmanagers on distinct (playerID, teamID, yearID). This'll give me the distinct managers that won an award on a (team/year) combo. -> playerID, teamID, yearID (t4). I don't need to count anything for managers, since this is a T/F type check rather than an enumeration check.

I'll then join t3 and t4 on teamID and yearID, which'll give me all of the (team, year) combos where it's players won more than 5 awards and it's manager won an award. -> teamID, yearID (t5)

I'll then project count(team) and group by team and filter teams having count(team) > 1 (t6) -> (count(team), team) from t5

I'll then join t6 against teams to get the leagues, and will then project out (league, team, count(occurences))






---------------------------------------------

*/
with
  t1 as ( -- the table of distinct (player, team, league, year) tuples
    select distinct
      app.playerID,
      app.teamID,
      app.lgID,
      app.yearID
    from
      appearances as app
    where
      app.teamID not in (
        select distinct
          teamID
        from
          teams
        where
          teams.lgID in (
            select distinct
              lgID
            from
              leagues
            where
              active = 'N'
          )
      )
    group by
      app.playerID,
      app.teamID,
      app.lgID,
      app.yearID
  ),
  -- what if instead of player up above I just went down to (team, year) by reverse engineering the player back to his team at the time?
  ttemp as ( -- table of distinct (player, team, league, year) tuples
    select distinct
      ap.playerID,
      t1.teamID,
      t1.lgID,
      ap.yearID
    from
      awardsplayers ap
      join t1 on ap.playerID = t1.playerID
      and ap.yearID = t1.yearID
      and ap.lgID = t1.lgID
  ),
  tl as ( -- the distinct (player, team, league, year) tuples that won an award
    -- ATTENTION: Made this back into a table of (player, team, year) to account for a player who played for 2 teams in the same year
    -- Need to try the same granularity reduction now... Does contain BOS, BAL, CLE.
    select distinct
      ttemp.playerID,
      t1.teamID,
      t1.lgID,
      ttemp.yearID
    from
      ttemp
      join t1 on ttemp.playerID = t1.playerID
      and ttemp.teamID = t1.teamID
      and ttemp.lgID = t1.lgID
      and ttemp.yearID = t1.yearID
    order by
      t1.teamID,
      ttemp.yearID
  ),
  tt as ( -- the distinct (team, league, year) tuples representing an award winning team
    -- table of distinct (teamID, year) tuples where > 5 players won an award
    -- the goal here is to reduce the granularity of awardsplayers from 1 row per award to match t1's granularity—
    -- (1 row per distinct (team, year) tuple). I need granularity: 1 row per team, year combo
    -- This is supposed to be a granularity of (team, year, # of awards in this year for this team)
    --
    -- -- ATTENTION: not enough, might've switched to a different team on the same league. Does not contain BOS, BAL, CLE.
    select
      tl.teamID,
      tl.lgID,
      tl.yearID,
      count(*)
    from
      tl
    group by
      tl.teamID,
      tl.lgID,
      tl.yearID
    having
      count(*) > 5
    order by
      tl.teamID,
      tl.lgID,
      tl.yearID
  ),
  tr as ( -- the distinct (manager, team, league, year) tuples
    select
      m.playerID,
      m.teamID,
      m.lgID,
      m.yearID
    from
      managers m
    group by
      m.playerID,
      m.teamID,
      m.lgID,
      m.yearID
    order by
      m.playerID,
      m.teamID,
      m.lgID,
      m.yearID
  ),
  tq as ( -- the distinct (manager, team, league, year) tuples that won an award
    select distinct
      am.playerID,
      tr.teamID,
      tr.lgID,
      am.yearID
    from
      awardsmanagers am
      join tr on am.playerID = tr.playerID
      and am.lgID = tr.lgID
      and am.yearID = tr.yearID
    group by
      am.playerID,
      tr.teamID,
      tr.lgID,
      am.yearID
    order by
      tr.teamID,
      tr.lgID,
      am.yearID
  ),
  t4 as ( -- table of distinct (team, league, year) tuples where a manager won an award
    select distinct
      tq.teamID,
      tq.lgID,
      tq.yearID
    from
      tq
    where
      tq.teamID not in (
        select
          teamID
        from
          teams
        where
          teams.lgID in (
            select
              lgID
            from
              leagues
            where
              leagues.active = 'N'
          )
      )
    group by
      tq.teamID,
      tq.lgID,
      tq.yearID
    order by
      tq.teamID,
      tq.lgID,
      tq.yearID
  ),
  t5 as ( -- Table of (team, league, year) tuples where players and managers together satisfy event E
    select distinct
      tt.teamID,
      tt.lgID,
      tt.yearID
    from
      tt
      join t4 on tt.teamID = t4.teamID
      and tt.lgID = t4.lgID
      and tt.yearID = t4.yearID
    where
      tt.teamID not in (
        select
          teamID
        from
          teams
        where
          teams.lgID in (
            select
              lgID
            from
              leagues
            where
              leagues.active = 'N'
          )
      )
    order by
      tt.teamID,
      tt.lgID,
      tt.yearID
  ),
  -- BUG EXISTS BEFORE HERE (counting teams/years that shouldnt count)
  t6 as ( -- Table of (team, count(team)) tuples where E has occured more than once
    select
      t5.teamID,
      t5.lgID,
      count(*) as c
    from
      t5
    where
      t5.teamID not in (
        select
          teamID
        from
          teams
        where
          teams.lgID in (
            select
              lgID
            from
              leagues
            where
              leagues.active = 'N'
          )
      )
    group by
      t5.teamID,
      t5.lgID
    having
      count(*) > 1
    order by
      c desc,
      t5.teamID,
      t5.lgID
  ),
  t7 as ( -- Table of (teamID, name, year) tuples to map from teamID to name
    select distinct
      teamID,
      name
    from
      teams
    where
      teamID not in (
        select
          teamID
        from
          teams
        where
          teams.lgID in (
            select
              lgID
            from
              leagues
            where
              active = 'N'
          )
      )
  ),
  t8 as ( -- Table of (team_name, count(event E)) tuples
    select distinct
      t7.name,
      t6.c as count
    from
      t6
      join t7 on t6.teamID = t7.teamID
  ),
  t9 as ( -- Final output
    select distinct
      leagues.league as league_name,
      t8.name as team,
      t8.count
    from
      t8
      join teams on t8.name = teams.name
      join leagues on teams.lgID = leagues.lgID
  )
select
  *
from
  t6;

-- atlanta, chicago, bal, bos, cle, new york (minnesota and philly are wrongfully included.)
