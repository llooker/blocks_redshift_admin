# # Make sure this is a connection where the database user has sufficient permissions (per above link)

connection: "demonew_events_ecommerce"
case_sensitive: no

include: "redshift_*.dashboard"
include: "redshift_*.view"

explore: redshift_data_loads {
   hidden: yes
}

explore: redshift_db_space {
  hidden: yes
}

explore: redshift_etl_errors {
  hidden: yes
}

explore: redshift_tables {
  hidden: yes
  persist_for: "0 seconds"
  view_label: "[Redshift Tables]"
  join: redshift_query_execution {
    sql_on: ${redshift_query_execution.table_join_key}=${redshift_tables.table_join_key};;
    relationship: one_to_many
    type: left_outer
    fields: [
      any_restricted_scan,
      count_scans,
      percent_restricted_scan,
      total_bytes_scanned,
      total_rows_emitted,
      emitted_rows_to_table_rows_ratio
    ]
  }
  join: redshift_queries {
    sql_on: ${redshift_queries.query} = ${redshift_query_execution.query} ;;
    relationship: many_to_one
    type: left_outer
    fields: [query,start_date, time_executing, substring,count,total_time_executing,time_executing_per_query]
  }
}

explore: redshift_plan_steps {
  hidden: yes
  persist_for: "0 seconds"
  join: redshift_tables {
    sql_on: ${redshift_tables.table}=${redshift_plan_steps.table} ;;
    type: left_outer
    relationship: many_to_one
  }
  join: redshift_queries {
    sql_on: ${redshift_queries.query} = ${redshift_plan_steps.query} ;;
    relationship: many_to_one
    type: left_outer
  }
  join: inner_child {
    from: redshift_plan_steps
    view_label: "Redshift Plan Steps > Inner Child"
    sql_on: ${inner_child.query}=${redshift_plan_steps.query}
      AND   ${inner_child.parent_step} = ${redshift_plan_steps.step}
      AND   ${inner_child.inner_outer} = 'inner'
      AND   ${inner_child.parent_step} <> 0;;
    type: left_outer
    relationship: one_to_one
    fields: [table,rows,bytes,total_rows,total_bytes]
  }
  join: outer_child {
    from: redshift_plan_steps
    view_label: "Redshift Plan Steps > Outer Child"
    sql_on: ${outer_child.query}=${redshift_plan_steps.query}
      AND   ${outer_child.parent_step} = ${redshift_plan_steps.step}
      AND   ${outer_child.inner_outer} = 'outer'
      AND   ${outer_child.parent_step} <> 0;;
    type: left_outer
    relationship: one_to_one
    fields: [table,rows,bytes,total_rows,total_bytes]
  }
  join: next_1 {
    from: redshift_plan_steps
    view_label: "Redshift Plan Steps > Parent 1 Operation"
    sql_on: ${next_1.query}=${redshift_plan_steps.query}
      AND ${next_1.step}=${redshift_plan_steps.parent_step}
      AND ${redshift_plan_steps.parent_step}<>0;;
    type: left_outer
    relationship: one_to_one
    fields: [operation,operation_argument,rows]
  }
  join: next_2 {
    from: redshift_plan_steps
    view_label: "Redshift Plan Steps > Parent 2 Operation"
    sql_on: ${next_2.query}=${next_1.query}
      AND ${next_2.step}=${next_1.parent_step}
      AND ${next_1.parent_step}<>0;;
    type: left_outer
    relationship: one_to_one
    fields: [operation,operation_argument,rows]
  }
}

explore: redshift_queries {
  hidden: yes
  persist_for: "0 seconds"
}

explore: redshift_slices {
  hidden: yes
  persist_for: "0 seconds"
}

explore: redshift_query_execution {
  hidden: yes
  persist_for: "0 seconds"
  fields: [ALL_FIELDS*, -redshift_query_execution.emitted_rows_to_table_rows_ratio]
}
