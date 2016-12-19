# view definitions #


view: redshift_tables {
  derived_table: {
    # Insert into PDT because redshift won't allow joining certain system tables/views onto others (presumably because they are located only on the leader node)
    persist_for: "8 hours"
    sql: select
        "database"::varchar,
        "schema"::varchar,
        "Table_id"::bigint,
        "table"::varchar,
        "encoded"::varchar,
        "diststyle"::varchar,
        "sortkey1"::varchar,
        "max_varchar"::bigint,
        "sortkey1_enc"::varchar,
        "sortkey_num"::int,
        "size"::bigint,
        "pct_used"::numeric,
        "unsorted"::numeric,
        "stats_off"::numeric,
        "tbl_rows"::bigint,
        "skew_sortkey1"::numeric,
        "skew_rows"::numeric
      from svv_table_info
    ;;
    # http://docs.aws.amazon.com/redshift/latest/dg/r_SVV_TABLE_INFO.html
    distribution: "table"
  }

  # dimensions #

  dimension: database {
    type: string
    sql: ${TABLE}.database ;;
  }

  dimension: schema {
    type: string
    sql: ${TABLE}.schema ;;
  }
  dimension: table_id {
    type: number
    sql: ${TABLE}.table_id ;;
  }
  dimension: table {
    type: string
    sql: ${TABLE}."table" ;;
  }
  dimension: id {
    sql: ${database}||'.'${schema}||'.'||${table} ;;
    primary_key: yes
    hidden: yes
  }
  dimension: encoded {
    description: "Whether any column has compression encoding defined"
    type: yesno
    sql: case ${TABLE}.encoded
        when 'Y'
        then true
        when 'N'
        then false
        else null
      end
       ;;
  }
  dimension: distribution_style {
    type: string
    sql: ${TABLE}.diststyle ;;
    html: 
    {% if value == 'EVEN' %}
      <span style="color: darkorange">{{ rendered_value }}</span>
    {% elsif value == 'ALL' or value == 'DS_DIST_NONE'%}
      <span style="color: dimgray">{{ rendered_value }}</span>
    {% else %}
      {{ rendered_value }}
    {% endif %}
    ;;
  }

  dimension: sortkey {
    description: "First sort key"
    type: string
    sql: ${TABLE}.sortkey1 ;;
  }

  dimension: max_varchar {
    description: "Size of the largest column that uses a VARCHAR data type"
    type: number
    sql: ${TABLE}.max_varchar ;;
  }

  dimension: sortkey_encoding {
    description: "Compression encoding of the first column in the sort key, if a sort key is defined"
    type: string
    sql: ${TABLE}.sortkey1_enc ;;
  }

  dimension: number_of_sortkeys {
    type: number
    sql: ${TABLE}.sortkey_num ;;
  }
  dimension: size {
    label: "Size"
    description: "Size of the table, in 1 MB data blocks"
    type: number
    sql: ${TABLE}.size ;;
  }
  dimension: pct_used {
    type: number
    description: "Percent of available space that is used by the table"
    sql: ${TABLE}.pct_used ;;
  }
  dimension: unsorted {
    description: "Percent of unsorted rows in the table"
    type: number
    sql: ${TABLE}.unsorted ;;
    html: 
      {% if value >= 50 %}
        <span style="color: darkred">{{ rendered_value }}</span>
      {% elsif value >= 10 %}
        <span style="color: darkorange">{{ rendered_value }}</span>
      {% elsif value < 10 %}
        <span style="color: green">{{ rendered_value }}</span>
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }
  dimension: stats_off {
    description: "Number that indicates how stale the table's statistics are; 0 is current, 100 is out of date"
    type: number
    sql: ${TABLE}.stats_off ;;
    html: 
      {% if value >= 50 %}
        <span style="color: darkred">{{ rendered_value }}</span>
      {% elsif value >= 10 %}
        <span style="color: darkorange">{{ rendered_value }}</span>
      {% elsif value < 10 %}
        <span style="color: green">{{ rendered_value }}</span>
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }
  dimension: rows_in_table {
    type: number
    sql: ${TABLE}.tbl_rows ;;
  }
  dimension: skew_sortkey {
    description: "Ratio of the size of the largest non-sort key column to the size of the first column of the sort key, if a sort key is defined. Use this value to evaluate the effectiveness of the sort key"
    type: number
    sql: ${TABLE}.skew_sortkey1 ;;
  }
  dimension: skew_rows {
    description: "Ratio of the number of rows in the slice with the most rows to the number of rows in the slice with the fewest rows"
    type: number
    sql: ${TABLE}.skew_rows ;;
    html: {% if value < 25 %}
      <div style="color:#B40404; background-color:#22CE7E; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% elsif value >= 25 and value < 50 %}
      <div style="color:#868A08; background-color:#95F047; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% elsif value >= 50 %}
      <div style="color:#868A08; background-color:#C64646; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% endif %}
      ;;
  }
  measure: count {
    type: count
  }
  measure: total_rows {
    type: "sum"
    sql: ${size};;
  }

}

