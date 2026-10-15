CREATE DATABASE hospital_analysis;
USE hospital_analysis;

CREATE TABLE admissions (name VARCHAR(100),age INT,gender VARCHAR(10),blood_type VARCHAR(5),medical_condition VARCHAR(50),date_of_admission DATE,doctor VARCHAR(100),hospital VARCHAR(150),insurance_provider VARCHAR(50),billing_amount  DECIMAL(12,2),room_number INT,admission_type VARCHAR(20),discharge_date DATE,medication VARCHAR(50),test_results VARCHAR(20),length_of_stay INT,admission_month VARCHAR(15),admission_weekday VARCHAR(15),age_group VARCHAR(10));


SELECT COUNT(*) FROM admissions;        
SELECT * FROM admissions LIMIT 10;

#Admissions by medical condition
SELECT medical_condition, COUNT(*) AS total_admissions FROM admissions GROUP BY medical_condition ORDER BY total_admissions DESC;

#Average length of stay and bill by admission type
select  admission_type,ROUND(AVG(length_of_stay), 1) AS avg_los,ROUND(AVG(billing_amount), 2) AS avg_bill FROM admissions GROUP BY admission_type;

#Monthly trend with change from the previous month
WITH monthly AS (
    SELECT DATE_FORMAT(date_of_admission, '%Y-%m') AS month,
           COUNT(*) AS admissions
    FROM admissions
    GROUP BY month
)
SELECT month, admissions,
       admissions - LAG(admissions) OVER (ORDER BY month) AS change_from_prev
FROM monthly
ORDER BY month;

#Total billing by insurance provider
SELECT insurance_provider,
       COUNT(*) AS patients,
       ROUND(SUM(billing_amount), 2) AS total_billing
FROM admissions
GROUP BY insurance_provider
ORDER BY total_billing DESC;

#Top 3 costliest conditions per insurance provider
SELECT * FROM (
    SELECT insurance_provider, medical_condition,
           ROUND(SUM(billing_amount), 2) AS total_billing,
           RANK() OVER (PARTITION BY insurance_provider
                        ORDER BY SUM(billing_amount) DESC) AS rnk
    FROM admissions
    GROUP BY insurance_provider, medical_condition
) t
WHERE rnk <= 3;

#Age group analysis
SELECT age_group, gender, COUNT(*) AS admissions,
       ROUND(AVG(length_of_stay), 1) AS avg_los
FROM admissions
GROUP BY age_group, gender
ORDER BY age_group;

#Readmissions (the same patient name appearing more than once)
SELECT COUNT(*) AS patients_readmitted
FROM (
    SELECT name FROM admissions
    GROUP BY name
    HAVING COUNT(*) > 1
) t;