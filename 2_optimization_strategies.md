### Optimization Guide

The first point of investigation or periodic review should typically be the performance dashboard <font color="#339">/dashboards/redshift_model::redshift_performance</font>

![image](https://user-images.githubusercontent.com/9888083/35290094-05510524-001e-11e8-8fc2-e88d9f43cd06.png)

By starting at the dashboard, you can focus your performance optimization efforts in areas where they will have the most impact:
<ul><li>Individual queries that are taking the most time</li><li>Suboptimal join patterns that, in aggregate, are taking the most time</li><li>Capacity limitations that would not be revealed at the per-query level</li></ul>
<table style="background-color:#EEE;margin-left:15%;margin-right:15%"><tbody><tr>
Note: All data relating to query history is limited to the past 1 day directly in the model. If desired, this can be adjusted in the redshift_queries view definition.
</tr></tbody></table>

<h3>Identifying opportunities from individual queries </h3>
The top section of the dashboard gives an overview of all queries run yesterday, with a histogram by run time, and a list of the top 10 longest running queries. You can drill into a list of queries by clicking on any bar in the histogram, and from either that list or the top 10 list, you can inspect queries you think might be problematic.
.

![image](https://user-images.githubusercontent.com/9888083/35290134-1f215bde-001e-11e8-9459-7b905280ba91.png)

<h3>Identifying opportunities from network activity patterns</h3>
The next section of the dashboard deals with the network activity caused by joins. Since network activity is highly impactful on execution time, and since it often follows consistent patterns, it is ripe for optimization, but most Redshift implementations neglect to properly analyze and optimize their network activity.

![image](https://user-images.githubusercontent.com/9888083/35290151-31938314-001e-11e8-971e-cb3283545e9b.png)

The pie chart on the left gives the approximate share of network activity for each type of network activity. Although there will always be some suboptimal redistribution of data for some share of queries in the system, when the red and yellow types account for more than 50% of the activity, there is a good indication that a different configuration would yield better system-wide average performance.

The list on the right then shows individual opportunities, with all queries performing a particular join pattern grouped into a row, and then sorted by aggregate time running among those queries, so that you can focus on adjusting join patterns that will have a significant impact on your end users.

Once you have identified a candidate join pattern for optimization based on this table, click the query count to see a drill-down of all the matching queries, and then select ones that appear representative or that are particularly slow to run to investigate further.

Note: Nested loops are another problem sometimes caused by joins. Not only will they always result in DB_BCAST_INNER, but they can also cause excessive CPU load and disk-based operations.


<h3>Identifying capacity issues</h3>
In addition to slowly running queries, you might be experiencing slow response time simply because Redshift is queueing queries as a result of excessive demand / insufficient capacity. The line graph at the bottom of the dashboard will quickly reveal if and during what time of the day queries were queued. The blue line represents all queries received each hour, and the red line represents queries queued each hour. You can also click on the &ldquo;minutes queued&rdquo; disabled series to get an estimate of how much, in aggregate, the queued queries were delayed by being in the queue.

![image](https://user-images.githubusercontent.com/9888083/35290181-42763a50-001e-11e8-8be8-e399182a81db.png)

If you do find an issue here, you can of course increase capacity - or, you could manage demand by adjusting or cleaning out your PDT build schedules and scheduled looks/dashboards.

PDTs: <font color="#339">/admin/pdts</font>

Scheduled content by hour: <font color="#339">/explore/i__looker/history?fields=history.created_hour,history.query_run_count&amp;f[history.source]=Scheduled+Task&amp;sorts=history.query_run_count+desc&amp;limit=50&amp;dynamic_fields=%5B%5D</font>

In addition to this capacity issue that directly affects query response time, you can also run into disk capacity issues. If your Redshift connection is a superuser connection, you can use the <a href="https://discourse.looker.com/t/analytic-block-redshift-admin/2079">admin elements</a> of the block to check this.

<h3 id="section-3">How to interpret diagnostic query information</h3>
When you click &ldquo;Inspect&rdquo; from any query ID, you&rsquo;ll be taken to the Query Inspection Dashboard:

![image](https://user-images.githubusercontent.com/9888083/35290206-565a700e-001e-11e8-89e1-66e33d318f9f.png)

The dashboard components can be interpreted as follows:

<ul>
<li><b>Seconds to run:</b> The number of seconds a query took to run, and a good starting point for deciding whether to spend time optimizing this query</li>
<li><b>Mb Scanned:</b> How many megabytes of data did the query scan from disk. This is commonly a significant contributing factor to query slowness. It&rsquo;s affected by things such as the underlying size of your dataset, whether a sort key could be leveraged to limit which blocks had to be read from disk, the average size of values in the referenced columns, the compression applied to your data on disk, whether a table is set to dist-style all.</li>
<li><b>Mb distributed, Mb broadcast:</b> Network activity is another very common cause for slow queries, and distributing and broadcasting are the two main categories of network activity caused by a query. They occur in order to allow separate points of data to be joined together, by sending the joined data to the same node. Distribution means that for each pair of datapoints to be joined together (e.g., a user and his/her order), Redshift chooses a location on the network for that pair and each node sends their datapoints to that new node for joining. On the otherhand, broadcasting occurs either when Redshift cannot determine ahead of time how datapoints will be matched up (e.g., the join predicate requires a nested loop instead of a hash join) or when Redshift estimates that one side of the relationship is small enough that broadcasting it will be less time costly than distributing both sides.</li>
<li><b>Rows sorted:</b> Less frequently, queries will trigger large sorts. Sorts on large numbers of records can be expensive, so a number greater than 100k here should be looked into. Of course, sometimes these sorts are required, but many times an extraneous order by is left in a derived table view, resulting in a large, unnecessary, and frequently executed sort.</li>
<li><b>Disk-based:</b> Indicates whether any step on any node resulted in an operation that exceeded the available memory and which caused the operation to be completed by storing some data on disk. If yes, see whether there is very high skew in the underlying data, or any step in the query execution section causing this, and if not consider whether additional capacity is needed based on trends across all queries in the system.</li>
<li><b>Query text:</b> Provides the first 4,000 characters of the query</li>
<li><b>Table details:</b> Shows the tables that participated in the query and some key information about those tables, and metrics about the scans of these tables during the execution of this query. Note that these table dimensions are current and may be different from what they were when the query ran.</li>
<li><b>Query Plan:</b> Shows the steps that the query planner produced. This is where the diagnostic heavy lifting gets done. When exploring from here, you can join the parent/child steps together, for example to see how many rows each side of a join contributed.</li>
<li><b>Query Execution:</b> At times, the query planner plans things that don&rsquo;t work out as expected. While the execution report is less structured and difficult to tie back to the query, it is a good way to check the assumptions made by the planner. For example, you can see how many rows or bytes were scanned, broadcast, or executed, and get a general sense for how the workload is balanced or skewed across nodes in the cluster.</li></ul>

<h3 id="section-4">Common problems and corrective actions</h3>

_Update: I presented on this at our JOIN 2017 conference, and you can find the presentation [here](https://discourse.looker.com/t/join-2017-deep-dive-redshift-optimization-with-lookers-redshift-block/5837)_

<table>
<thead>
  <tr>
    <th>Situation</th>
    <th>Possible Corrective Actions</th>
    <th>Considerations</th>
  </tr>
</thead>
<tbody>

<tr>
<td>A join pattern causes a nested loop that is unintentional or on large tables</td>
<td>Refactor the join into an equijoin (or an equijoin and a small fixed-size nested loop)</td>
<td></td>
</tr>
<tr>
  <td></td>
<td>Build a relationship table as a PDT so the nested loop only needs to be done once per ETL</td>
<td></td>
</tr>

<tr>
  <td>Overall join patterns result in frequent broadcasts of inner tables, or distribution of large outer tables, or distribution of both tables</td>
  <td>Adjust the dist style and distkey of the broadcast table, or of the receiving table based on overall join patterns in your system</td>
  <td></td>
</tr>
<tr>
  <td></td>
  <td>Add denormalized column(s) to your ETL to enable better dist keys. E.g., in events -&gt; users -&gt; accounts, you could add account_id to the events table</td>
  <td>Don&rsquo;t forget to add the account_id as an additional condition in the events -&gt; users join</td>
</tr>
<tr>
  <td></td>
  <td>Build a PDT to pre-join or redistribute the table</td>
  <td>Not usually needed, though this may be worth the higher disk usage, and can be more efficient than distribution style &ldquo;all&rdquo;</td>
</tr>
<tr>
  <td>Queries result in large amounts of scanned data</td>
  <td>Set your first sort key to the most frequently filtered on or joined on columns</td>
  <td></td>
</tr>
<tr>
  <td></td>
  <td>Check whether any distribution style &ldquo;all&rdquo; tables should be distributed instead (and possibly duplicated and re-distributed)</td>
  <td>With distribution style all, each node must scan the entire table, vs. just scanning its slice</td></tr>
<tr>
  <td></td>
  <td>Adjust <a href="http://docs.aws.amazon.com/redshift/latest/dg/tutorial-tuning-tables-compression.html">table compression</a></td>
  <td></td>
</tr>
<tr>
  <td></td>
  <td>Check for unsorted data in tables, and schedule <a href="http://docs.aws.amazon.com/redshift/latest/dg/tutorial-loading-data-vacuum.html">vacuums</a> or leverage <a href="http://docs.aws.amazon.com/redshift/latest/dg/vacuum-load-in-sort-key-order.html">sorted loading</a> for append-only datasets</td>
  <td></td>
</tr>
<tr>
  <td></td>
  <td>For large tables, set a <a href="https://looker.com/docs/reference/explore-params/always_filter">always_filter</a> declaration on your sort key to guide users </td>
  <td></td>
</tr>
<tr>
  <td>Queries have large steps with high skew, and/or disk-based operations</td>
  <td>Check table skew, skew of scan operations, and potentially adjust relevant distribution keys to better distribute the query processing</td>
  <td>For small queries, higher skew can be ok. </td>
</tr>
<tr>
  <td>The query planner incorrectly underestimates the resulting rows from a filter, leading to a broadcast of a large number of rows</td>
  <td>Check how off the statistics are for the relevant table, and schedule <a href="http://docs.aws.amazon.com/redshift/latest/dg/t_Analyzing_tables.html">analyzes</a></td>
  <td></td>
</tr>
<tr>
  <td></td>
  <td>Adjust your filter condition</td>
  <td></td>
</tr>
<tr>
  <td>Users frequently run full historical queries when recent data would do just as well</td>
  <td>Use <a href="https://looker.com/docs/reference/explore-params/always_filter">always_filter</a> so users are required to specify a filter value</td>
  <td>The filtered field is ideally the sort key for a significant table. E.g., the created date field in an event table</td>
</tr>
</tbody></table>

In case the above changes require changing content in your LookML model, you can use regex search within your project to find the relevant model code. For example `\${[a-zA-Z0-9_]+\.field_id}\s*=|=\s*${[a-zA-Z0-9_]+\.field_id}` would let you search for where a given field is involved in an equality/join, if you are using the same field name as the underlying database column name.