view: redshift_db_space {
  derived_table: {
    sql: select name as table
        , trim(pgn.nspname) as schema
        , sum(b.mbytes) as megabytes
        , sum(a.rows) as rows
      from (select db_id
              , id
              , name
              , sum(rows) as rows
            from stv_tbl_perm a
            group by 1,2,3) as a
      join pg_class as pgc
      on pgc.oid = a.id
      join pg_namespace as pgn
      on pgn.oid = pgc.relnamespace
      join pg_database as pgdb
      on pgdb.oid = a.db_id
      join (select tbl
              , count(*) as mbytes
            from stv_blocklist
            group by 1) as b
      on a.id = b.tbl
      group by 1,2
       ;;
  }

  # dimensions #

  dimension: table {
    type: string
    sql: ${TABLE}.table ;;
  }

  dimension: schema {
    type: string
    sql: ${TABLE}.schema ;;
  }

  dimension: megabytes {
    type: number
    sql: ${TABLE}.megabytes ;;
  }

  dimension: rows {
    type: number
    sql: ${TABLE}.rows ;;
  }

  dimension: table_stem {
    sql: case
        when (${table} ~ '(lr|lc)\\$[a-zA-Z0-9]+_.*')
        then ltrim(regexp_substr(${table}, '_.*'), '_') || ' - Looker PDT'
        else ${table}
      end
       ;;
  }

  # measures #

  measure: total_megabytes {
    type: sum
    sql: ${megabytes} ;;
  }

  measure: total_rows {
    type: sum
    sql: ${rows} ;;
  }

  measure: total_tables {
    type: count_distinct
    sql: ${table} ;;
  }
}

view: redshift_etl_errors {
  derived_table: {
    sql: select starttime as error_time
        , filename as file_name
        , colname as column_name
        , type as column_data_type
        , position as error_position
        , raw_field_value as error_field_value
        , err_reason as error_reason
        , raw_line
      from stl_load_errors
       ;;
  }

  # dimensions #

  dimension_group: error {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.error_time ;;
  }

  dimension: file_name {
    type: string
    sql: ${TABLE}.file_name ;;
  }

  dimension: column_name {
    type: string
    sql: ${TABLE}.column_name ;;
  }

  dimension: column_data_type {
    type: string
    sql: ${TABLE}.column_data_type ;;
  }

  dimension: error_position {
    type: string
    sql: ${TABLE}.error_position ;;
  }

  dimension: error_field_value {
    type: string
    sql: ${TABLE}.error_field_value ;;
  }

  dimension: error_reason {
    type: string
    sql: ${TABLE}.error_reason ;;
  }

  dimension: raw_line {
    type: string
    sql: ${TABLE}.raw_line ;;
  }
}

