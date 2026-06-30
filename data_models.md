- The issue with a flat file storage model is that querying over striaght files makes it unorthodox to verify the integrity of the data you're processing, implementing functions over that model, handling concurrent writers, and persisting it throug failure.
- Data model = describes the genre of DB (relational, graph, KV, Array). Schema = describes the layout of a DB (fields, their relations, constraints)
- Codd's relational model proposed that databases should separate the logical layer that developers write from the physical layer an engine actually executes. Developers should be able to write declarative statements of the result they want, leaving the imperative piece to the underlying engine which it can optimize on its own.

Definitions:
-
