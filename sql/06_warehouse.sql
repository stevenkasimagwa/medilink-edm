-- 06_warehouse.sql
-- Enterprise warehouse and analytical data model

CREATE TABLE IF NOT EXISTS marts.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year_num INTEGER,
    quarter_num INTEGER,
    month_num INTEGER,
    month_name VARCHAR(20),
    day_num INTEGER
);

CREATE TABLE IF NOT EXISTS marts.dim_patient (
    patient_sk UUID PRIMARY KEY,
    patient_id UUID NOT NULL,
    patient_number VARCHAR(50),
    full_name VARCHAR(255),
    age_band VARCHAR(50),
    city VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS marts.dim_provider (
    provider_sk UUID PRIMARY KEY,
    provider_id UUID NOT NULL,
    provider_name VARCHAR(255),
    specialty VARCHAR(150),
    facility_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS marts.fact_encounter (
    encounter_id UUID PRIMARY KEY,
    patient_sk UUID,
    provider_sk UUID,
    date_key INTEGER,
    facility_id UUID,
    diagnosis_code VARCHAR(50),
    total_charge NUMERIC(12,2),
    encounter_type VARCHAR(100)
);

CREATE VIEW marts.vw_patient_dashboard AS
SELECT
    p.patient_number,
    p.full_name,
    COUNT(f.encounter_id) AS total_visits,
    SUM(f.total_charge) AS total_cost
FROM marts.dim_patient p
LEFT JOIN marts.fact_encounter f ON p.patient_sk = f.patient_sk
GROUP BY p.patient_number, p.full_name;
