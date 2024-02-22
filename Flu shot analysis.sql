
-- Section 1: Annual Flu Shot Statistics by Demographics
-- Patients by Age, Race, and County (2022):
SELECT age, race, county, COUNT(*) AS patient_count
FROM patients
WHERE flu_shot_2022 = 1
GROUP BY age, race, county
ORDER BY age, race, county;

-- Percentage Analysis of Flu Shots
-- Stratified Patient Percentage (2022):
SELECT age, race, county, 
       ROUND((COUNT(*) FILTER (WHERE flu_shot_2022 = 1)::decimal / COUNT(*)) * 100, 2) AS flu_shot_percentage
FROM patients
GROUP BY age, race, county
ORDER BY age, race, county;

-- Overall Hospital/Clinic Percentage (2022):
SELECT ROUND((COUNT(*) FILTER (WHERE flu_shot_2022 = 1)::decimal / COUNT(*)) * 100, 2) AS overall_percentage
FROM patients;

-- Monthly Cumulative Flu Shot Data
-- Monthly Administration (2022):
SELECT EXTRACT(MONTH FROM earliest_flu_shot_2022) AS month, COUNT(*) AS flu_shots_administered
FROM patients
WHERE flu_shot_2022 = 1
AND EXTRACT(YEAR FROM earliest_flu_shot_2022) = 2022
GROUP BY month
ORDER BY month;

-- Total Annual Flu Shots
-- Annual Total (2022):
SELECT COUNT(*) AS total_flu_shots_2022
FROM patients
WHERE flu_shot_2022 = 1;

-- Patient Lists for Flu Shot Analysis
-- List of Vaccinated Patients (2022):
SELECT id, first, last, age, race, ethnicity, gender, county, zip
FROM patients
WHERE flu_shot_2022 = 1
ORDER BY last, first;

-- List of Unvaccinated Patients (2022):
SELECT id, first, last, age, race, ethnicity, gender, county, zip
FROM patients
WHERE flu_shot_2022 = 0
ORDER BY last, first;

-- Additional Analysis Questions
-- Patient Demographics Analysis:
SELECT CASE
         WHEN age <= 18 THEN '0-18'
         WHEN age BETWEEN 19 AND 35 THEN '19-35'
         WHEN age BETWEEN 36 AND 60 THEN '36-60'
         ELSE '60+'
       END AS age_group,
       COUNT(*) AS patient_count
FROM patients
GROUP BY age_group
ORDER BY age_group;

-- Geographical Distribution:
SELECT county, COUNT(*) AS patient_count
FROM patients
GROUP BY county
ORDER BY patient_count DESC
LIMIT 5;

-- Healthcare Utilization Patterns:
SELECT AVG(encounter_count) AS average_encounters_per_patient
FROM (
  SELECT patient_id, COUNT(*) AS encounter_count
  FROM encounters
  GROUP BY patient_id
) AS patient_encounters;

-- Condition Prevalence:
SELECT condition_name, COUNT(*) AS prevalence
FROM conditions
GROUP BY condition_name
ORDER BY prevalence DESC
LIMIT 10;

-- Healthcare Costs Analysis:
SELECT AVG(expense_amount) AS average_healthcare_expense_per_patient
FROM expenses;

-- Encounter Analysis:
SELECT encounter_class, COUNT(*) AS encounter_count
FROM encounters
GROUP BY encounter_class
ORDER BY encounter_count DESC
LIMIT 1;

-- Income vs. Healthcare Coverage:
SELECT CORR(income, healthcare_coverage) AS income_coverage_correlation
FROM financial_data;

-- Immunization Records:
SELECT immunization_type, COUNT(*) AS patient_count
FROM immunizations
GROUP BY immunization_type;

-- Patient Mortality:
SELECT gender, race, AVG(age_at_death) AS average_age_at_death
FROM patients
WHERE date_of_death IS NOT NULL
GROUP BY gender, race;

-- Provider Workload:
SELECT provider_id, COUNT(*) AS encounter_count
FROM encounters
GROUP BY provider_id
ORDER BY encounter_count DESC
LIMIT 1;

-- Encounter Costs Analysis:
SELECT encounter_class, AVG(total_claim_cost) AS average_claim_cost, AVG(payer_coverage) AS average_payer_coverage
FROM encounters
GROUP BY encounter_class;

-- Marital Status and Health:
SELECT marital_status, AVG(encounter_count) AS average_encounters
FROM (
  SELECT patient_id, marital_status, COUNT(*) AS encounter_count
  FROM encounters
  JOIN patients ON encounters.patient_id = patients.id
  GROUP BY patient_id, marital_status
) AS patient_encounters
GROUP BY marital_status;

-- Race and Ethnicity in Healthcare:
SELECT race, ethnicity, AVG(expense_amount) AS average_expense
FROM expenses
JOIN patients ON expenses.patient_id = patients.id
GROUP BY race, ethnicity;

-- Chronic Condition Management
SELECT patients.id, patients.first, patients.last, COUNT(encounters.id) AS encounter_count
FROM patients
JOIN conditions ON patients.id = conditions.patient_id
JOIN encounters ON patients.id = encounters.patient_id
WHERE conditions.duration > '1 year' -- Assuming `duration` can directly indicate this, or a similar logic applies
GROUP BY patients.id
ORDER BY encounter_count DESC
LIMIT 10;

-- Patient Coverage Gaps
SELECT patients.id, patients.first, patients.last, SUM(expenses.total_claim_cost) AS total_expenses, SUM(expenses.payer_coverage) AS total_coverage, (SUM(expenses.total_claim_cost) - SUM(expenses.payer_coverage)) AS coverage_gap
FROM patients
JOIN expenses ON patients.id = expenses.patient_id
GROUP BY patients.id
HAVING total_expenses > 10000 AND (SUM(expenses.total_claim_cost) - SUM(expenses.payer_coverage)) > 5000
ORDER BY coverage_gap DESC;




