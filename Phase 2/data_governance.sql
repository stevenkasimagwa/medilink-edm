CREATE TABLE data_ownership (
    object_name VARCHAR(64) PRIMARY KEY,
    data_owner VARCHAR(100),
    data_steward VARCHAR(100),
    custodian VARCHAR(100)
);

INSERT INTO data_ownership VALUES
('m_patient', 'Medical Director', 'Ahairwe Apophia (Steward)', 'Steven (IT Custodian)'),
('billing', 'Finance Manager', 'Balaba M. Charles (Steward)', 'Steven (IT Custodian)');

CREATE TABLE raci (
    activity VARCHAR(60) PRIMARY KEY,
    cdo ENUM('R', 'A', 'C', 'I', 'T'),
    steward ENUM('R', 'A', 'C', 'I', 'T', 'A/R'),
    custodian ENUM('R', 'A', 'C', 'I', 'T','A/R'),
    clinician ENUM('R', 'A', 'C', 'I', 'T')
);

INSERT INTO raci VALUES
('Approve new source system', 'A', 'R', 'C', 'I'),
('Resolve duplicate patient', 'T', 'A/R', 'C', 'C'),
('Grant data access', 'T', 'C', 'A/R', 'T');

CREATE TABLE policies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    rule_summary VARCHAR(300),
    enforcement ENUM('MANUAL', 'TECHNICAL') NOT NULL
);

INSERT INTO policies VALUES
(NULL, 'Patient Identity Policy', 'One golden record per patient; steward reviews identity merges', 'TECHNICAL'),
(NULL, 'Access Control Policy', 'Least privilege by role; PII masked outside clinical use', 'TECHNICAL'),
(NULL, 'Retention Policy', 'Per data_lifecycle_policy table', 'TECHNICAL');

CREATE TABLE compliance_register (
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    requirement VARCHAR(200),
    current_state VARCHAR(200),
    gap ENUM('CLOSED', 'PARTIAL', 'OPEN'),
    remediation VARCHAR(200)
);

INSERT INTO compliance_register VALUES
(NULL, 'National ID not stored in plain text', 'Plaintext in Legacy A', 'OPEN', 'Hash at ingestion (Phase 8)'),
(NULL, 'Breach notification within 72h', 'No procedure', 'OPEN', 'Breach playbook (Phase 8)');