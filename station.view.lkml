view: station {

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: id {
    type: number
    sql: ${TABLE}.station_id ;;
  }
}
