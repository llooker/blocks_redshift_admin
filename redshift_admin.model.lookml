# preliminaries #

- connection: YOUR_CONNECTION_HERE # make sure this is a connection where the database user has access to pg_admin tables
- case_sensitive: false
- include: '*dashboard.lookml'
- include: '*view.lookml'


# views to explore—i.e., "base views" #

- explore: data_loads

- explore: db_space
  label: 'DB Space'

- explore: etl_errors
  label: 'ETL Errors'

- explore: table_skew

- explore: view_definitions
  from: pg_views
