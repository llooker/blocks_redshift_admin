- dashboard: redshift_performance
  title: Redshift Performance
  layout: newspaper
  elements:
  - title: Query time histogram
    name: Query time histogram
    model: redshift_model
    explore: redshift_queries
    type: looker_column
    fields:
    - redshift_queries.time_executing_roundup5
    - redshift_queries.count
    filters:
      redshift_queries.time_executing: not 0
    sorts:
    - redshift_queries.time_executing_roundup5
    limit: 500
    column_limit: 50
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
    listen:
      PDT: redshift_queries.pdt
    row: 0
    col: 0
    width: 12
    height: 6
  - title: Top 10 longest running queries
    name: Top 10 longest running queries
    model: redshift_model
    explore: redshift_queries
    type: table
    fields:
    - redshift_queries.query
    - redshift_queries.snippet
    - redshift_queries.time_executing_roundup1
    sorts:
    - redshift_queries.time_executing_roundup1 desc
    limit: 10
    column_limit: 50
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
    listen:
      PDT: redshift_queries.pdt
    row: 0
    col: 12
    width: 12
    height: 6
  - name: Modeling
    type: text
    title_text: Modeling
    subtitle_text: ''
    body_text: ''
    row: 6
    col: 0
    width: 24
    height: 2
  - title: Network distribution breakdown
    name: Network distribution breakdown
    model: redshift_model
    explore: redshift_plan_steps
    type: looker_pie
    fields:
    - redshift_plan_steps.network_distribution_type
    - redshift_queries.total_time_executing
    filters:
      redshift_plan_steps.operation: "%Join%"
    sorts:
    - redshift_queries.total_time_executing desc
    limit: 500
    column_limit: 50
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
      DS_DIST_NONE: "#37ce12"
      DS_DIST_ALL_NONE: "#17470c"
      DS_DIST_INNER: "#5f7c58"
      DS_DIST_OUTER: "#ff8828"
      DS_DIST_BOTH: "#c13c07"
      DS_BCAST_INNER: "#d6a400"
      DS_DIST_ALL_INNER: "#9e0f62"
    listen:
      PDT: redshift_queries.pdt
    row: 8
    col: 0
    width: 12
    height: 6
  - title: Top Network Distribution Operations
    name: Top Network Distribution Operations
    model: redshift_model
    explore: redshift_plan_steps
    type: table
    fields:
    - redshift_plan_steps.network_distribution_type
    - redshift_plan_steps.operation_argument
    - redshift_queries.count
    - redshift_queries.total_time_executing
    - redshift_queries.time_executing_per_query
    filters:
      redshift_plan_steps.network_distribution_type: DS^_DIST^_OUTER,DS^_DIST^_ALL^_INNER,DS^_DIST^_BOTH,DS^_BCAST^_INNER
      redshift_plan_steps.operation: "%Join%"
    sorts:
    - redshift_queries.total_time_executing desc
    limit: 50
    column_limit: 50
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
    listen:
      PDT: redshift_queries.pdt
    row: 8
    col: 12
    width: 12
    height: 6
  - name: Capacity
    type: text
    title_text: Capacity
    subtitle_text: ''
    body_text: ''
    row: 14
    col: 0
    width: 24
    height: 2
  - title: Queries submitted & queued by hour
    name: Queries submitted & queued by hour
    model: redshift_model
    explore: redshift_queries
    type: looker_line
    fields:
    - redshift_queries.start_hour
    - redshift_queries.count
    - redshift_queries.count_of_queued
    - redshift_queries.percent_queued
    - redshift_queries.total_time_in_queue
    fill_fields:
    - redshift_queries.start_hour
    sorts:
    - redshift_queries.start_hour desc
    limit: 500
    column_limit: 50
    dynamic_fields:
    - table_calculation: minutes_queued
      label: Minutes Queued
      expression: "${redshift_queries.total_time_in_queue}/60"
      value_format:
      value_format_name: decimal_1
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
    y_axis_labels:
    - Count
    - Queued
    - Minutes Queued
    y_axis_orientation:
    - left
    - left
    - right
    hidden_series:
    - minutes_queued
    hidden_fields:
    - redshift_queries.total_time_in_queue
    - redshift_queries.percent_queued
    colors:
    - 'palette: Tomato to Steel Blue'
    series_colors:
      minutes_queued: "#e0bc5e"
      redshift_queries.count: "#2f24b5"
      redshift_queries.count_of_queued: "#d10c04"
    listen:
      PDT: redshift_queries.pdt
    row: 16
    col: 0
    width: 24
    height: 6
  filters:
  - name: PDT
    title: PDT
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: redshift_model
    explore: redshift_queries
    listens_to_filters: []
    field: redshift_queries.pdt
