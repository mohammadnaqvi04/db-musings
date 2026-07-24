-- Find ten people with the highest home-runs (HR) in any single appearance, irrespective of year or team.
-- Only consider people who have played at some point for a school in PA. Order the results from most to
-- least home runs, and then by first name alphabetically.
with
  t1 as (
    select
      playerID,
      MAX(HR) as homeruns
    from
      appearances
    where
      playerID IN (
        select
          playerID
        from
          collegeplaying
        where
          schoolID IN (
            select
              schoolID
            from
              schools
            where
              state = 'PA'
          )
      )
    group by
      playerID
  )
  -- query atp gives me the top 10 by HRs all time, I need to get rid of duplicates without using distinct
select
  nameFirst || ' (' || nameGiven || ') ' || nameLast || '|' || t1.homeruns
from
  people t2
  join t1 on t1.playerID = t2.playerId
order by
  t1.homeruns desc
limit
  10;

-- group by appearances.yearID, appearances.teamID;
-- figure out how to group by/only get the max of each player's career hr count
/* select nameFirst || ' (' || nameGiven || ') ' ||nameLast ||'|' || t1.homeruns from people t2
join t1 on t1.playerID = t2.playerId
order by t1.homeruns desc, t2.nameFirst limit 10; */
-- SELECT nameFirst AS first, nameGiven AS given, nameLast AS last FROM people WHERE first IN (SELECT nameFirst FROM people WHERE)
/* Select the top 10 HRs from appearances
where playerID in
collegeplaying where
schoolID in schools where
schoolID = PA

Take the HR's of those appearances and, against people, output the top 10
*/
