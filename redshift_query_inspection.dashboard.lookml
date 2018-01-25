- dashboard: redshift_query_inspection
  title: Redshift Query Inspection
  layout: tile
  tile_size: 50
  auto_run: true

  filters:
  - name: query
    type: field_filter
    explore: redshift_queries
    field: redshift_queries.query
    # default: 0

  elements:
  - name: time_executing
    type: single_value
    height: 3
    width: 8
    title:
    model: redshift_model
    explore: redshift_queries
    measures: [redshift_queries.total_time_executing]
    listen:
      query: redshift_queries.query
    limit: '500'
    column_limit: '50'
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    single_value_title: seconds to run
    value_format: "#,##0.0"

  - name: bytes_scanned
    type: single_value
    height: 3
    width: 8
    title:
    model: redshift_model
    explore: redshift_query_execution
    measures: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned, redshift_query_execution.total_rows_sorted_approx,
      redshift_query_execution.average_step_skew, redshift_query_execution.any_disk_based]
    listen:
      query: redshift_query_execution.query
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    value_format: '#,##0.0,," Mb"'
    single_value_title: Scanned
    hidden_fields: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed]

  - name: query_text
    height: 9
    width: 16
    type: table
    title: Query text
    model: redshift_model
    explore: redshift_queries
    dimensions: [redshift_queries.text]
    listen:
      query: redshift_queries.query
    sorts: [redshift_queries.text]
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: false
    truncate_column_names: true
    hide_totals: false
    hide_row_totals: false
    table_theme: white
    limit_displayed_rows: true
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    limit_displayed_rows_values:
      show_hide: show
      first_last: first
      num_rows: '1'

  - name: bytes_distributed
    type: single_value
    height: 3
    width: 8
    title:
    model: redshift_model
    explore: redshift_query_execution
    measures: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned, redshift_query_execution.total_rows_sorted_approx,
      redshift_query_execution.average_step_skew, redshift_query_execution.any_disk_based]
    listen:
      query: redshift_query_execution.query
    limit: '500'
    column_limit: '50'
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    value_format: '#,##0.0,," Mb"'
    single_value_title: Distributed
    hidden_fields: [redshift_query_execution.total_bytes_broadcast]

  - name: bytes_broadcast
    type: single_value
    height: 3
    width: 8
    title:
    model: redshift_model
    explore: redshift_query_execution
    measures: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned, redshift_query_execution.total_rows_sorted_approx,
      redshift_query_execution.average_step_skew, redshift_query_execution.any_disk_based]
    listen:
      query: redshift_query_execution.query
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    value_format: '#,##0.0,," Mb"'
    single_value_title: Broadcast

  - name: rows_sorted
    type: single_value
    height: 3
    width: 8
    title:
    model: redshift_model
    explore: redshift_query_execution
    measures: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned, redshift_query_execution.total_rows_sorted_approx,
      redshift_query_execution.average_step_skew, redshift_query_execution.any_disk_based]
    listen:
      query: redshift_query_execution.query
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    value_format: '#,##0, "k"'
    single_value_title: Rows sorted
    hidden_fields: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned]

  - name: was_disk_based
    type: single_value
    height: 3
    width: 8
    title:
    model: redshift_model
    explore: redshift_query_execution
    measures: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned, redshift_query_execution.total_rows_sorted_approx,
      redshift_query_execution.average_step_skew, redshift_query_execution.any_disk_based]
    listen:
      query: redshift_query_execution.query
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    value_format: ''
    single_value_title: Disk based?
    hidden_fields: [redshift_query_execution.total_bytes_broadcast, redshift_query_execution.total_bytes_distributed,
      redshift_query_execution.total_bytes_scanned, redshift_query_execution.total_rows_sorted_approx,
      redshift_query_execution.average_step_skew]

  - name: query_tables
    title: "Table Details"
    height: 6
    width: 32
    type: table
    model: redshift_model
    explore: redshift_tables
    dimensions: [redshift_tables.schema, redshift_tables.table, redshift_tables.rows_in_table,
      redshift_tables.distribution_style, redshift_tables.skew_rows, redshift_tables.encoded,
      redshift_tables.sortkey, redshift_tables.sortkey_encoding, redshift_tables.unsorted,
      redshift_tables.stats_off]
    measures: [redshift_query_execution.total_bytes_scanned, redshift_query_execution.emitted_rows_to_table_rows_ratio,
      redshift_query_execution.any_restricted_scan]
    listen:
      query: redshift_queries.query
    sorts: [redshift_query_execution.total_bytes_scanned desc]
    limit: '40'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}

  - name: plan_steps
    title: "Query Plan"
    height: 18
    width: 32
    type: table
    model: redshift_model
    explore: redshift_plan_steps
    dimensions: [redshift_plan_steps.step, redshift_plan_steps.parent_step, redshift_plan_steps.operation,
      redshift_plan_steps.network_distribution_type, redshift_plan_steps.operation_argument,
      redshift_plan_steps.table, redshift_plan_steps.rows, redshift_plan_steps.bytes]
    listen:
      query: redshift_plan_steps.query
    sorts: [redshift_plan_steps.step]
    limit: '2000'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false

  - name: execution
    title: "Query Execution"
    height: 18
    width: 32
    type: table
    model: redshift_model
    explore: redshift_query_execution
    dimensions: [redshift_query_execution.step, redshift_query_execution.label, redshift_query_execution.was_diskbased,
      redshift_query_execution.rows_out, redshift_query_execution.bytes, redshift_query_execution.step_skew,
      redshift_query_execution.step_max_slice_time]
    listen:
      query: redshift_query_execution.query
    sorts: [redshift_query_execution.step]
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
