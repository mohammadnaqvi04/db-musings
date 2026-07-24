/*
Consider the event E: for a given (team, year), the team has more than 5 distinct
players win an award and some manager has won an award in the same year. For all
active leagues, find the teams where the event E has happened more than once. Order
the results by the number of event E occurrences from most to least, and then by
team name alphabetically.

Hints: You might find Correlated Subqueries and CTEs in DuckDB useful. Consider breaking the problem into sub-problems and combining their results.

Your output should look like this:

league|team_name|distinct_years

One of the rows in the output looks like the following:

National League|Atlanta Braves|3
*/
