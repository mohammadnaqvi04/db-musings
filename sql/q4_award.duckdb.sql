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
  t1 as ( --  the table of distinct players grouped by (ID, team, year)
    select distinct
      app.playerID,
      app.teamID,
      app.yearID
    from
      appearances as app
    group by
      app.playerID,
      app.teamID,
      app.yearID
  ),
  t2 as ( -- table of the distinct (player, team, year) tuples that won an award
    select distinct
      t1.playerID,
      t1.teamID,
      t1.yearID
    from
      t1
      join awardsplayers as ap on t1.playerID = ap.playerID
      and t1.yearID = ap.yearID
  ),
  t3 as ( -- table of distinct (team, year) tuples where > 5 players won an award
    select distinct
      t2.teamID,
      t2.yearID
    from
      t2
    group by
      t2.teamID,
      t2.yearID
    having
      count(t2.teamID) > 5
  ),
  t4 as ( -- table of distinct (manager, team, year) tuples where a manager won an award
    select distinct
      m.playerID,
      m.teamID,
      m.yearID
    from
      managers as m
      join awardsmanagers as am on m.playerID = am.playerID
      and m.yearID = am.yearID
  ),
  t5 as ( -- Table of (team, year) tuples where players and managers together satisfy event E
    select
      t3.teamID,
      t3.yearID as year
    from
      t3
      join t4 on t3.teamID = t4.teamID
      and t3.yearID = t4.yearID
  ),
  t6 as ( -- Table of (team, count(team)) tuples where E has occured more than once
    select
      t5.teamID,
      count(*) as c
    from
      t5
    group by
      t5.teamID
    having
      count(*) > 1
  ),
  t7 as ( -- the join fanout that's occuring here is because the `teams` table has a row for each year a team player, not a static list of teams
    select
      teams.lgID as league,
      teams.name as teamName,
      t6.c as count
    from
      t6
      join teams on t6.teamID = teams.teamID
  )
select
  *
from
  t7;

--   t8 as (
--     select
--       leagues.league as league,
--       t7.team,
--       t7.count
--     from
--       t7
--       join leagues on t7.league = leagues.lgID
--   )
-- select
--   t8.league || '|' || t8.team || '|' || t8.count
-- from
--   t8
-- order by
--   t8.count desc,
--   t8.team;
