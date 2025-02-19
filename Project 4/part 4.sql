-- Part 4 of the project 

use md_water_services;
-- Task 1 : Joining pieces together 
-- Joining the location table and the visits table 
SELECT 
    location.province_name, 
    location.town_name, 
    visits.visit_count, 
    location.location_id
FROM visits 
INNER JOIN location ON location.location_id = visits.location_id;
-- Joining the vists and location and the water source tables 
SELECT 
    location.province_name, 
    location.town_name, 
    visits.visit_count, 
    location.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM visits 
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id;



SELECT 
    location.province_name, 
    location.town_name, 
    visits.visit_count, 
    location.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM visits 
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
where visits.location_id = 'AkHa00103';

SELECT 
    location.province_name, 
    location.town_name, 
    visits.visit_count, 
    location.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM visits 
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
where visits.visit_count = 1;


SELECT 
    location.province_name, 
    location.town_name, 
    water_source.type_of_water_source,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue
FROM visits 
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
where visits.visit_count = 1;

SELECT
water_source.type_of_water_source,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

CREATE VIEW combined_analysis_table AS
SELECT
	water_source.type_of_water_source AS source_type,
	location.town_name,
	location.province_name,
	location.location_type,
	water_source.number_of_people_served AS people_served,
	visits.time_in_queue,
	well_pollution.results
FROM
	visits
LEFT JOIN
	well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
	water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;


-- Task 2 : last analysis 
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;



WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
*
FROM
province_totals;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

SELECT * FROM town_aggregated_water_access
where tap_in_home + tap_in_home_broken < 50 ;


SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *

	100,0) AS Pct_broken_taps

FROM
	town_aggregated_water_access;

-- Task 4 : Practical plan 
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same

source more than once in the future.

*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,

and should refer to the source table. This ensures data integrity.

*/
Address VARCHAR(50), -- Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);


SELECT
	location.address,
	location.town_name,
	location.province_name,
	water_source.source_id,
	water_source.type_of_water_source,
	well_pollution.results
FROM
	water_source
LEFT JOIN
	well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
	visits ON water_source.source_id = visits.source_id
INNER JOIN
	location ON location.location_id = visits.location_id
WHERE
	visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
	results != 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source = 'shared_tap' AND time_in_queue >30)
)
LIMIT 1000000;

SET SQL_SAFE_UPDATES = 0;
/*
INSERT INTO project_progress (source_id)  
SELECT DISTINCT source_id FROM well_pollution;

UPDATE project_progress
JOIN well_pollution ON project_progress.source_id = well_pollution.source_id
SET project_progress.Improvement = 
    CASE 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        ELSE NULL
    END;
  
UPDATE project_progress pp
JOIN water_source ws ON pp.source_id = ws.source_id
SET pp.source_type = ws.type_of_water_source;

    UPDATE project_progress pp
JOIN water_source ws ON pp.source_id = ws.source_id
SET pp.improvement = 'Drill well'
WHERE ws.type_of_water_source = 'river';
*/
TRUNCATE TABLE project_progress;
INSERT INTO project_progress (source_id, town, province, source_type)
SELECT 
    ws.source_id,
    loc.town_name AS town,
    loc.province_name AS province,
    ws.type_of_water_source AS source_type
FROM 
    water_source ws
JOIN 
    visits v ON ws.source_id = v.source_id
JOIN 
    location loc ON v.location_id = loc.location_id;
    
UPDATE project_progress
JOIN well_pollution ON project_progress.source_id = well_pollution.source_id
SET project_progress.Improvement = 
    CASE 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        ELSE NULL
    END;
    
    UPDATE project_progress
SET Improvement = 'Drill well'
WHERE source_type = 'river';


UPDATE project_progress pp
JOIN water_source ws ON pp.source_id = ws.source_id
JOIN visits v ON pp.source_id = v.source_id
SET pp.Improvement = 
    CASE 
        WHEN ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30
        THEN CONCAT(IFNULL(pp.Improvement, ''), " Install ", FLOOR(v.time_in_queue / 30), " taps nearby")
        ELSE pp.Improvement
    END;
UPDATE project_progress pp
SET pp.Improvement = 
    CASE 
        WHEN pp.source_type LIKE '%tap_in_home_broken%' 
        THEN CONCAT(IFNULL(pp.Improvement, ''), " Diagnose local infrastructure")
        ELSE pp.Improvement
    END;

SELECT
	project_progress.Project_id, 
	project_progress.Town, 
	project_progress.Province, 
	project_progress.Source_type, 
	project_progress.Improvement,
	Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served)
FROM  project_progress 
JOIN water_source 
ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served;
