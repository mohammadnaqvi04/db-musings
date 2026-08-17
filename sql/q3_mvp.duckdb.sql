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
  players_who_won_gold_glove_and_batted_abv_their_teams_avg as (
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
              -- This is how you compare the player's batting average against
              -- their team's average (collapsed into a scalar). You just do an
              -- aggregate which collapses a table into a single value
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
select distinct
  t2.nameGiven || '|' || t3.teamID || '|' || c
from
  -- This is to get the count of the # of years a player won Gold Glove, grouped by player.
  -- This is how you get around the issue of needing to include a SELECT attr in your GROUP BY when
  -- you have an aggregate in your SELECT
  -- https://stackoverflow.com/questions/19601948/must-appear-in-the-group-by-clause-or-be-used-in-an-aggregate-function
  (
    select
      players_who_won_gold_glove_and_batted_abv_their_teams_avg.playerID,
      count(
        players_who_won_gold_glove_and_batted_abv_their_teams_avg.yearID
      ) as c
    from
      players_who_won_gold_glove_and_batted_abv_their_teams_avg
    group by
      players_who_won_gold_glove_and_batted_abv_their_teams_avg.playerID
  ) tt
  join people t2 on tt.playerID = t2.playerID
  join players_who_won_gold_glove_and_batted_abv_their_teams_avg on t2.playerID = players_who_won_gold_glove_and_batted_abv_their_teams_avg.playerID
  -- players_who_won_gold_glove_and_batted_abv_their_teams_avg only gives me the players who won Gold Glove and the years they won it, but there's nothing in there
  -- that tells me the team they were on when they won it, which I need for the output
  --
  -- This necessitates the bottom join, which answers the q of "which team for this player, year combo".
  -- The issue in doing this without an additional where clause is it'll just give you the records
  -- from appearances irrespective of the (year, player) combo corresponding to the selection criteria.
  --
  -- It's not an unnecessary operation, you genuinely didn't have access to this in players_who_won_gold_glove_and_batted_abv_their_teams_avg and now you need to join
  -- in order to find it
  join appearances t3 on players_who_won_gold_glove_and_batted_abv_their_teams_avg.playerID = t3.playerID
where
  (
    players_who_won_gold_glove_and_batted_abv_their_teams_avg.yearID = t3.yearID
    and players_who_won_gold_glove_and_batted_abv_their_teams_avg.playerID = t3.playerID
  )
order by
  c desc,
  t2.nameGiven
limit
  10;

-- count(players_who_won_gold_glove_and_batted_abv_their_teams_avg.yearID) as c
