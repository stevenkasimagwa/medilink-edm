-- 08_security.sql
-- Security, privacy and access controls

CREATE TABLE IF NOT EXISTS security.data_classification (
    classification_id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    column_name VARCHAR(255),
    sensitivity_level VARCHAR(50) NOT NULL,
    pii_flag BOOLEAN DEFAULT FALSE,
    masking_required BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS security.access_policy (
    policy_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    schema_name VARCHAR(100),
    table_name VARCHAR(255),
    allowed_operation VARCHAR(50) DEFAULT 'read',
    notes TEXT
);

CREATE TABLE IF NOT EXISTS security.audit_log (
    audit_id SERIAL PRIMARY KEY,
    user_name VARCHAR(150) NOT NULL,
    action_name VARCHAR(150) NOT NULL,
    object_name VARCHAR(255),
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    result VARCHAR(50) DEFAULT 'success'
);

INSERT INTO security.data_classification (table_name, column_name, sensitivity_level, pii_flag, masking_required)
VALUES
    ('patient_master', 'first_name', 'confidential', TRUE, TRUE),
    ('patient_master', 'dob', 'confidential', TRUE, TRUE),
    ('encounter_fact', 'diagnosis_description', 'restricted', FALSE, FALSE);
