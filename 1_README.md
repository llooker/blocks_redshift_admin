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

* **Where to deploy it**
    - **Separate Project** (Recommended) - Since this model has little to no need to share views with the primary model, keeping it as its own project makes for the most convenient isolation of concerns.
    - **Existing Project** - Make sure that other models do not contain include: "*.dashboard.lkml", as these will attempt to include the Redshift dashboards into existing models in which they do not make sense and will cause errors.

* **Connection and Permission**
    - Prerequisite: Ensure Looker is able to use its temp schema, according to our [Standard Redshift connection instructions](https://docs.looker.com/setup-and-management/database-config/amazon-redshift#temp_schema_setup)
    - [Grant](http://docs.aws.amazon.com/redshift/latest/dg/r_GRANT.html) the SELECT privilege on:
      - [STV_WLM_SERVICE_CLASS_CONFIG](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_WLM_SERVICE_CLASS_CONFIG.html)
      - [SVV_TABLE_INFO](http://docs.aws.amazon.com/redshift/latest/dg/r_SVV_TABLE_INFO.html)
      - [STV_TBL_PERM](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_TBL_PERM.html)
      - [STV_BLOCKLIST](http://docs.aws.amazon.com/redshift/latest/dg/r_STV_BLOCKLIST.html)
      - [STL_LOAD_COMMITS](http://docs.aws.amazon.com/redshift/latest/dg/r_STL_LOAD_COMMITS.html)
    - By default, grants to the above tables will **only allow the Redshift user to [view their own activity](https://docs.aws.amazon.com/redshift/latest/dg/c_visibility-of-data.html)**.
      Since Looker normally connects as a single Redshift user, this usually means all Looker activity, which is normally fine.
      If you want the reports to include data from other users you can execute these grants with [SYSLOG ACCESS](https://docs.aws.amazon.com/redshift/latest/dg/r_ALTER_USER.html#alter-user-syslog-access)

 * **[Optional] Adding Flame Graph Custom Visualization**
    - To better visualize the costs of the [query execution plan](https://docs.aws.amazon.com/redshift/latest/dg/c-the-query-plan.html), this block uses a custom visualization to display the hierarchy of steps. Here are the steps to add this visualization to your instance:
      1. Fork this repository
      2. Turn on [GitHub Pages](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/)
      3. Follow directions on Looker's documentation to add a [new custom visualisation manifest](https://docs.looker.com/admin-options/platform/visualizations#adding_a_new_custom_visualization_manifest):
          - Name the ID of the visualization as `flamegraph`. In the 'Main' field, the URI of the visualization will be `https://YOUR_DOMAIN_NAME/blocks_redshift_admin/flamegraph.js`
          - The required dependencies are:
            - [d3](https://d3js.org/d3.v4.min.js)
            - [d3-tip](https://cdnjs.cloudflare.com/ajax/libs/d3-tip/0.9.1/d3-tip.min.js)
            - [d3-flamegraph](https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.min.js)
    - Full details and examples of the Flame Graph visualization can be found in the Flame Graph for Looker [Github repo](https://github.com/davidtamaki/flamegraph).


 * **[Optional] Change daily PDT trigger** - The default PDT trigger (00:00 UTC) is not selected for any particular timezone, so you may want to offset it so that it does not trigger during your peak hours.

 * **[Optional] Unhide Explores** - Explores are hidden by default.


### How do I optimize the performance of my database?

Check our [Looker Discourse article](https://discourse.looker.com/t/optimizing-redshift-performance-with-lookers-redshift-block/4110) for an overview of common performance issues, and suggestions to resolve them.

### What if I find an error? Suggestions for improvements?

Great! Blocks were designed for continuous improvement through the help of the entire Looker community, and we'd love your input. To log an error or improvement recommentation, simply create a "New Issue" in the corresponding [Github repo for this Block](https://github.com/llooker/blocks_redshift_admin/issues). Please be as detailed as possible in your explanation, and we'll address it as quick as we can.


### Known Issues

- Sometimes, drilling into a list of queries doesn't return any records. As far as we can tell, this is due to categorically wrong result sets from Redshift for certain where filters. As a workaround, remove some filters, such as redshift_tables.sortkey1_enc
- Sometimes, the query execution table has 0 distribution bytes, despite the query plan and table distributions both suggesting that there was distribution activity. This zeroing out is present in each of SVL_QUERY_SUMMARY, SVL_QUERY_REPORT, and STL_DIST. Always check query execution metrics to ensure they're in the right ballpark before relying on them.
- "Rows out" according to the query plan are estimates. The are often _highly_ inflated. If anything, this is an indication that you should update table statistics in Redshift so it can generate better query plans.
- Need to think about metrics for scans (e.g. bytes, rows emitted, and emitted rows to table rows ratio). When a table has dist style='all', the measures are increased by a factor of the number of slices. This is unintuitive since, for example the ratio is then typically >100%, but this may be a good thing.
