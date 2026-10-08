-- 02_governance.sql
-- Governance layer and stewardship policies

CREATE TABLE IF NOT EXISTS governance.policy (
    policy_id SERIAL PRIMARY KEY,
    policy_name VARCHAR(255) NOT NULL,
    domain VARCHAR(150) NOT NULL,
    policy_status VARCHAR(50) DEFAULT 'draft',
    description TEXT,
    review_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS governance.stewardship_assignment (
    assignment_id SERIAL PRIMARY KEY,
    steward_id INTEGER REFERENCES governance.data_steward(steward_id),
    domain VARCHAR(150) NOT NULL,
    subject_area VARCHAR(200),
    role_name VARCHAR(100) NOT NULL,
    assigned_on DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS governance.data_issue (
    issue_id SERIAL PRIMARY KEY,
    issue_code VARCHAR(100) NOT NULL,
    issue_title VARCHAR(255) NOT NULL,
    severity VARCHAR(50),
    affected_entity VARCHAR(255),
    issue_status VARCHAR(50) DEFAULT 'open',
    raised_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO governance.policy (policy_name, domain, policy_status, description, review_date)
VALUES
    ('Patient Master Ownership', 'patient', 'active', 'Defines stewardship and accountability for patient master data.', '2026-12-31'),
    ('Clinical Data Retention', 'clinical', 'active', 'Defines retention, archival and legal hold policy for healthcare data.', '2026-12-31'),
    ('PII Handling Standard', 'security', 'active', 'Defines how personal identifiers are protected and accessed.', '2026-06-30');
