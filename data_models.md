- The issue with a flat file storage model is that querying over striaght files makes it unorthodox to verify the integrity of the data you're processing, implementing functions over that model, handling concurrent writers, and persisting it throug failure.
- Data model = describes the genre of DB (relational, graph, KV, Array). Schema = describes the layout of a DB (fields, their relations, constraints)
- Codd's relational model proposed that databases should separate the logical layer that developers write from the physical layer an engine actually executes. Developers should be able to write declarative statements of the result they want, leaving the imperative piece to the underlying engine which it can optimize on its own.
- Two flavors of data manipulation langauges: declarative and procedural/imperative
- Inner join: return records from both tables where there's a match
- Left join: return all records from left table + matching records from the right with NULL filling in missing values from the right table
- Right join: return all records from the right table while filling in NULL for missing data in the left record matches
- Full join: return all records from both sides, filling in missing values with NULL
- An observation with relational algebra—it allows you to describe a high-level ordering of how to execute a query.  This isn't exactly what the underlying engine should use though, performing a high-pruning filter and then joining with the resulting relation is much more performant than joining two tables expensively and then filtering after the fact.
- Relational algebra gives a high level procedural blueprint for describing a query, whereas SQL defines a declarative shape of what I want and the DB can figure out how to get it
- Two other popular model shapes worth calling out—document DBs and vector DBs

Definitions:
- Relation: essentially a database table where you define rows and the relations between attributes in the table
- Tuple: a single DB record/row that contains a set of attribute values
- N-ary relation: table with N columns
- Primary key: key in row that uniquely identifies it
- Foreign key: a key that acts as a mapper to the primary key of another relation.
- Constraint: a UDF that must hold for any and all rows of a table