view: redshift_data_loads {
  derived_table: {
    sql: select replace(regexp_substr(filename, '//[a-zA-Z0-9\-]+/'), '/', '') as root_bucket
        , replace(filename, split_part(filename, '/', regexp_count(filename, '/') + 1), '') as s3_path
        , regexp_replace(replace(filename, split_part(filename, '/', regexp_count(filename, '/') + 1), ''), '([\\d]{5,}|[\\d\-]{5,}/)', '') as s3_path_clean
        , split_part(filename, '/', regexp_count(filename, '/') + 1) as file_name
        , regexp_replace(split_part(filename, '/', regexp_count(filename, '/') + 1), '([\\d]{7,}|[\\d\-]{7,})', '') as file_stem
        , curtime as load_time
      from stl_load_commits
       ;;
  }

  # dimensions #

  dimension: root_bucket {
    type: string
    sql: ${TABLE}.root_bucket ;;
  }

  dimension: s3_path {
    type: string
    sql: ${TABLE}.s3_path ;;
  }

  dimension: s3_path_clean {
    type: string
    sql: ${TABLE}.s3_path_clean ;;
  }

  dimension: file_name {
    type: string
    sql: ${TABLE}.file_name ;;
  }

  dimension: file_stem {
    type: string
    sql: ${TABLE}.file_stem ;;
  }

  dimension_group: load {
    type: time
    timeframes: [raw, time, date]
    sql: ${TABLE}.load_time ;;
  }

  # measures #

  measure: most_recent_load {
    type: string
    sql: max(${load_raw}) ;;
  }

  measure: hours_since_last_load {
    type: number
    value_format_name: id
    sql: datediff('hour', ${most_recent_load}, getdate()) ;;
    html: {% if value < 24 %}
      <div style="color:#B40404; background-color:#22CE7E; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% elsif value >= 24 and value < 48 %}
      <div style="color:#868A08; background-color:#95F047; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% elsif value >= 48 %}
      <div style="color:#868A08; background-color:#C64646; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% endif %}
      ;;
  }
}

view: redshift_queries {
  #Recent is last "5000" queries (we only see queries related to our rs user_id, so actual number is smaller)
  #description: "Recent queries to Redshift"
  derived_table: {
    sql_trigger_value: SELECT FLOOR((EXTRACT(epoch from GETDATE()) - 60*60*22)/(60*60*24)) ;; #22h
    sql: SELECT
        wlm.query,
        q.substring,
        --wlm.service_class,
        sc.name as service_class,
        wlm.service_class_start_time as start_time,
        wlm.total_queue_time,
        wlm.total_exec_time,
        q.elapsed --Hmm.. this measure seems to be greater than queue_time+exec_time
      FROM STL_WLM_QUERY wlm
      LEFT JOIN STV_WLM_SERVICE_CLASS_CONFIG sc ON sc.service_class=wlm.service_class
      LEFT JOIN SVL_QLOG q on q.query=wlm.query
      WHERE wlm.query>=(SELECT MAX(query)-5000 FROM STL_WLM_QUERY)
    ;;
    #STL_QUERY could also be used instead of SVL_QLOG. It has more characters of query text (4000), but is only retained for "2 to 5 days"
    distribution: "query"
    sortkeys: ["start_time"]
  }
  dimension: query {
    type: number
    hidden: yes
    sql: ${TABLE}.query ;;
    primary_key: yes
  }
  dimension_group: start {
    type: time
    timeframes: [raw, minute15, hour, day_of_week, date]
    sql: ${TABLE}.start_time ;;
  }
  dimension: service_class {
    type: string
    sql: ${TABLE}.service_class ;;
  }
  dimension: time_in_queue {
    type: number
    description: "Amount of time that a query was queued before running, in seconds"
    sql: ${TABLE}.total_queue_time /1000000;;
  }
  dimension: time_executing {
    type: number
    description: "Amount of time that a query was executing, in seconds"
    sql: ${TABLE}.total_exec_time /1000000;;
  }
  dimension: time_overall {
    type: number
    description: "Amount of time that a query took (both queued and executing), in seconds"
    sql: ${time_in_queue} + ${time_executing}  ;;
  }
  dimension: time_elapsed {
    type: number
    description: "Amount of time (from another table, for comparison...)"
    sql: ${TABLE}.elapsed / 1000000 ;;
  }
  dimension: substring {
    type: string
    sql: ${TABLE}.substring ;;
  }
  dimension:  was_queued {
    type: yesno
    sql: ${TABLE}.total_queue_time > 0;;
  }
  measure: count {
    type: count
    sql: ${TABLE}.query ;;
    drill_fields: [query, start_date, time_executing, substring]
  }
  measure: count_of_queued {
    type: sum
    sql: ${was_queued}::int ;;
  }
  measure: percent_queued {
    type: number
    value_format: "0.## \%"
    sql: ${count_of_queued} / ${count} * 100 ;;
  }
  measure: total_time_in_queue {
    type: sum
    description: "Sum of time that queries were queued before running, in seconds"
    sql: ${time_in_queue};;
  }
  measure: total_time_executing {
    type: sum
    description: "Sum of time that queries were executing, in seconds"
    sql: ${time_executing};;
  }
  measure: total_time_overall {
    type: sum
    description: "Sum of time that queries took (both queued and executing), in seconds"
    sql: ${time_in_queue} + ${time_executing}  ;;
  }
  measure: total_time_elapsed {
    type: sum
    description: "Sum of time from another table, for comparison"
    sql: ${time_elapsed}  ;;
  }
  measure: time_executing_per_query {
    type: number
    sql: CASE WHEN ${count}<>0 THEN ${total_time_executing} / ${count} ELSE NULL END ;;
    value_format_name: decimal_1
  }
}

