 
-- Task 1: Get to know our data
-- Show all of the tables. Selecting "SHOW TABLES;" with your cursor and running it, will run only that part.
SHOW TABLES;



 -- location table
SELECT
   *
FROM
   location
LIMIT 10;
-- Add some notes
-- Look at the visits table
SELECT * FROM visits;

-- Look at the water_source table
SELECT * FROM water_source;


-- Task 2: Dive into the water sources

-- unique types of water sources.
SELECT DISTINCT 
	type_of_water_source 
FROM 
	water_source;

-- time_in_queue is more than some crazy time, say 500 min.
SELECT * FROM 
	visits 
WHERE time_in_queue >= 500;


-- Task 3: Unpack the visits to water sources

-- Let's check the records for these source_ids AkRu05234224 HaZa21742224.
SELECT * FROM 
	water_source 
WHERE  source_id IN ( 'AkRu05234224' , 'HaZa21742224');

-- Task 4: Assess the quality of water sources

/* The table that contains a quality score for each visit made about a water source that was assigned by a Field surveyor.
 They assigned a score to each source from 1, being terrible, to 10 for a good, clean water source in a home.*/
SELECT * FROM water_quality;

-- records where the subject_quality_score is 10  and where the source was visited a second time.
SELECT * FROM 
	water_quality 
WHERE subjective_quality_score = 10 AND visit_count = 2;

-- Task 5: Investigate any pollution issues

-- Find the right table that recorded contamination/pollution data for all of the well sources and print the first few rows.
SELECT  * FROM 
	well_pollution 
LIMIT 15;

-- query that checks if the results is Clean but the biological column is > 0.01.
SELECT * FROM 
	well_pollution 
WHERE results = 'Clean' AND biological > 0.01;

-- Search for descriptions that have the word Clean with additional characters after it.
SELECT * FROM 
	well_pollution 
WHERE  description LIKE '%Clean %' ;

UPDATE
	well_pollution
SET
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';

UPDATE
	well_pollution
SET
	description = 'Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';

UPDATE
	well_pollution
SET
	result = 'Contaminated : Biological'
WHERE
	biological > 0.01 AND results = 'Clean';
-- copy of well_pollution table
CREATE TABLE
	md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
	well_pollution
);
-- I just wanted to check the copy table :)
SELECT * FROM well_pollution_copy;

SET SQL_SAFE_UPDATES = 0;
UPDATE
	well_pollution_copy
SET
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';

UPDATE
	well_pollution_copy
SET
	description = 'Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';

UPDATE
	well_pollution_copy
SET
	results = 'Contaminated: Biological'
WHERE
	biological > 0.01 AND results = 'Clean';

-- testing if the data is fixed now and there is no errors 
SELECT * FROM 
	well_pollution_copy 
WHERE 
	results = 'Clean' 
AND 
	biological > 0.01;
    
SELECT * FROM 
	well_pollution_copy 
WHERE  description LIKE '%Clean %' ;

SELECT
*
FROM
	well_pollution_copy
WHERE
	description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

-- fixing the well_pollution table 
UPDATE
	well_pollution
SET
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';

UPDATE
	well_pollution
SET
	description = 'Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';

UPDATE
	well_pollution
SET
	results = 'Contaminated : Biological'
WHERE
	biological > 0.01 AND results = 'Clean';

-- checking if the update worked 
SELECT
*
FROM
	well_pollution
WHERE
	description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

DROP TABLE well_pollution_copy;