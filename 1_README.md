### What does this Block do for me?

**(1) ETL and Data Flow Management** - review ETL history, tables, and capacity, and set up alerts to trigger whenever errors occur in ETL or data movement processes.

**(2) Monitor Database Performance** - provides a comprehensive view of query performance across all queries and users to understand how quickly your database is performing, allowing users to see exactly which queries are causing delays (if any), and why.

**(3) Inspect Queries** - gain full detail around any particular query, from the time to return to the bytes scanned to the specific execution steps. This Block helps highlight those execution steps that are particularly slow moving and complex.

**(4) Understand User Behavior** - see which users or user groups are issuing the most or least performant queries, and help architect your schema and data pipeline to empower the users that need it most.



### Redshift System Tables Data Structure

* Redshift comes with System Tables, which provide metadata around database performance and operations. These tables come natively, with the same table structures, for each Redshift instance. More information on System Tables can be found in [AWS documentation](https://docs.aws.amazon.com/redshift/latest/dg/c_intro_system_tables.html).


### Block Structure

* **Redshift Views** - This Block consists of several derived tables based on the System Tables, which we've consolidated into one single view file.

* **Dashboards** - Due to the nature in which this data is displayed, this Block only exposes Dashboards as starting points for exploration, rather than using individual "Explore" pages. Start from a dashboard, then drill into any tile to start free-form exploration.


### Implementation Instructions / Customizations ##

* **Includes** - Notice that lines 6-7 in the model contain `includes` functions, which ensure that only Redshift views are contained in this model. Your views and dashboards should follow the same naming syntax as this Block (i.e. prefix of "redshift_"). Similarily, your other models shouldn't indiscriminantly including all the dashboards/views in your project. If they are, modify their include statements to only include dashboards/views that make sense in those models. (You can leverage file prefixes for better model organization.) This is important for this Block due to the permissions required to query the System Tables.

* **Optional Explores** - Unhide any explores that you want to be visible from your explore menu.

* **Connection and Permission** - The connection and its associated user in Redshift have an impact on the results of reports. Choose your connection based on your needs for the block:
  * **Standard** - (Recommended) With a standard connection
    - This will allow you to view all activity issued from that connection (so normally all Looker activity)
    - Grant the SELECT privilege on:
      - [STV_WLM_SERVICE_CLASS_CONFIG](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_WLM_SERVICE_CLASS_CONFIG.html)
      - [SVV_TABLE_INFO](http://docs.aws.amazon.com/redshift/latest/dg/r_SVV_TABLE_INFO.html)
      - [STV_TBL_PERM](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_TBL_PERM.html)
      - [STV_BLOCKLIST](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_BLOCKLIST.html)
      - [STL_LOAD_COMMITS](http://docs.aws.amazon.com/redshift/latest/dg/r_STL_LOAD_COMMITS.html)
  * **Superuser** - With a separate superuser connection
    - This will allow you to view all activity on Redshift across users
    - Note that when creating a superuser connection, Looker users with (develop or sql_runner permissions AND with access to the model) or with manage_models would be able to run arbitrary queries through the super-user connection.

  * **Parameterizing the Connection** - [Parameterized connections](https://discourse.looker.com/t/parameterizing-connections-with-user-attributes/3986) currently do not support PDTs, and will not work with the Block.


### How do I oiptimize the performance of my database?

Check our [Looker Discourse article](https://discourse.looker.com/t/optimizing-redshift-performance-with-lookers-redshift-block/4110) for an overview of common performance issues, and suggestions to resolve them.

### What if I find an error? Suggestions for improvements?

Great! Blocks were designed for continuous improvement through the help of the entire Looker community, and we'd love your input. To log an error or improvement recommentation, simply create a "New Issue" in the corresponding [Github repo for this Block](https://github.com/llooker/blocks_redshift_admin/issues). Please be as detailed as possible in your explanation, and we'll address it as quick as we can.


### Known Issues

- Sometimes, drilling into a list of queries doesn't return any records. As far as we can tell, this is due to categorically wrong result sets from Redshift for certain where filters. As a workaround, remove some filters, such as redshift_tables.sortkey1_enc
- Sometimes, the query execution table has 0 distribution bytes, despite the query plan and table distributions both suggesting that there was distribution activity. This zeroing out is present in each of SVL_QUERY_SUMMARY, SVL_QUERY_REPORT, and STL_DIST. Always check query execution metrics to ensure they're in the right ballpark before relying on them.
- "Rows out" according to the query plan are estimates. The are often _highly_ inflated. If anything, this is an indication that you should update table statistics in Redshift so it can generate better query plans.
- Need to think about metrics for scans (e.g. bytes, rows emitted, and emitted rows to table rows ratio). When a table has dist style='all', the measures are increased by a factor of the number of slices. This is unintuitive since, for example the ratio is then typically >100%, but this may be a good thing.
