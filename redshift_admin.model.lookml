# preliminaries #

- connection: [your_connection] # make sure this is a connection where the database user has access to pg_admin tables
- scoping: true
- case_sensitive: false


# views to explore—i.e., "base views" #

- explore: view_definitions
  from: pg_views


- explore: table_skew


- explore: db_space
  label: 'DB Space'


- explore: etl_errors
  label: 'ETL Errors'


- explore: data_loads
