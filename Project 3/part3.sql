-- Part 3 
USE `md_water_services`;
-- Task 1 : integrating the report 
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

select * from auditor_report ;

SELECT 
	location_id, 
    true_water_source_score 
FROM auditor_report ; 

SELECT
	auditor_report.location_id AS audit_location,
	auditor_report.true_water_source_score,
	visits.location_id AS visit_location,
	visits.record_id
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id;


SELECT
	auditor_report.location_id AS audit_location,
	auditor_report.true_water_source_score,
	visits.location_id AS visit_location,
	visits.record_id,
	subjective_quality_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN 
	water_quality 
ON visits.record_id = water_quality.record_id;


SELECT
	auditor_report.location_id ,
	visits.record_id,
	auditor_report.true_water_source_score AS auditor_score,
	subjective_quality_score AS surveyor_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN 
	water_quality 
ON visits.record_id = water_quality.record_id
LIMIT 10000;

SELECT
	auditor_report.location_id ,
	visits.record_id,
	auditor_report.true_water_source_score AS auditor_score,
	subjective_quality_score AS surveyor_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN 
	water_quality 
ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score = water_quality.subjective_quality_score
AND visits.visit_count = 1
LIMIT 10000;




SELECT
	auditor_report.location_id ,
	visits.record_id,
	auditor_report.true_water_source_score AS auditor_score,
	subjective_quality_score AS surveyor_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN 
	water_quality 
ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
AND visits.visit_count = 1
LIMIT 10000;


SELECT
	auditor_report.location_id ,
	auditor_report.type_of_water_source AS auditor_source,
	water_source.type_of_water_source AS survey_source,
	visits.record_id,
	auditor_report.true_water_source_score AS auditor_score,
	subjective_quality_score AS surveyor_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN 
	water_quality 
ON visits.record_id = water_quality.record_id
JOIN 
	water_source
ON water_source.source_id = visits.source_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
AND visits.visit_count = 1
LIMIT 10000;


-- Task 2 : linking records 

SELECT
	auditor_report.location_id ,
	visits.record_id,
	employee.employee_name,
	auditor_report.true_water_source_score AS auditor_score,
	subjective_quality_score AS surveyor_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN 
	water_quality 
ON visits.record_id = water_quality.record_id
JOIN 
	employee 
ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
AND visits.visit_count = 1
LIMIT 10000;


WITH 
	Incorrect_records AS ( SELECT
									auditor_report.location_id ,
									visits.record_id,
									employee.employee_name,
									auditor_report.true_water_source_score AS auditor_score,
									subjective_quality_score AS surveyor_score
							FROM
							auditor_report
							JOIN
							visits
							ON auditor_report.location_id = visits.location_id
							JOIN 
							water_quality 
							ON visits.record_id = water_quality.record_id
							JOIN 
							employee 
							ON employee.assigned_employee_id = visits.assigned_employee_id
							WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
							AND visits.visit_count = 1
LIMIT 10000 )
-- SELECT * FROM Incorrect_records;

SELECT DISTINCT employee_name,
count(employee_name) as number_of_mistakes 
 from Incorrect_records
 GROUP BY employee_name;


-- Task 3 : gathering evidence 

CREATE VIEW Incorrect_records AS (
SELECT
	auditor_report.location_id,
	visits.record_id,
	employee.employee_name,
	auditor_report.true_water_source_score AS auditor_score,
	wq.subjective_quality_score AS surveyor_score,
	auditor_report.statements AS statements
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality AS wq
ON visits.record_id = wq.record_id
JOIN
employee
ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE
visits.visit_count =1
AND auditor_report.true_water_source_score != wq.subjective_quality_score);

SELECT * FROM Incorrect_records;


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/

GROUP BY
employee_name)
-- SELECT * FROM error_count;
SELECT avg(number_of_mistakes) FROM error_count;

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/

GROUP BY
employee_name)
SELECT employee_name, 
number_of_mistakes 
From error_count where  number_of_mistakes > ( select avg(number_of_mistakes) FROM error_count);

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY
employee_name),
suspect_list AS (
select 
employee_name, 
number_of_mistakes 
from error_count where number_of_mistakes > ( select avg(number_of_mistakes) FROM error_count)
)
SELECT employee_name, 
number_of_mistakes from suspect_list;


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY
employee_name),
suspect_list AS (
select 
employee_name, 
number_of_mistakes 
from error_count where number_of_mistakes > ( select avg(number_of_mistakes) FROM error_count)
) SELECT
location_id,
employee_name,
statements
FROM
Incorrect_records
WHERE
employee_name  IN (SELECT employee_name FROM suspect_list)
AND statements LIKE '%cash%';


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY
employee_name),
suspect_list AS (
select 
employee_name, 
number_of_mistakes 
from error_count where number_of_mistakes > ( select avg(number_of_mistakes) FROM error_count)
) SELECT
location_id,
employee_name,
statements
FROM
Incorrect_records
WHERE
employee_name NOT IN (SELECT employee_name FROM suspect_list)
AND statements LIKE '%cash%';