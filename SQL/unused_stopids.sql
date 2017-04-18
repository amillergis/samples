-- View: view_basemap.unused_stopids

-- DROP VIEW view_basemap.unused_stopids;

CREATE OR REPLACE VIEW view_basemap.unused_stopids AS 
 SELECT l.stopid,
        CASE
            WHEN l.stopid >= 100000 AND l.stopid <= 103999 THEN 'Victoria Regional Transit System'::text
            WHEN l.stopid >= 104000 AND l.stopid <= 107999 THEN 'Regional District of Nanaimo Transit System'::text
            WHEN l.stopid >= 108000 AND l.stopid <= 109999 THEN 'Cowichan Valley Regional Transit System'::text
            WHEN l.stopid >= 110000 AND l.stopid <= 111999 THEN 'Comox Valley Transit System'::text
            WHEN l.stopid >= 112000 AND l.stopid <= 113999 THEN 'Campbell River Transit System'::text
            WHEN l.stopid >= 114000 AND l.stopid <= 114999 THEN 'Port Alberni Regional Transit System'::text
            WHEN l.stopid >= 115000 AND l.stopid <= 115999 THEN 'Mount Waddington Transit System'::text
            WHEN l.stopid >= 116000 AND l.stopid <= 116999 THEN 'Powell River Regional Transit System'::text
            WHEN l.stopid >= 117000 AND l.stopid <= 117999 THEN 'Salt Spring Island Transit System'::text
            WHEN l.stopid >= 118000 AND l.stopid <= 118999 THEN 'Sunshine Coast Regional Transit System'::text
            WHEN l.stopid >= 120000 AND l.stopid <= 123999 THEN 'Central Fraser Valley Transit System'::text
            WHEN l.stopid >= 124000 AND l.stopid <= 125999 THEN 'Chilliwack Transit System'::text
            WHEN l.stopid >= 126000 AND l.stopid <= 126999 THEN 'Agassiz-Harrison Transit System'::text
            WHEN l.stopid >= 130000 AND l.stopid <= 133999 THEN 'Whistler Transit System'::text
            WHEN l.stopid >= 134000 AND l.stopid <= 134999 THEN 'Squamish Transit System'::text
            WHEN l.stopid >= 135000 AND l.stopid <= 135999 THEN 'Pemberton Valley Transit System'::text
            WHEN l.stopid >= 140000 AND l.stopid <= 143999 THEN 'Kelowna Regional Transit System'::text
            WHEN l.stopid >= 144000 AND l.stopid <= 145999 THEN 'Vernon Regional Transit System'::text
            WHEN l.stopid >= 146000 AND l.stopid <= 147999 THEN 'Penticton and Okanagan Similkameen Transit System'::text
            WHEN l.stopid >= 148000 AND l.stopid <= 148999 THEN 'Summerland Transit System'::text
            WHEN l.stopid >= 149000 AND l.stopid <= 149999 THEN 'South Okanagan Transit System'::text
            WHEN l.stopid >= 150000 AND l.stopid <= 150999 THEN 'Princeton Regional Transit System'::text
            WHEN l.stopid >= 151000 AND l.stopid <= 154999 THEN 'Kamloops Transit System'::text
            WHEN l.stopid >= 155000 AND l.stopid <= 155999 THEN 'Merrit Regional Transit System'::text
            WHEN l.stopid >= 156000 AND l.stopid <= 156999 THEN 'Revelstoke Transit System'::text
            WHEN l.stopid >= 157000 AND l.stopid <= 157999 THEN 'Clearwater Regional Transit System'::text
            WHEN l.stopid >= 158000 AND l.stopid <= 158999 THEN 'Ashcroft-Clinton Transit System'::text
            WHEN l.stopid >= 159000 AND l.stopid <= 159999 THEN 'Shuswap Regional Transit System'::text
            WHEN l.stopid >= 160000 AND l.stopid <= 161999 THEN 'West Kootenay Transit System'::text
            WHEN l.stopid >= 162000 AND l.stopid <= 162999 THEN 'Creston Valley Transit System'::text
            WHEN l.stopid >= 164000 AND l.stopid <= 164999 THEN 'Boundary Transit System'::text
            WHEN l.stopid >= 170000 AND l.stopid <= 170999 THEN 'Cranbrook Transit System'::text
            WHEN l.stopid >= 171000 AND l.stopid <= 171999 THEN 'Kimberly Transit System'::text
            WHEN l.stopid >= 172000 AND l.stopid <= 172999 THEN 'Columbia Valley Transit System'::text
            WHEN l.stopid >= 174000 AND l.stopid <= 174999 THEN 'Elk Valley Transit System'::text
            WHEN l.stopid >= 180000 AND l.stopid <= 183999 THEN 'Prince George Transit System'::text
            WHEN l.stopid >= 184000 AND l.stopid <= 184999 THEN 'Quesnel Transit System'::text
            WHEN l.stopid >= 186000 AND l.stopid <= 186999 THEN 'Williams Lake Transit System'::text
            WHEN l.stopid >= 187000 AND l.stopid <= 187999 THEN '100 Mile House Regional Transit System'::text
            WHEN l.stopid >= 188000 AND l.stopid <= 188999 THEN 'Bella Coola Transit System'::text
            WHEN l.stopid >= 190000 AND l.stopid <= 190999 THEN 'Prince Rupert Transit System'::text
            WHEN l.stopid >= 191000 AND l.stopid <= 191999 THEN 'Port Edward Transit System'::text
            WHEN l.stopid >= 192000 AND l.stopid <= 192999 THEN 'Terrace Regional Transit System'::text
            WHEN l.stopid >= 193000 AND l.stopid <= 193999 THEN 'Skeena Regional Transit System'::text
            WHEN l.stopid >= 194000 AND l.stopid <= 194999 THEN 'Kitimat Transit System'::text
            WHEN l.stopid >= 195000 AND l.stopid <= 195999 THEN 'Smithers Regional Transit System'::text
            WHEN l.stopid >= 196000 AND l.stopid <= 196999 THEN 'Dawson Creek Transit System'::text
            WHEN l.stopid >= 197000 AND l.stopid <= 197999 THEN 'Hazletons Regional Transit System'::text
            WHEN l.stopid >= 198000 AND l.stopid <= 198999 THEN 'Fort St John Transit System'::text
            ELSE 'Unassigned'::text
        END AS system
   FROM ( SELECT generate_series(100000, 199999) AS stopid) l
  WHERE NOT (EXISTS ( SELECT r.stopid
           FROM src_bctransit.stop r
          WHERE r.stopid = l.stopid));
