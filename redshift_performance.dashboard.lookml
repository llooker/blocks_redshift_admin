- dashboard: redshift_performance
  title: Redshift Performance
  layout: tile
  tile_size: 50

  #filters:
  elements:
  - name: query_time_histogram
    height: 6
    width: 12
    title: "Query time histogram"
    type: looker_column
    model: meta
    explore: redshift_queries
    dimensions: [redshift_queries.time_executing_roundup5]
    measures: [redshift_queries.count]
    filters:
      redshift_queries.time_executing: not 0
    sorts: [redshift_queries.time_executing_roundup5]
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: log
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    show_null_points: true
    point_style: none
    interpolation: linear
    series_types: {}

  - name: longest_queries
    height: 6
    width: 20
    title: "Top 10 longest running queries"
    type: table
    model: meta
    explore: redshift_queries
    dimensions: [redshift_queries.query, redshift_queries.substring, redshift_queries.time_executing_roundup1]
    sorts: [redshift_queries.time_executing_roundup1 desc]
    limit: '10'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    series_labels:
      redshift_queries.time_executing_roundup1: Run time (seconds)
      redshift_queries.query: Query ID


  - name: recent_joins
    height: 6
    width: 20
    title: Recent Joins
    type: table
    model: meta
    explore: redshift_plan_steps
    dimensions: [redshift_plan_steps.operation_join_algorithm, redshift_plan_steps.network_distribution_type]
    measures: [redshift_plan_steps.count, inner_child.total_rows, inner_child.total_bytes]
    dynamic_fields:
    - table_calculation: avg_inner_bytes_join
      label: Avg Inner Bytes / Join
      expression: "${inner_child.total_bytes}/${redshift_plan_steps.count}"
      value_format:
      value_format_name: decimal_0
    filters:
      redshift_plan_steps.operation: "%Join%"
    sorts: [redshift_plan_steps.count desc]
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false

