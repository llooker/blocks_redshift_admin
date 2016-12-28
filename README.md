

## Known Issues ##

- Sometimes, drilling into a table doesn't return any records. As far as we can tell, this is due to categorically wrong SQL result sets from Redshift for our where filters. See for example https://metanew.looker.com/sql/dnnpcjxwjjmkth. As a workaround, remove some filters, such as sortkey1_enc 
- Sometimes, the query execution table has 0 distribution bytes, despite the query plan and table distributions both suggesting that there was distribution activity. This zeroing out is present in each of SVL_QUERY_SUMMARY, SVL_QUERY_REPORT, and STL_DIST. Always check query execution metrics to ensure they're in the right ballpark before relying on them.
- "Rows out" according to the query plan are estimates. The are often highly inflated. If anything, this is an indication that you should update table statistics in Redshift so it can generate better query plans.
- Need to think about metrics for scans and (e.g. bytes, rows emitted, and emitted rows to table rows ratio). When a table has dist style='all', the measures are increased by a factor of the number of slices. This is unituitive since, for example the ratio is then typically >100, but this may be a good thing. (Aside: it seems like Redshift isn't restricting scans of dist-all tables based on the upstream join...)
