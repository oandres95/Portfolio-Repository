-- CREATE DATABASE projects;

USE projects;

SELECT * FROM hr;

-- Data Cleaning

-- 		Change Column names
ALTER table hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

-- Clean and convert 'birthdate' values to DATE format 
SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE 
	WHEN birthdate LIKE '%/%' THEN date_format((str_to_date(birthdate,'%m/%d/%Y')),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format((str_to_date(birthdate,'%m-%d-%Y')),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE; 

-- Clean and convert 'hire_date' values to DATE format 
SELECT hire_date FROM hr;

UPDATE hr
SET hire_date = CASE 
	WHEN hire_date LIKE '%/%' THEN date_format((str_to_date(hire_date,'%m/%d/%Y')),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format((str_to_date(hire_date,'%m-%d-%Y')),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- Clean and convert 'termdate' values to DATE format 
UPDATE hr
SET termdate = 
    CASE 
        WHEN TRIM(termdate) = '' THEN NULL
        ELSE DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
    END;

SELECT termdate FROM hr;

-- Change the data type of 'termdate' to DATE
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- adding age column
ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());
SELECT age,birthdate FROM hr;

-- 
SELECT 
	MIN(age) AS youngest,
    MAX(age) AS oldest
FROM hr;

SELECT COUNT(*) FROM hr WHERE age < 18;

-- Drop values with age under 18
DELETE FROM hr
WHERE age <18;


