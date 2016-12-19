# preliminaries #

# make sure this is a connection where the database user has access to pg_admin tables
connection: "YOUR_CONNECTION_HERE"

case_sensitive: no

include: "redshift_*dashboard"

include: "redshift_*view"

# views to explore—i.e., "base views" #

explore: redshift_data_loads {}

explore: redshift_db_space {
  label: "DB Space"
}

explore: redshift_etl_errors {
  label: "ETL Errors"
}

explore: redshift_tables {
  view_label: "[Redshift Tables]"
  join: redshift_plan_steps {
    sql_on: ${redshift_plan_steps.table}=${redshift_tables.table} ;;
    type: left_outer
    relationship: one_to_many
    fields:[count, total_rows, total_bytes]
  }
  join: redshift_queries {
    sql_on: ${redshift_queries.query} = ${redshift_plan_steps.query} ;;
    relationship: many_to_one
    type: left_outer
    fields: [count,total_time_executing,time_executing_per_query]
  }
  fields: [ALL_FIELDS*,-redshift_plan_steps.network_distribution_bytes]
}

explore: redshift_plan_steps {
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
      AND   ${inner_child.inner_outer} = 'inner';;
    type: left_outer
    relationship: one_to_one
    fields: [table,rows,bytes,total_rows,total_bytes]
  }
  join: outer_child {
    from: redshift_plan_steps
    view_label: "Redshift Plan Steps > Outer Child"
    sql_on: ${outer_child.query}=${redshift_plan_steps.query}
      AND   ${outer_child.parent_step} = ${redshift_plan_steps.step}
      AND   ${outer_child.inner_outer} = 'outer';;
    type: left_outer
    relationship: one_to_one
    fields: [table,rows,bytes,total_rows,total_bytes]
  }
}

explore: redshift_queries {}
