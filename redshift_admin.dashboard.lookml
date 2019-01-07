- dashboard: redshift_admin
  title: 'Redshift Admin'
  layout: tile
  tile_size: 100

  elements:

  - name: table_load_summary
    title: 'Table Load Summary'
    type: table
    model: redshift_model
    explore: redshift_data_loads
    dimensions: [redshift_data_loads.root_bucket, redshift_data_loads.s3_path_clean, redshift_data_loads.file_stem]
    measures: [redshift_data_loads.hours_since_last_load]
    sorts: [redshift_data_loads.root_bucket]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4
    limit: 500

  - name: recent_files_loaded
    title: 'Recent Files Loaded'
    type: table
    model: redshift_model
    explore: redshift_data_loads
    dimensions: [redshift_data_loads.file_name]
    measures: [redshift_data_loads.hours_since_last_load]
    filters:
      redshift_data_loads.load_date: 3 hours
    sorts: [redshift_data_loads.hours_since_last_load]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4
    limit: 500

  - name: recent_load_errors
    title: 'Recent Load Errors'
    type: table
    model: redshift_model
    explore: redshift_etl_errors
    dimensions: [redshift_etl_errors.error_date, redshift_etl_errors.file_name, redshift_etl_errors.column_name,
      redshift_etl_errors.column_data_type, redshift_etl_errors.error_reason]
    filters:
      redshift_etl_errors.error_date: 7 days
    sorts: [redshift_etl_errors.error_date desc]
    show_view_names: true
    width: 12
    height: 4
    limit: 500

  - name: database_consumption
    title: 'Database Consumption'
    type: table
    model: redshift_model
    explore: redshift_db_space
    dimensions: [redshift_db_space.schema, redshift_db_space.table_stem]
    measures: [redshift_db_space.total_rows, redshift_db_space.total_megabytes, redshift_db_space.total_tables]
    sorts: [redshift_db_space.total_megabytes desc]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4
    limit: 500