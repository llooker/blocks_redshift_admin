- dashboard: redshift_performance
  title: Redshift Performance
  layout: grid
  rows:
    - elements: [query_time_histogram, longest_queries]
      height: 300
      
    - elements: [modeling_header]
      height: 100
    - elements: [network_distribution_piechart,network_distribution_top_joins]
      height: 300
      
    - elements: [capacity_header]
      height: 100
    - elements: [queries_and_queued_per_hour]
      height: 300
      

  #filters:
  elements:
  - name: query_time_histogram
    title: "Query time histogram"
    type: looker_column
    model: redshift_model
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
    title: "Top 10 longest running queries"
    type: table
    model: redshift_model
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



  - name: modeling_header
    type: text
    title_text: "Modeling"
    subtitle_text: ""
    body_text: ""
    
  - name: network_distribution_piechart
    title: Network distribution breakdown
    type: looker_pie
    model: redshift_model
    explore: redshift_plan_steps
    dimensions: [redshift_plan_steps.network_distribution_type]
    measures: [redshift_queries.total_time_executing]
    filters:
      redshift_plan_steps.operation: "%Join%"
    sorts: [redshift_queries.total_time_executing desc]
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    value_labels: labels
    label_type: labPer
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    series_types: {}
    series_colors:
      DS_BCAST_INNER: "#d3271d"
      DS_DIST_BOTH: "#fa6600"
      DS_DIST_INNER: "#82c400"
      DS_DIST_NONE: "#276300"
      DS_DIST_ALL_INNER: "#5f00cf"
      DS_DIST_ALL_NONE: "#1c8b19"
    
  - name: network_distribution_top_joins
    title: Top Network Distribution Operations
    type: table
    model: redshift_model
    explore: redshift_plan_steps
    dimensions: [redshift_plan_steps.network_distribution_type, redshift_plan_steps.operation_argument]
    measures: [redshift_queries.count, redshift_queries.total_time_executing, redshift_queries.time_executing_per_query]
    filters:
      redshift_plan_steps.network_distribution_type: DS^_DIST^_OUTER,DS^_DIST^_ALL^_INNER,DS^_DIST^_BOTH,DS^_BCAST^_INNER
      redshift_plan_steps.operation: "%Join%"
    sorts: [redshift_queries.total_time_executing desc]
    limit: '50'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: true
    value_labels: labels
    label_type: labPer
    series_types: {}
    series_colors:
      DS_BCAST_INNER: "#d3271d"
      DS_DIST_BOTH: "#fa6600"
      DS_DIST_INNER: "#82c400"
      DS_DIST_NONE: "#276300"
      DS_DIST_ALL_INNER: "#5f00cf"
      DS_DIST_ALL_NONE: "#1c8b19"
    limit_displayed_rows_values:
      show_hide: show
      first_last: first
      num_rows: '20'
    
    
  - name: capacity_header
    type: text
    title_text: "Capacity"
    subtitle_text: ""
    body_text: ""
    
  - name: queries_and_queued_per_hour
    title: Queries submitted & queued by hour
    type: looker_line
    model: redshift_model
    explore: redshift_queries
    dimensions: [redshift_queries.start_hour]
    fill_fields: [redshift_queries.start_hour]
    measures: [redshift_queries.count, redshift_queries.count_of_queued, redshift_queries.percent_queued,
      redshift_queries.total_time_in_queue]
    dynamic_fields:
    - table_calculation: minutes_queued
      label: Minutes Queued
      expression: "${redshift_queries.total_time_in_queue}/60"
      value_format:
      value_format_name: decimal_1
    sorts: [redshift_queries.start_hour desc]
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
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    ordering: none
    show_null_labels: false
    series_types:
      redshift_queries.count_of_queued: area
      minutes_queued: area
    y_axis_labels: [Count, Queued, Minutes Queued]
    y_axis_orientation: [left, left, right]
    hidden_series: [minutes_queued]
    hidden_fields: [redshift_queries.total_time_in_queue, redshift_queries.percent_queued]
    colors: ['palette: Tomato to Steel Blue']
    series_colors:
      minutes_queued: "#e0bc5e"
      redshift_queries.count: "#2f24b5"
      redshift_queries.count_of_queued: "#d10c04"
