/* Part 2 of the integreted project */

-- First task : add emails to employee table 
SELECT 
CONCAT ( LOWER (REPLACE(employee_name, ' ' , '.')), '@ndogowater.gov') AS new_email 
FROM md_water_services.employee;

SET SQL_SAFE_UPDATES = 0;
update 
	md_water_services.employee
set 
	email =  CONCAT ( LOWER (REPLACE(employee_name, ' ' , '.')), '@ndogowater.gov') ;

SELECT 
	count(assigned_employee_id) FROM md_water_services.employee
where 
	town_name IN ('Harare', 'Kilimani');

-- Task 2 : fix phone numbers length 
SELECT 
	LENGTH (phone_number) 
FROM 
	md_water_services.employee;

SELECT 
	RTRIM(phone_number) AS new_phone_num 
FROM 
	md_water_services.employee;

UPDATE 
	md_water_services.employee 
SET 
	phone_number = RTRIM(phone_number);
/* After executing the update query i executed the select employee table and select 
length queries to make sure that the task is done successfully */

-- Task 3 : honouring the workers 
SELECT 
	town_name, COUNT(employee_name) 
AS 
	num_employee 
FROM 
	md_water_services.employee 
GROUP BY town_name;

SELECT 
	assigned_employee_id, COUNT(assigned_employee_id) as num_visits 
FROM 
	md_water_services.visits
GROUP BY 
	assigned_employee_id
LIMIT 3;

/*SELECT assigned_employee_id, employee_name, phone_number, email FROM md_water_services.employee
WHERE assigned_employee_id in (20 ,22,44) ;*/
-- This the query used to find the top 3 employees 
SELECT 
	assigned_employee_id, employee_name, phone_number, email 
FROM 
	md_water_services.employee
WHERE assigned_employee_id IN (0, 1, 2 );

-- Task 4 : Analysing locations 
SELECT * FROM 
	md_water_services.location;
-- THE QUERY THAT COUNTS THE NUMBER OF RECORDS PER TOWN 
SELECT 
	COUNT(location_id) AS records_per_town , town_name 
FROM 
	md_water_services.location
GROUP BY 
	town_name;
 -- THE QUERY THAT COUNTS THE NUMBER OF RECORDS PER PROVINCE 
SELECT 
	COUNT(location_id) AS records_per_province , province_name 
FROM 
	md_water_services.location
GROUP BY 
	province_name;
-- 
SELECT 
	province_name, town_name, COUNT(location_id) AS records_per_town 
FROM 
	md_water_services.location
GROUP BY 
	province_name, town_name 
ORDER BY 
	province_name, records_per_town DESC ;
-- THE NUMBER OF RECORDS FOR EACH LOCATION TYPE 
SELECT 
	location_type, COUNT(location_id) AS num_sources 
FROM 
	md_water_services.location 
group by location_type ;

-- Task 5 : DIVING INTO SOURCES 
SELECT * FROM 
	md_water_services.water_source;
-- The total of people surveyed !! not sure if this is the right query !!!!! IT'S CORRECT 
SELECT 	
	SUM(number_of_people_served) AS total_of_people_served 
FROM 
	md_water_services.water_source;
-- The number of each of the different water source types
SELECT 
	type_of_water_source,  count(type_of_water_source) as number_of_sources  
FROM 
	md_water_services.water_source
GROUP BY 
	type_of_water_source;
--  The average number of people that are served by each water source
SELECT 
	type_of_water_source, ROUND( AVG(number_of_people_served)) as avg_people_per_source  
FROM 
	md_water_services.water_source
GROUP BY 
	type_of_water_source;
--  The total number of people that are served by each water source
SELECT 
	type_of_water_source, SUM(number_of_people_served) as total_people_per_source  
FROM 
	md_water_services.water_source
GROUP BY 
	type_of_water_source
ORDER BY 
	total_people_per_source DESC;
-- The percentage of prople served by each water source 
SELECT 
    type_of_water_source, 
   ROUND( SUM(number_of_people_served) * 100.0 / 
    (SELECT SUM(number_of_people_served) FROM md_water_services.water_source)) AS pct_of_people_served
FROM 
    md_water_services.water_source
GROUP BY 
    type_of_water_source
ORDER BY 
    pct_of_people_served DESC;

-- Task 6 : START OF A SOLUTION 
-- First query 
SELECT 
    type_of_water_source, 
    SUM(number_of_people_served) AS total_people_per_source,
    RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS rank_by_population
FROM 
    md_water_services.water_source
GROUP BY 
    type_of_water_source
ORDER BY 
    rank_by_population;

-- Second Query 
SELECT 
	source_id, 
    type_of_water_source,
    number_of_people_served,
    RANK() over (partition by  type_of_water_source order by number_of_people_served DESC) as rank_priority
FROM 
	md_water_services.water_source
ORDER BY type_of_water_source, rank_priority;

SELECT 
	source_id, 
    type_of_water_source,
    number_of_people_served,
    DENSE_RANK() over (partition by  type_of_water_source order by number_of_people_served DESC) as rank_priority
FROM 
	md_water_services.water_source
ORDER BY type_of_water_source, rank_priority;

-- Task 7 : ANALYSING QUEUES 
SELECT * FROM md_water_services.visits;

SELECT 
	MIN(time_of_record), MAX(time_of_record)  
FROM 
	md_water_services.visits;

-- The survey duration in days 
SELECT datediff(MAX(time_of_record), MIN(time_of_record))  as time_of_survey from md_water_services.visits;
--  how long people have to queue on average in Maji Ndogo.
SELECT AVG(NULLIF(time_in_queue, 0)) AS average_queue_time
    FROM md_water_services.visits ;
    
-- the queue times aggregated across the different days of the week.
SELECT dayname(time_of_record) as day_of_week ,
	ROUND(AVG(NULLIF(time_in_queue, 0)) )AS average_queue_time 
     FROM md_water_services.visits 
     GROUP BY dayname(time_of_record);
     
-- what time during the day people collect water.   
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') as hour_of_day ,
	ROUND(AVG(NULLIF(time_in_queue, 0)) )AS average_queue_time 
     FROM md_water_services.visits 
     GROUP BY TIME_FORMAT(TIME(time_of_record), '%H:00');


SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
	DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
	md_water_services.visits
WHERE
	time_in_queue != 0; -- this exludes other sources with 0 queue times.
    
    
SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
md_water_services.visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;



