-- Materialized View: staging.vw_population

-- DROP MATERIALIZED VIEW staging.vw_population;

CREATE MATERIALIZED VIEW staging.vw_population AS 
 SELECT row_number() OVER () AS id,
    db.dbuid::bigint AS dbuid,
    bcpop.year::integer AS year,
    scpop.pop2011::numeric * bcpop.growth_base_2011 AS population,
        CASE
            WHEN db.populated_area > 0::numeric THEN scpop.pop2011::numeric * bcpop.growth_base_2011 / db.populated_area
            ELSE 0::numeric
        END AS density
   FROM staging.population_2011 scpop
     JOIN staging.dissemination_block_cartographic db ON scpop.dbuid = db.dbuid
     JOIN ( SELECT pop.lhauid,
            pop.year,
            pop.total / (( SELECT population.total
                   FROM staging.population
                  WHERE population.lhauid = pop.lhauid AND population.year = 2011::numeric)) AS growth_base_2011
           FROM staging.population pop) bcpop ON scpop.lhauid::numeric = bcpop.lhauid
WITH DATA;

ALTER TABLE staging.vw_population
  OWNER TO "BIAdmin";
GRANT ALL ON TABLE staging.vw_population TO "BIAdmin";
GRANT SELECT ON TABLE staging.vw_population TO "BIRead";
