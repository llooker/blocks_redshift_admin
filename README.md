
## Features ##

- Dashboards
	- *Performance overview* to see longest running queries, bad join patterns, red flags on table settings, and capacity metrics, and to drill into lists of related queries
	- *Query inspection* to get both-high level metrics about a particular query's resource usage, as well as query plan and step by step resources
	- *Admin dashboard* to review ETL history and errors, tables, and capacity
- Explores
	- Tables
	- Queries for the past day
	- Query Plans for the past day
	- Execution metrics for the past day

## Implementation Instructions ##

The model is very self contained, with no references to other views/models, and all global object names prefixed with "redshift_". As a result, implementation should be straight-forward:

- Copy the view and dashboard files into your project
- Either:
	- Copy the model file into your project and set the connection
	- Or, splice the model file contents (except connection) into an existing model file on your redshift connection
- Search and replace your model name. Search for "meta" (You can use regular expressions to limit to whole word matches with "\bmeta\b")
	- Dashboards elements will contain references to the model name
	- Links to dashboards will contain references to the model name (in particular, from the dimension redshift_queries.query)

## Known Issues ##

- Sometimes, drilling into a list of queries doesn't return any records. As far as we can tell, this is due to categorically wrong result sets from Redshift for certain where filters. As a workaround, remove some filters, such as redshift_tables.sortkey1_enc 
- Sometimes, the query execution table has 0 distribution bytes, despite the query plan and table distributions both suggesting that there was distribution activity. This zeroing out is present in each of SVL_QUERY_SUMMARY, SVL_QUERY_REPORT, and STL_DIST. Always check query execution metrics to ensure they're in the right ballpark before relying on them.
- "Rows out" according to the query plan are estimates. The are often _highly_ inflated. If anything, this is an indication that you should update table statistics in Redshift so it can generate better query plans.
- Need to think about metrics for scans (e.g. bytes, rows emitted, and emitted rows to table rows ratio). When a table has dist style='all', the measures are increased by a factor of the number of slices. This is unituitive since, for example the ratio is then typically >100%, but this may be a good thing. (Aside: it seems like Redshift isn't restricting scans of dist-all tables based on the upstream join...)

[comment]: # (To see the issue with Redshift result sets returning incorrect filtering, check https://metanew.looker.com/sql/dnnpcjxwjjmkth )