-- 03_schema.sql
-- Curated enterprise schema for clinical data

CREATE TABLE IF NOT EXISTS curated.patient_master (
    patient_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_number VARCHAR(50) UNIQUE,
    first_name VARCHAR(120),
    last_name VARCHAR(120),
    dob DATE,
    sex VARCHAR(20),
    primary_phone VARCHAR(50),
    email VARCHAR(255),
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    state_code VARCHAR(20),
    postal_code VARCHAR(20),
    source_system VARCHAR(100),
    active_flag BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS curated.provider_master (
    provider_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_number VARCHAR(50) UNIQUE,
    provider_name VARCHAR(255) NOT NULL,
    specialty VARCHAR(150),
    facility_id UUID,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS curated.facility_master (
    facility_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_code VARCHAR(50) UNIQUE,
    facility_name VARCHAR(255) NOT NULL,
    region VARCHAR(100),
    city VARCHAR(100),
    state_code VARCHAR(20),
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6)
);

CREATE TABLE IF NOT EXISTS curated.encounter_fact (
    encounter_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES curated.patient_master(patient_id),
    provider_id UUID REFERENCES curated.provider_master(provider_id),
    facility_id UUID REFERENCES curated.facility_master(facility_id),
    encounter_type VARCHAR(100),
    encounter_date TIMESTAMP,
    diagnosis_code VARCHAR(50),
    diagnosis_description TEXT,
    total_charge NUMERIC(12,2),
    discharge_status VARCHAR(100)
);
