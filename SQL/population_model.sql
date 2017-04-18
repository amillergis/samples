
  CREATE MATERIALIZED VIEW "MVW_BCT_DB_POPULATION_MODEL" ("DBUID", "YEAR", "POPULATION", "POPULATION_DENSITY", "GEOM")
  AS SELECT
  dbc.dbuid,
  year,
  -- Multiply Census 2011 Population by growth factor adjustment for each year
  -- and Census Net Undercount %2.32 to estimate annual db population
  CAST((population * total * 1.0232) as INTEGER) as population,
  -- Calculate the population density of the dissemination block
  CAST((((CAST((population * total * 1.0232) as INTEGER))/dbbc.area) * 1000000) AS INTEGER) as population_density,
  geom

FROM (
  -- Spatial Join to determine which LHA each dissemination block is located in
  SELECT /*+ ordered */ 
    a.dbuid,
    b.lha_num
  FROM 
    TABLE(sdo_join ('mvw_statscan_db_reppoints', 'GEOM','src_bcstats_lha_geom', 'GEOM','mask=ANYINTERACT')) c,
    mvw_statscan_db_reppoints a,  -- VIEW CREATED BY CONVERTING DB GEOMETRY TO POINTS
    src_bcstats_lha_geom b  -- SOURCE TABLE
  WHERE 
    c.rowid1 = a.rowid AND 
    c.rowid2 = b.rowid
  ) dbc

-- Join view table containing population attributes and geometry including counts
JOIN
  mvw_statscan_db_bc dbbc on dbbc.dbuid = dbc.dbuid

-- Pivot LHA numbers and divide by 2011 population to calculate estimated adjustment
-- factor i.e. growth or decrease in population
JOIN ( 
  SELECT 
    *
  FROM (
    SELECT 
      lhauid,
      local_health_area,
      -- Divide yearly population by 2011 population(census baseline) to determine
      -- approximate growth or loss factor
      "1986"/"2011" as "1986", "1987"/"2011" as "1987", "1988"/"2011" as "1988", 
      "1989"/"2011" as "1989", "1990"/"2011" as "1990", "1991"/"2011" as "1991",
      "1992"/"2011" as "1992", "1993"/"2011" as "1993", "1994"/"2011" as "1994",
      "1995"/"2011" as "1995", "1996"/"2011" as "1996", "1997"/"2011" as "1997",
      "1998"/"2011" as "1998", "1999"/"2011" as "1999", "2000"/"2011" as "2000",
      "2001"/"2011" as "2001", "2002"/"2011" as "2002", "2003"/"2011" as "2003",
      "2004"/"2011" as "2004", "2005"/"2011" as "2005", "2006"/"2011" as "2006",
      "2007"/"2011" as "2007", "2008"/"2011" as "2008", "2009"/"2011" as "2009",      
      "2010"/"2011" as "2010", "2011"/"2011" as "2011", "2012"/"2011" as "2012",
      "2013"/"2011" as "2013", "2014"/"2011" as "2014", "2015"/"2011" as "2015",
      "2016"/"2011" as "2016", "2017"/"2011" as "2017", "2018"/"2011" as "2018",
      "2019"/"2011" as "2019", "2020"/"2011" as "2020", "2021"/"2011" as "2021",
      "2022"/"2011" as "2022", "2023"/"2011" as "2023", "2024"/"2011" as "2024",
      "2025"/"2011" as "2025", "2026"/"2011" as "2026", "2027"/"2011" as "2027",
      "2028"/"2011" as "2028", "2029"/"2011" as "2029", "2030"/"2011" as "2030",
      "2031"/"2011" as "2031", "2032"/"2011" as "2032", "2033"/"2011" as "2033",
      "2034"/"2011" as "2034", "2035"/"2011" as "2035", "2036"/"2011" as "2036",
      "2037"/"2011" as "2037", "2038"/"2011" as "2038", "2039"/"2011" as "2039",
      "2040"/"2011" as "2040","2041"/"2011" as "2041"
    FROM (
      SELECT 
        lhauid,
        local_health_area,
        total,
        year
      -- Combine estimates and projections from BC Stats to form one table with
      -- consecutive populations from 1986-2041
      FROM (SELECT * FROM src_bcstats_lha_estimate UNION ALL SELECT * FROM src_bcstats_lha_projection)  --SOURCE TABLES
    )
    -- Pivot table in order to calculate growth or loss based on y2011 value
    PIVOT (MAX(total) FOR (year) in (
      1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 
      1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
      2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015,
      2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025,
      2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035,
      2036, 2037, 2038, 2039, 2040, 2041))
  )
  -- Unpivot table to return it to one record for each LHA per year in order to
  -- join it to the DB populations
  UNPIVOT (total FOR year IN (
  "1986", "1987", "1988", "1989", "1990", "1991", "1992", "1993", "1994", "1995",
  "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005",
  "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015",
  "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025",
  "2026", "2027", "2028", "2029", "2030", "2031", "2032", "2033", "2034", "2035",
  "2036", "2037", "2038", "2039", "2040","2041"))) lha
ON 
  lha.lhauid = dbc.lha_num;

  CREATE INDEX "BCT_BI_ADMIN"."MVW_BCT_DB_POP_MODEL_IDX" ON "BCT_BI_ADMIN"."MVW_BCT_DB_POPULATION_MODEL" ("GEOM") 
   INDEXTYPE IS "MDSYS"."SPATIAL_INDEX" ;
