USE projects;
-- QUESTIONS
SELECT * FROM hr;
-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company 
SELECT race, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT min(age) AS youngest, max(age) AS oldest
FROM hr
WHERE termdate IS NULL;

SELECT 
	CASE
		WHEN age >=18 AND age <= 24 THEN '18-24'
        WHEN age >=25 AND age <= 34 THEN '25-34'
        WHEN age >=35 AND age <= 44 THEN '35-44'
        WHEN age >=45 AND age <= 54 THEN '45-54'
        WHEN age >=55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) AS count
    FROM hr
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group;
    
    
    
    SELECT 
	CASE
		WHEN age >=18 AND age <= 24 THEN '18-24'
        WHEN age >=25 AND age <= 34 THEN '25-34'
        WHEN age >=35 AND age <= 44 THEN '35-44'
        WHEN age >=45 AND age <= 54 THEN '45-54'
        WHEN age >=55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,gender,
    count(*) AS count
    FROM hr
    WHERE termdate IS NULL
    GROUP BY age_group, gender
    ORDER BY age_group, gender;
    
  -- 4. How many employees work at headquarters vs remote?
  SELECT location, count(*) AS count
  FROM hr
  WHERE termdate IS NULL
  GROUP BY location;
  
  
  -- 5. What id the avg lenght of employment for employees who have been terminated?
  SELECT 
  ROUND(AVG(datediff(termdate, hire_date))/365,0) AS avg_length_employ
  FROM hr
  WHERE termdate IS NOT NULL AND termdate <=curdate();
  
  
  -- 6. How does the gender distribution vary across departments & job titles?
  SELECT department, gender, COUNT(*)  AS count
  FROM hr
  WHERE termdate IS NULL
  GROUP BY department, gender
  ORDER BY department;
  
  -- 7.  What is the distribution of jobs titles across the company?
  
  SELECT jobtitle, COUNT(*) AS count
  FROM hr
  WHERE termdate IS NULL
  GROUP BY jobtitle
  ORDER BY count DESC;
  
  -- 8. Which department has the highest turnover rate?
  SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    GROUP BY department
    ) AS subquery
    ORDER BY termination_rate DESC;
    
-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10. HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERM DATES?
SELECT
year,
hires,
terminations,
hires - terminations AS net_change,
ROUND(((hires - terminations)/hires)*100,2) AS net_change_percent
FROM(
SELECT YEAR(hire_date) AS year,
COUNT(*) AS hires,
SUM(case when termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
FROM hr
GROUP BY YEAR(hire_date)
) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate()
GROUP BY department;

