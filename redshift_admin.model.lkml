# preliminaries #

# make sure this is a connection where the database user has access to pg_admin tables
connection: "YOUR_CONNECTION_HERE"

case_sensitive: no

include: "*dashboard"

include: "*view"

# views to explore—i.e., "base views" #

explore: data_loads {}

explore: db_space {
  label: "DB Space"
}

explore: etl_errors {
  label: "ETL Errors"
}

explore: table_skew {}

explore: view_definitions {
  from: pg_views
}
