
## Features ##

- Dashboards
	- [*Performance overview*](https://discourse.looker.com/t/optimizing-redshift-performance-with-lookers-redshift-block/4110) to see longest running queries, bad join patterns, red flags on table settings, and capacity metrics, and to drill into lists of related queries
	- *Query inspection* to get both-high level metrics about a particular query's resource usage, as well as query plan and step by step resources
	- [*Admin dashboard*](https://discourse.looker.com/t/analytic-block-redshift-admin/2079) to review ETL history and errors, tables, and capacity
- Explores
	- Tables
	- Queries for the past day
	- Query Plans for the past day
	- Execution metrics for the past day

## Implementation Instructions ##

The model is very self contained, with no references to other views/models, and all global object names prefixed with "redshift_". As a result, implementation should be straight-forward:

- Copy the view and dashboard files into your project
	- If your scratch schema is not called `looker_scratch`, search for `looker_scratch` within the view file and replace it with the name of your scratch schema 
- Copy the model file into your project and set the connection
	- Alternately, you can splice the model file contents into an existing model file that uses your redshift connection. Then search and replace your model name. Search for "redshift_model"
- The connection and its associated user in Redshift have an impact on the results of reports. Choose your connection based on your needs for the block:
	- (Recommended) With a standard connection
		- This will allow you to view all activity issued from that connection (so normally all Looker activity)
		- Grant the SELECT privilege on:
			- [STV_WLM_SERVICE_CLASS_CONFIG](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_WLM_SERVICE_CLASS_CONFIG.html)
			- [SVV_TABLE_INFO](http://docs.aws.amazon.com/redshift/latest/dg/r_SVV_TABLE_INFO.html)
			- [STV_TBL_PERM](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_TBL_PERM.html)
			- [STV_BLOCKLIST](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_BLOCKLIST.html)
			- [STL_LOAD_COMMITS](http://docs.aws.amazon.com/redshift/latest/dg/r_STL_LOAD_COMMITS.html)
	- With a separate superuser connection
		- This will allow you to view all activity on Redshift across users
		- Note that when creating a superuser connection, Looker users with (develop or sql_runner permissions AND with access to the model) or with manage_models would be able to run arbitrary queries through the super-user connection.
	- [Parameterized connections](https://discourse.looker.com/t/parameterizing-connections-with-user-attributes/3986) currently do not support PDTs, and will not work with the block.
- Optional: Unhide any explores that you want to be visible from your explore menu
- Optional: Adjust time of day that PDT's rebuild
- Warning: If you see errors in your project, doublecheck your other models to ensure they aren't indiscriminantly including all the dashboards/views in your project. If they are, modify their include statements to only include dashboards/views that make sense in those models. (You can leverage file prefixes for better model organization.)

## Great! Now what? ##

Check our [Looker Discourse article](https://discourse.looker.com/t/optimizing-redshift-performance-with-lookers-redshift-block/4110) for a guide on how to use the block to optimize your performance.

## Known Issues ##

- Sometimes, drilling into a list of queries doesn't return any records. As far as we can tell, this is due to categorically wrong result sets from Redshift for certain where filters. As a workaround, remove some filters, such as redshift_tables.sortkey1_enc 
- Sometimes, the query execution table has 0 distribution bytes, despite the query plan and table distributions both suggesting that there was distribution activity. This zeroing out is present in each of SVL_QUERY_SUMMARY, SVL_QUERY_REPORT, and STL_DIST. Always check query execution metrics to ensure they're in the right ballpark before relying on them.
- "Rows out" according to the query plan are estimates. The are often _highly_ inflated. If anything, this is an indication that you should update table statistics in Redshift so it can generate better query plans.
- Need to think about metrics for scans (e.g. bytes, rows emitted, and emitted rows to table rows ratio). When a table has dist style='all', the measures are increased by a factor of the number of slices. This is unintuitive since, for example the ratio is then typically >100%, but this may be a good thing.

[comment]: # (To see the issue with Redshift result sets returning incorrect filtering, check https://metanew.looker.com/sql/dnnpcjxwjjmkth )

#