view: redshift_plan_steps {
  #Recent is last "1000" queries, based on (persiseted) recent_queries
  #description: "Steps from the query planner for recent queries to Redshift"
  derived_table: {
    # Insert into PDT because redshift won't allow joining certain system tables/views onto others (presumably because they are located only on the leader node)
    sql_trigger_value: SELECT FLOOR((EXTRACT(epoch from GETDATE()) - 60*60*23)/(60*60*24)) ;; #23h
    sql:
        SELECT
        query, nodeid, parentid,
        substring(regexp_substr(plannode, 'XN( [A-Z][a-z]+)+'),4) as operation,
        substring(regexp_substr(plannode, 'DS_[A-Z_]+'),0) as network_distribution_type,
        substring(info from 1 for 240) as operation_argument,
        substring(regexp_substr(plannode,' on [\._a-zA-Z0-9]+'),5) as "table",
        ('0'||COALESCE(substring(regexp_substr(plannode,' rows=[0-9]+'),7),''))::decimal(38,0) as "rows",
        ('0'||COALESCE(substring(regexp_substr(plannode,' width=[0-9]+'),8),''))::decimal(38,0) as width,
        substring(regexp_substr(plannode,'\\(cost=[0-9]+'),7) as cost_lo,
        substring(regexp_substr(plannode,'\\.\\.[0-9]+'),3) as cost_hi,
        CASE
          WHEN COALESCE(parentid,0)=0 THEN 'root'
          WHEN nodeid = MIN(nodeid) OVER (PARTITION BY query,parentid) THEN 'inner'
          ELSE 'outer'
        END::CHAR(5) as inner_outer
      FROM stl_explain
      WHERE query>=(SELECT min(query) FROM ${redshift_queries.SQL_TABLE_NAME})
        AND query<=(SELECT max(query) FROM ${redshift_queries.SQL_TABLE_NAME})
    ;;
    #TODO: Triple check inner/outer vs min/max nodeid pairing
    distribution: "table"
  }
  dimension: query {
    sql: ${TABLE}.query ;;
    type: number
    value_format_name: id
    drill_fields: [redshift_plan_steps.step]
  }
  dimension: step {
    sql: ${TABLE}.nodeid ;;
    type: number
    value_format_name: id
  }
  dimension: query_step {
    sql: ${query}||'.'||${step} ;;
    primary_key: yes
    hidden: yes
  }
  dimension: parent_step {
    type: number
    sql: ${TABLE}.parentid;;
    hidden: yes
  }
  dimension: operation {
    label: "Operation"
    sql: ${TABLE}.operation ;;
    type: "string"
    html:
      {% if value contains 'Nested' %}
        <span style="color: darkred">{{ rendered_value }}</span>
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }
  dimension: operation_join_algorithm {
    type: "string"
    sql: CASE WHEN ${operation} ILIKE '%Join%'
      THEN regexp_substr(${operation},'^[A-Za-z]+')
      ELSE 'Not a Join' END
    ;;
    html:
      {% if value == 'Nested' %}
      <span style="color: darkred">{{ rendered_value }}</span>
      {% else %}
      {{ rendered_value }}
      {% endif %}
    ;;
  }
  dimension: network_distribution_type {
    label: "Network Redistribution"
    description: "AWS Docs http://docs.aws.amazon.com/redshift/latest/dg/c_data_redistribution.html"
    sql: ${TABLE}.network_distribution_type ;;
    type: "string"
    html:
    {% if value == 'DS_DIST_ALL_INNER' or value == 'DS_BCAST_INNER' %}
      <span style="color: darkred">{{ rendered_value }}</span>
    {% elsif value == 'DS_DIST_BOTH' %}
      <span style="color: darkorange">{{ rendered_value }}</span>
    {% elsif value == 'DS_DIST_ALL_NONE' or value == 'DS_DIST_NONE'%}
      <span style="color: green">{{ rendered_value }}</span>
    {% else %}
      {{ rendered_value }}
    {% endif %}
    ;;
    #DS_DIST_OUTER is not even in the AWS Docs...?
  }
  dimension: network_distribution_bytes {
    #TODO: Multiply by number of nodes if BCAST?
    description: "Bytes from inner and outer children needing to be distributed or broadcast. (For broadcast, this value does not multiply by the number of nodes broadcast to.)"
    sql: CASE 
      WHEN ${network_distribution_type} ILIKE '%INNER%' THEN ${inner_child.bytes}
      WHEN ${network_distribution_type} ILIKE '%OUTER%' THEN ${outer_child.bytes}
      WHEN ${network_distribution_type} ILIKE '%BOTH%' THEN ${inner_child.bytes} + ${outer_child.bytes}
      ELSE 0
    END ;;
  }
  dimension: table {
    sql: ${TABLE}."table" ;;
    type: "string"
  }
  dimension: operation_argument {
    label: "Operation argument"
    sql: ${TABLE}.operation_argument ;;
    type: "string"
  }
  dimension: rows {
    label: "Rows out"
    sql: ${TABLE}.rows;;
    description: "Number of rows returned from this step"
    type: "number"
  }
  dimension: width {
    label: "Width out"
    sql: ${TABLE}.width;;
    description: "The estimated width of the average row, in bytes, that is returned from this step"
    type: "number"
  }
  dimension:bytes{
    label: "Bytes out"
    description: "Estimated bytes out from this step (rows * width)"
    sql: ${rows} * ${width} ;;
    type: "number"
  }
  dimension: inner_outer {
    label: "Child Inner/Outer"
    description: "If the step is a child of another step, whether it is the inner or outer child of the parent, e.g. for network redistribution in joins"
    type: "string"
    sql: ${TABLE}.inner_outer ;;
  }
  measure: count {
    type: count
    drill_fields: [query, parent_step, step, operation, operation_argument, network_distribution_type]
  }
  measure: total_rows{
    label: "Total rows out"
    type:  "sum"
    sql:  ${rows} ;;
    description: "Sum of rows returned across steps"
  }
  measure: total_bytes {
    label: "Total bytes out"
    type: "sum"
    sql:  ${bytes} ;;
  }
  
  measure: total_network_distribution_bytes {
    type: sum
    sql: ${network_distribution_bytes} ;;
  }

  set: steps_drill {
    fields: [
      redshift_plan_steps.query,
      redshift_plan_steps.parent_step,
      redshift_plan_steps.step,
      redshift_plan_steps.operation,
      redshift_plan_steps.operation_argument,
      redshift_plan_steps.network_distribution_type,
      redshift_plan_steps.rows,
      redshift_plan_steps.width,
      redshift_plan_steps.bytes
    ]
  }
}
