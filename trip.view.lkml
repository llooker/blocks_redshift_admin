view: trip {

  dimension: trip_bike_id {
    type: number
    sql: ${TABLE}.bike_id ;;
  }

  dimension: from_station_id {
    type: number
    sql: ${TABLE}.from_station_id ;;
  }

  dimension: usertype {
    type: string
    sql: ${TABLE}.usertype ;;
  }

  dimension_group: start_time {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.start_time ;;
  }

  dimension: trip_duration {
    type: number
    sql: ${TABLE}.trip_duration ;;
  }

  measure: trip_average_trip_duration_minutes {
    type: average
    sql: ${TABLE}.trip_duration ;;
  }

  measure: trip_percent_non_member {
    type: count
    sql: CASE WHEN (trip.usertype <> 'Member' OR trip.usertype IS NULL) THEN 1 ELSE NULL END))/(COUNT(*);;
  }

}

# SELECT
#
# end_station.name  AS end_station_name,
# end_station.station_id  AS end_station_station_id,
# start_station.name  AS start_station_name,
# start_station.station_id  AS start_station_station_id,
# trip.bike_id  AS trip_bike_id,
# trip.usertype  AS trip_usertype,
#
# 1.0 * (COUNT(*))/NULLIF((COUNT(DISTINCT (CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', trip.start_time , 'America/Los_Angeles')) AS DATE)) )), 0)  AS trip_average_trips_per_day,
# AVG((cast(trip.trip_duration as FLOAT64)) / 60.0) AS trip_average_trip_duration_minutes,
# (COUNT(CASE WHEN (trip.usertype <> 'Member' OR trip.usertype IS NULL) THEN 1 ELSE NULL END))/(COUNT(*))  AS trip_percent_non_member
#
# FROM bike_trips.trip  AS trip
# LEFT JOIN bike_trips.station  AS start_station ON trip.from_station_id = start_station.station_id
# LEFT JOIN bike_trips.station  AS end_station ON trip.from_station_id = end_station.station_id
#
# GROUP BY 1,2,3,4,5,6
# ORDER BY 7 DESC
# LIMIT 500



# 2. put redshift performance block on demo
#
# 3. build a derived table to determine station usage. number of trips by station. tier stations [0,100,1000,5000,10000] trips
#
# 4. templated filter. for the pdt above give the station statistics a variable time window. Lets say an end user was to know number of trips  for each station for the last 30 days or 90 days.
#
# 5. create an extended view of trips and put all the derived fields and measures on that view. create an extended view of trips and redefine trip.count as trips that lasted more than 1 minute
#
# 6. add an access filter so that end users can only look at info for 1 station
#
# 7. using html create a red, orange, yellow, green, blue background for stations that fall into the different tiers
#
# 8. create a high level trips dashboard and a stations dashboard and link them together on the station name field
