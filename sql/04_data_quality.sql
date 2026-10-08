-- 04_data_quality.sql
-- Data quality rules and monitoring framework

CREATE TABLE IF NOT EXISTS governance.data_quality_rule (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(255) NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    rule_type VARCHAR(100) NOT NULL,
    expression TEXT NOT NULL,
    severity VARCHAR(50) DEFAULT 'warning',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS governance.data_quality_result (
    result_id SERIAL PRIMARY KEY,
    rule_id INTEGER REFERENCES governance.data_quality_rule(rule_id),
    entity_name VARCHAR(255) NOT NULL,
    record_count INTEGER DEFAULT 0,
    exception_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'passed',
    run_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS governance.data_quality_exception (
    exception_id SERIAL PRIMARY KEY,
    rule_id INTEGER REFERENCES governance.data_quality_rule(rule_id),
    record_key VARCHAR(255),
    exception_reason TEXT,
    accepted_by VARCHAR(150),
    accepted_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_resolved BOOLEAN DEFAULT FALSE
);

INSERT INTO governance.data_quality_rule (rule_name, entity_name, rule_type, expression, severity)
VALUES
    ('patient_id_not_null', 'patient_master', 'not_null', 'patient_id IS NOT NULL', 'critical'),
    ('dob_valid_format', 'patient_master', 'data_format', 'dob IS NOT NULL', 'medium'),
    ('diagnosis_required', 'encounter_fact', 'not_null', 'diagnosis_code IS NOT NULL', 'high');
