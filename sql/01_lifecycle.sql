-- 01_lifecycle.sql
-- Data lifecycle and control metadata

CREATE TABLE IF NOT EXISTS metadata.data_lifecycle (
    lifecycle_id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    schema_name VARCHAR(100) NOT NULL,
    lifecycle_stage VARCHAR(100) NOT NULL,
    retention_days INTEGER,
    archival_required BOOLEAN DEFAULT FALSE,
    purge_policy TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS metadata.lineage (
    lineage_id SERIAL PRIMARY KEY,
    source_table VARCHAR(255) NOT NULL,
    target_table VARCHAR(255) NOT NULL,
    transformation_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS metadata.data_quality_score (
    score_id SERIAL PRIMARY KEY,
    entity_name VARCHAR(255) NOT NULL,
    score_percentage NUMERIC(5,2),
    assessment_date DATE DEFAULT CURRENT_DATE,
    notes TEXT
);

INSERT INTO metadata.data_lifecycle (table_name, schema_name, lifecycle_stage, retention_days, archival_required, purge_policy)
VALUES
    ('patient_master', 'curated', 'active', 2555, TRUE, 'Archive after 7 years; purge after legal hold release'),
    ('encounter_fact', 'marts', 'active', 1825, TRUE, 'Archive after 5 years'),
    ('source_patient_raw', 'raw', 'staging', 365, FALSE, 'Retain for operational debugging');
