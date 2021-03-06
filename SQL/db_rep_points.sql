
  CREATE MATERIALIZED VIEW "MVW_STATSCAN_DB_REPPOINTS" ("DBUID", "GEOM")
  AS SELECT 
  DBUID, 
  SDO_CS.TRANSFORM(SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(dbrplong,dbrplat,NULL), NULL, NULL),3005) as GEOM 
FROM 
  src_statscan_db_carto
WHERE
  PRUID='59';
  CREATE INDEX "BCT_BI_ADMIN"."MVW_STATSCAN_DB_REPPOINTS_IDX" ON "BCT_BI_ADMIN"."MVW_STATSCAN_DB_REPPOINTS" ("GEOM") 
   INDEXTYPE IS "MDSYS"."SPATIAL_INDEX" ;
