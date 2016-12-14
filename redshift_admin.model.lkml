# preliminaries #

# make sure this is a connection where the database user has access to pg_admin tables
connection: "YOUR_CONNECTION_HERE"

case_sensitive: no

include: "redshift_*dashboard"

include: "redshift_*view"

# views to explore—i.e., "base views" #

explore: data_loads {}

explore: db_space {
  label: "DB Space"
}

explore: etl_errors {
  label: "ETL Errors"
}

explore: tables {

  join: recent_plan_steps {
    sql_on: ${recent_plan_steps.table}=${tables.table} ;;
    type: left_outer
    relationship: one_to_many
  }
}

explore: recent_plan_steps {
  join: tables {
    sql_on: ${tables.table}=${recent_plan_steps.table} ;;
    type: left_outer
    relationship: many_to_one
  }
  join: recent_queries {
    sql_on: ${recent_queries.query} = ${recent_plan_steps.query} ;;
    relationship: many_to_one
    type: left_outer
  }
  join: inner_child {
    from: recent_plan_steps
    view_label: "Recent Plan Steps > Inner Child"
    sql_on: ${inner_child.query}=${recent_plan_steps.query}
      AND   ${inner_child.parent_step} = ${recent_plan_steps.step}
      AND   ${inner_child.inner_outer} = 'inner';;
    type: left_outer
    relationship: one_to_one
    fields: [table,rows,bytes,total_rows,total_bytes]                                               
  }
}

explore: view_definitions {
  from: pg_views
}
