-- View: staging.stop_names

-- DROP VIEW staging.stop_names;

CREATE OR REPLACE VIEW staging.stop_names AS 
 SELECT stop_names.stopid,
    concat_ws('_'::text, stop_names.direction, stop_names.name_full, stop_names.side, stop_names.cross_street) AS stopsite,
        CASE
            WHEN stop_names.direction = 'NB'::text THEN concat_ws(' '::text, 'Northbound', stop_names.name_full, 'at', stop_names.cross_street)
            WHEN stop_names.direction = 'SB'::text THEN concat_ws(' '::text, 'Southbound', stop_names.name_full, 'at', stop_names.cross_street)
            WHEN stop_names.direction = 'EB'::text THEN concat_ws(' '::text, 'Eastbound', stop_names.name_full, 'at', stop_names.cross_street)
            WHEN stop_names.direction = 'WB'::text THEN concat_ws(' '::text, 'Westbound', stop_names.name_full, 'at', stop_names.cross_street)
            ELSE NULL::text
        END AS stopname
   FROM ( SELECT DISTINCT ON (stop.stopid) stop.stopid,
            road.name_full,
            st_distance(stop.geom, road.geom) AS distance,
                CASE
                    WHEN st_linecrossingdirection(st_makeline(stop.geom, st_setsrid(st_makepoint(st_x(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * sin(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom))), st_y(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * cos(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)))), 3005)), road.geom) = (-1) AND st_line_locate_point(road.geom, st_closestpoint(road.geom, stop.geom)) <= 0.5::double precision THEN 'NS'::text
                    WHEN st_linecrossingdirection(st_makeline(stop.geom, st_setsrid(st_makepoint(st_x(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * sin(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom))), st_y(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * cos(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)))), 3005)), road.geom) = 1 AND st_line_locate_point(road.geom, st_closestpoint(road.geom, stop.geom)) < 0.5::double precision THEN 'FS'::text
                    WHEN st_linecrossingdirection(st_makeline(stop.geom, st_setsrid(st_makepoint(st_x(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * sin(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom))), st_y(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * cos(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)))), 3005)), road.geom) = (-1) AND st_line_locate_point(road.geom, st_closestpoint(road.geom, stop.geom)) > 0.5::double precision THEN 'FS'::text
                    WHEN st_linecrossingdirection(st_makeline(stop.geom, st_setsrid(st_makepoint(st_x(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * sin(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom))), st_y(stop.geom) + (st_distance(stop.geom, road.geom) + 1::double precision) * cos(st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)))), 3005)), road.geom) = 1 AND st_line_locate_point(road.geom, st_closestpoint(road.geom, stop.geom)) >= 0.5::double precision THEN 'NS'::text
                    ELSE 'Unknown'::text
                END AS side,
                CASE
                    WHEN st_line_locate_point(road.geom, st_closestpoint(road.geom, stop.geom)) < 0.5::double precision THEN ( SELECT cross_street.name_full
                       FROM src_geobc.road cross_street
                      WHERE st_dwithin(st_startpoint(road.geom), cross_street.geom, 1::double precision) AND road.name_full::text <> cross_street.name_full::text
                     LIMIT 1)
                    ELSE ( SELECT cross_street.name_full
                       FROM src_geobc.road cross_street
                      WHERE st_dwithin(st_endpoint(road.geom), cross_street.geom, 1::double precision) AND road.name_full::text <> cross_street.name_full::text
                     LIMIT 1)
                END AS cross_street,
                CASE
                    WHEN st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) >= (pi() * 0::double precision) AND st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) <= (pi() * 0.25::double precision) THEN 'EB'::text
                    WHEN st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) >= (pi() * 0.25::double precision) AND st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) <= (pi() * 0.75::double precision) THEN 'SB'::text
                    WHEN st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) >= (pi() * 0.75::double precision) AND st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) <= (pi() * 1.25::double precision) THEN 'WB'::text
                    WHEN st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) >= (pi() * 1.25::double precision) AND st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) <= (pi() * 1.75::double precision) THEN 'NB'::text
                    WHEN st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) >= (pi() * 1.75::double precision) AND st_azimuth(stop.geom, st_closestpoint(road.geom, stop.geom)) <= (pi() * 2::double precision) THEN 'EB'::text
                    ELSE 'Unknown'::text
                END AS direction
           FROM src_bctransit.stop stop,
            src_geobc.road road
          WHERE st_dwithin(stop.geom, road.geom, 50::double precision)
          ORDER BY stop.stopid, st_distance(stop.geom, road.geom)) stop_names;

ALTER TABLE staging.stop_names
  OWNER TO "BIAdmin";
GRANT ALL ON TABLE staging.stop_names TO "BIAdmin";
GRANT SELECT ON TABLE staging.stop_names TO "BIRead";
