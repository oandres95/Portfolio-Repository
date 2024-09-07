-- Select all records from the original table
SELECT *
FROM layoffs_1;

-- Identify duplicate records based on specified columns
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ORDER BY (SELECT NULL)
    ) AS row_num
    FROM layoffs_1
)
-- Select only the duplicate records
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Remove duplicate records from the original table
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ORDER BY (SELECT NULL)
    ) AS row_num
    FROM layoffs_1
)
DELETE FROM layoffs_1
WHERE EXISTS (
    SELECT 1
    FROM duplicate_cte
    WHERE duplicate_cte.row_num > 1
    AND duplicate_cte.company = layoffs_1.company
    AND duplicate_cte.location = layoffs_1.location
    AND duplicate_cte.industry = layoffs_1.industry
    AND duplicate_cte.total_laid_off = layoffs_1.total_laid_off
    AND duplicate_cte.percentage_laid_off = layoffs_1.percentage_laid_off
    AND duplicate_cte.`date` = layoffs_1.`date`
    AND duplicate_cte.stage = layoffs_1.stage
    AND duplicate_cte.country = layoffs_1.country
    AND duplicate_cte.funds_raised_millions = layoffs_1.funds_raised_millions
);

-- Create a new table for cleaned data
CREATE TABLE `layoffs_2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` DATE,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert cleaned data into the new table
INSERT INTO layoffs_2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ORDER BY (SELECT NULL)
) AS row_num
FROM layoffs_1;

-- Disable safe updates to allow deletion
SET SQL_SAFE_UPDATES = 0;

-- Remove duplicates from the new table
DELETE FROM layoffs_2
WHERE row_num > 1;

-- Verify that no duplicates remain
SELECT *
FROM layoffs_2
WHERE row_num > 1;

-- Standardize data by removing leading and trailing spaces from 'company'
SELECT company, TRIM(company) AS trimmed_company
FROM layoffs_2;

UPDATE layoffs_2
SET company = TRIM(company);

-- List distinct industries for review
SELECT DISTINCT(industry)
FROM layoffs_2
ORDER BY industry;

-- Count the occurrences of each industry
SELECT industry, COUNT(*) AS count
FROM layoffs_2
GROUP BY industry
ORDER BY count DESC;

-- Standardize 'Crypto Currency' to 'Crypto'
SELECT *
FROM layoffs_2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize 'Fintech' to 'Finance'
SELECT *
FROM layoffs_2
WHERE industry LIKE 'Fin%';

UPDATE layoffs_2
SET industry = 'Finance'
WHERE industry LIKE 'Fin%';

-- Review and standardize country names
SELECT DISTINCT(country)
FROM layoffs_2
ORDER BY country;

-- Standardize variations of 'United States'
UPDATE layoffs_2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Convert 'date' column from text to date format
SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_2;

UPDATE layoffs_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter the 'date' column to use DATE type
ALTER TABLE layoffs_2
MODIFY COLUMN `date` DATE;

-- Handle NULL and blank values
-- Find records with NULL or blank 'industry'
SELECT *
FROM layoffs_2
WHERE industry IS NULL OR industry = '';

-- Find records with NULL 'industry' and corresponding non-NULL records to update from
SELECT t1.company, t1.industry AS t1_industry, t2.industry AS t2_industry
FROM layoffs_2 t1
JOIN layoffs_2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;

-- Update blank 'industry' values to NULL
UPDATE layoffs_2
SET industry = NULL
WHERE industry = '';

-- Use a self-join to fill NULL 'industry' values with non-NULL values from the same company
UPDATE layoffs_2 t1
JOIN layoffs_2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;

-- Delete rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
DELETE FROM layoffs_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Drop the 'row_num' column as it is no longer needed
ALTER TABLE layoffs_2
DROP COLUMN row_num;

-- Final check of the cleaned data
SELECT *
FROM layoffs_2;
