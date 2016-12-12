# view definitions #

view: pg_views {
  sql_table_name: pg_views ;;
  # dimensions #

  dimension: definition {
    type: string
    sql: ${TABLE}.definition ;;
  }

  dimension: schema {
    type: string
    sql: ${TABLE}.schemaname ;;
  }

  dimension: view {
    type: string
    sql: ${TABLE}.viewname ;;
  }
}

view: tables {
  derived_table: {
    # Insert into PDT because redshift won't allow joining certain system tables/views onto others (presumably because they are located only on the leader node)
    persist_for: "8 hours"
    sql: select *
      from svv_table_info
       ;;
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

  dimension: schema_table {
    sql: ${schema}||'.'||${table} ;;
    primary_key: yes
    hidden: yes
  }

  dimension: encoded {
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
  }

  dimension: sortkey {
    description: "First sort key"
    type: string
    sql: ${TABLE}.sortkey1 ;;
  }

  dimension: max_varchar {
    type: number
    sql: ${TABLE}.max_varchar ;;
  }

  dimension: sortkey_encoding {
    type: string
    sql: ${TABLE}.sortkey1_enc ;;
  }

  dimension: number_of_sortkeys {
    type: number
    sql: ${TABLE}.sortkey_num ;;
  }

  dimension: size {
    label: "Rows"
    type: number
    sql: ${TABLE}.size ;;
  }

  dimension: pct_used {
    type: number
    sql: ${TABLE}.pct_used ;;
  }

  dimension: empty {
    type: number
    sql: ${TABLE}.empty ;;
  }

  dimension: unsorted {
    type: number
    sql: ${TABLE}.unsorted ;;
  }

  dimension: stats_off {
    type: number
    sql: ${TABLE}.stats_off ;;
  }

  dimension: rows_in_table {
    type: number
    sql: ${TABLE}.tbl_rows ;;
  }

  dimension: skew_sortkey {
    type: number
    sql: ${TABLE}.skew_sortkey1 ;;
  }

  dimension: skew_rows {
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

view: db_space {
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

view: etl_errors {
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

view: data_loads {
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

view: recent_plan_steps {
  #Recent is last 1000 queries (but not in sync with other recent_ PDTs with the same condition)
  derived_table: {
    # Insert into PDT because redshift won't allow joining certain system tables/views onto others (presumably because they are located only on the leader node)
    persist_for: "2 hours"
    sql:
      SELECT
        query, 
        nodeid as step,
        parentid as parent_step,
        substring(regexp_substr(plannode, 'XN ([A-Z][a-z]+ ?)+'),3) as operation,
        substring(regexp_substr(plannode, 'DS_[A-Z_]+'),0) as network_distribution_type,
        substring(info from 1 for 240) as operation_argument,
        substring(regexp_substr(plannode,' on [\._a-zA-Z0-9]+'),5) as "table",
        ('0'||COALESCE(substring(regexp_substr(plannode,' rows=[0-9]+'),7),''))::bigint as "rows",
        ('0'||COALESCE(substring(regexp_substr(plannode,' width=[0-9]+'),8),''))::bigint as width,
        substring(regexp_substr(plannode,'\\(cost=[0-9]+'),7) as cost_lo,
        substring(regexp_substr(plannode,'\\.\\.[0-9]+'),3) as cost_hi,
        CASE 
          WHEN COALESCE(parentid,0)=0 THEN 'p' 
          WHEN nodeid=min(nodeid) OVER (PARTITION BY query,parentid) THEN 'i'
          ELSE 'o' END
        as inner_outer
      FROM stl_explain
      WHERE stl_explain.query>(SELECT max(query)-1000 FROM stl_explain)
      ;;
    distribution: "table"
  }
  dimension: query {
    sql: ${TABLE}.query ;;
    type: number
  }
  dimension: step {
    sql: ${TABLE}.nodeid ;;
    type: number
  }
  dimension: query_step {
    sql: ${query}||'.'||${step} ;;
    primary_key: yes
    hidden: yes
  }
  dimension: operation {
    label: "Operation"
    sql: ${TABLE}.operation ;;
    type: "string"
  }
  dimension: network_distribution_type {
    label: "Distribution style"
    sql: ${TABLE}.network_distribution_type ;;
    type: "string"
  }
  dimension: table {
    sql: ${TABLE}.tbl ;;
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
  measure: count {
    type: count
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
}
