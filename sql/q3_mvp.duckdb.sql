/* Find ten (player, team) pairs where the player won the Gold Glove award in an active
-- league after 1999 and batted in more games than the player's team's average since 1999.
--
--
-- Order by the number of distinct award-winning years from most to least, and then by given name alphabetically.
--
--
-- Hints: Only consider awardID that matches Gold Glove. The team average can be computed by
-- taking the average over the batted games by each team player's appearances since 1999.
--  You might find Correlated Subqueries in DuckDB useful.
--
-- Your output should look like this:
-- nameGiven | teamID | distinct_years
--
-- tables involved: awardsplayers (for player->award), people, teams, appearances (for batted games)
*/
with
  t1 as (
    select
      playerID,
      awardID,
      yearID
    from
      awardsplayers as a1
    where
      (
        awardID = 'Gold Glove'
        and yearID > 1999
        -- checking if the playerID that qualifies to be returned is in the set of players who batted above their team's average
        and playerID IN (
          select
            playerID
          from
            appearances as a2
          where
            (
              -- this establishes that the playerID from the awardsPlayers that I'm
              -- selecting and the one from the appearances table is the same
              a1.playerID = a2.playerID
              -- This is how you compare the player's batting average against a single
              -- scalar value (collapsed from the avg aggregate func) representing
              -- their team's average
              and a2.G_batting > (
                select
                  avg(a3.G_batting)
                from
                  appearances as a3
                where
                  a2.teamID = a3.teamID
                  and a3.yearID > 1999
              )
            )
        )
      )
  )
select
  t2.nameGiven,
  t3.teamID
from
  people as t2
  join t1 on t2.playerID = t1.playerID
  join appearances t3 on t3.playerId = t1.playerID
