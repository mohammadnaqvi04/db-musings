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
*/
/*

Rough sketch:

Going to need CTEs here. Tables involved —
awardsplayers correlated against a team, year combo.
awardsmanagers correlated against the same team, year combo.
leagues to find the active leagues.

Outer table will likely contain all the active leagues from leagues, then
the year column will correlate against awardsmanagers and awardsplayers

Deeper thinking:
---------------------------------------------

Break this into a few queries, then define the relations between them.

Firstly, I need a table that, given a team/year pair, can be used to
answer, as a boolean, did 5 distinct players from the team win an award
in this year.

Secondly, I need a table that, given a team/year pair, can be used to
answer, as a boolean, did a manager from the same team as ^ win an award
in the same year.

The above two consolidate an event, E. The combination of the above two will
generate a table roughly something like "Count of Instances this has happened, league, team_name"
which will act as my inner query/table.

The outer query will feed in league IDs that are active from `leagues`, which the
inner query will then match on against its own league_id and return three-tuple pairs.

---------------------------------------------

First I need a table of all awards won by everyone in a given year/league combo. There's no direct way to do that,
I need to list out all

*/
-- This gives the year, league pairs that are currently active
with
  active_leagues as (
    select distinct
      ap.yearID,
      ap.lgID
    from
      awardsplayers as ap
    where
      ap.lgID in (
        select
          l.lgId
        from
          leagues as l
        where
          l.active = 'Y'
      )
    group by
      ap.yearID,
      ap.lgID
  )
select
  *
from
  active_leagues;
