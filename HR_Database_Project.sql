-- HR Database Test Document

-- Finding the total number of employees overall.
SELECT SUM(employee_count) AS total_employees_overall
FROM HR_Database;

-- Finding the total number of employees that have a high school education.
SELECT SUM(employee_count) AS high_school_employees
FROM HR_Database
WHERE education = 'High School';

-- Finding the total number of employees that work in the Sales department.
SELECT SUM(employee_count) AS sales_employees
FROM HR_Database
WHERE department = 'Sales';

-- Finding the total number of employees that are in the medical education field.
SELECT SUM(employee_count) AS employees_EF_Medical
FROM HR_Database
WHERE education_field = 'Medical';

-- Find the total number of attritions overall
SELECT COUNT(attrition) AS attrition_total
FROM HR_Database
WHERE attrition = 'Yes';

-- Find the total number of attritions from the R&D department
SELECT COUNT(attrition) AS attrition_R_and_D
FROM HR_Database
WHERE attrition = 'Yes' and department = 'R&D';

-- Find the total number of attritions within the R&D department that are in the Medical field
SELECT COUNT(attrition) AS attrition_R_and_D_Medical
FROM HR_Database
WHERE attrition = 'Yes' AND department = 'R&D' AND education_field = 'Medical';

-- Find the total number of attritions within the R&D department that are in the Medical field with a High School education
SELECT COUNT(attrition) AS attrition_R_and_D_Medical_HS
FROM HR_Database
WHERE attrition = 'Yes' AND department = 'R&D' AND education_field = 'Medical' AND education = 'High School';

-- Create a subquery to calculate the percentage between the number of attritions in total and how many employees there are overall
SELECT ROUND(((SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes') / SUM(employee_count)) * 100, 2) AS attrition_rate
FROM HR_Database;

-- Calculate the attrition rate within the Sales department
SELECT ROUND(((SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes') / SUM(employee_count)) * 100, 2) AS attrition_rate_Sales
FROM HR_Database
WHERE department = 'Sales';

-- Calculate the Sales attrition rate within the Sales department
SELECT ROUND(((SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes' AND department = 'Sales') / SUM(employee_count)) * 100, 2) AS attrition_rate_Sales
FROM HR_Database
WHERE department = 'Sales';

-- Calculate the total number of active employees
SELECT (SUM(employee_count) - (SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes')) AS active_employees_overall
FROM HR_Database;

-- Calculate the total number of active employees that are male
SELECT (SUM(employee_count) - (SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes' AND gender = 'Male')) AS active_employees_Male
FROM HR_Database
WHERE gender = 'Male';

-- Find the average age for employee attritions
SELECT ROUND(AVG(age), 0) AS avg_age_attritions
FROM HR_Database;

-- attrition by gender
SELECT gender, COUNT(attrition) AS attrition_count
FROM HR_Database
WHERE attrition = 'Yes'
GROUP BY gender
ORDER BY attrition_count DESC;

-- attrition by gender with employees having a High School education
SELECT gender, COUNT(attrition) AS attrition_count
FROM HR_Database
WHERE attrition = 'Yes' AND education = 'High School'
GROUP BY gender
ORDER BY attrition_count DESC;

-- Department-wise attrition: find the number of attritions for each department. As well as their rates.
SELECT department, COUNT(attrition) AS attrition_count,
ROUND((CAST(COUNT(attrition) AS numeric) / 
(SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes')) * 100, 2) AS attrition_rate_perc
FROM HR_Database
WHERE attrition = 'Yes'
GROUP BY department
ORDER BY attrition_count DESC;

-- Department-wise attrition by gender
SELECT gender, department, COUNT(attrition) AS attrition_count,
ROUND((CAST(COUNT(attrition) AS numeric) / 
(SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes')) * 100, 2) AS attrition_rate_perc
FROM HR_Database
WHERE attrition = 'Yes' AND gender = 'Male'
GROUP BY gender, department
ORDER BY attrition_count DESC;

-- No. of Employees by Age Group
SELECT age, SUM(employee_count) AS employee_count_by_age
FROM HR_Database
GROUP BY age
ORDER BY age;

-- No. of Employees by Age Group from Department
SELECT age, department, SUM(employee_count) AS employee_count_by_age
FROM HR_Database
WHERE department = 'Sales'
GROUP BY age, department
ORDER BY age;

-- Education Field-wise Attrition
SELECT education_field, COUNT(attrition) AS attrition_count
FROM HR_Database
WHERE attrition = 'Yes'
GROUP BY education_field
ORDER BY attrition_count DESC;

-- Education Field-wise Attrition by Department
SELECT department, education_field, COUNT(attrition) AS attrition_count
FROM HR_Database
WHERE attrition = 'Yes' AND department = 'Sales'
GROUP BY department, education_field
ORDER BY attrition_count DESC;

-- Attrition Rate by Gender for Different Age Groups
SELECT age_band, gender, COUNT(attrition) AS attrition_count, 
ROUND((CAST(COUNT(attrition) AS numeric) / 
(SELECT COUNT(attrition) FROM HR_Database WHERE attrition = 'Yes')) * 100, 2) AS attrition_rate_perc
FROM HR_Database
WHERE attrition = 'Yes'
GROUP BY age_band, gender
ORDER BY age_band, gender;

-- Job Satisfaction Ratings
SELECT job_role, [1], [2], [3], [4]
FROM (

SELECT job_role, job_satisfaction, employee_count
FROM HR_Database

) s

PIVOT (
  SUM(employee_count)
  FOR job_satisfaction IN (
  [1], [2], [3], [4])
) AS PivotTable
ORDER BY job_role;

-- Job Satisfaction Ratings by Education
SELECT job_role, [1], [2], [3], [4]
FROM (

SELECT job_role, job_satisfaction, employee_count
FROM HR_Database
WHERE education = 'Associates Degree'

) s

PIVOT (
  SUM(employee_count)
  FOR job_satisfaction IN (
  [1], [2], [3], [4])
) AS PivotTable
ORDER BY job_role;