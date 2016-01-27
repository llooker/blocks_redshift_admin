- dashboard: redshift_admin
  title: 'Redshift Admin'
  layout: tile
  tile_size: 100

  elements:

  - name: table_load_summary
    title: 'Table Load Summary'
    type: table
    model: bigfdata
    explore: data_loads
    dimensions: [data_loads.root_bucket, data_loads.s3_path_clean, data_loads.file_stem]
    measures: [data_loads.hours_since_last_load]
    sorts: [data_loads.root_bucket]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4
    limit: 500

  - name: recent_files_loaded
    title: 'Recent Files Loaded'
    type: table
    model: bigfdata
    explore: data_loads
    dimensions: [data_loads.file_name]
    measures: [data_loads.hours_since_last_load]
    filters:
      data_loads.load_date: 3 hours
    sorts: [data_loads.hours_since_last_load]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4    
    limit: 500
    
  - name: recent_load_errors
    title: 'Recent Load Errors'
    type: table
    model: bigfdata
    explore: etl_errors
    dimensions: [etl_errors.error_date, etl_errors.file_name, etl_errors.column_name,
      etl_errors.column_data_type, etl_errors.error_reason]
    filters:
      etl_errors.error_date: 7 days
    sorts: [etl_errors.error_date desc]
    show_view_names: true
    width: 12
    height: 4    
    limit: 500
    
  - name: database_consumption
    title: 'Database Consumption'
    type: table
    model: bigfdata
    explore: db_space
    dimensions: [db_space.schema, db_space.table_stem]
    measures: [db_space.total_rows, db_space.total_megabytes, db_space.total_tables]
    sorts: [db_space.total_megabytes desc]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4    
    limit: 500

  - name: table_architecture
    title: 'Table Architecture (Distribution, Sort, and Skew)'
    type: table
    model: bigfdata
    explore: table_skew
    dimensions: [table_skew.schema, table_skew.table, table_skew.encoded, table_skew.rows_in_table,
      table_skew.size, table_skew.sortkey, table_skew.distribution_style, table_skew.skew_rows]
    filters:
      table_skew.skew_rows: NOT NULL
    sorts: [table_skew.skew_rows desc]
    show_view_names: true
    show_row_numbers: true
    width: 12
    height: 4    
    limit: 500

