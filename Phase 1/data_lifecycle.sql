CREATE TABLE data_lifecycle_policy (
    data_class VARCHAR(50) PRIMARY KEY,
    retention_years INT NOT NULL,
    archive_after_years INT NOT NULL,
    lawful_basis VARCHAR(100),
    owner VARCHAR(100)
);

INSERT INTO data_lifecycle_policy VALUES
('CLINICAL', 10, 7, 'Provision of health care (DPA s.7)', 'Head of Clinical Services'),
('BILLING', 7, 5, 'Legal obligation', 'Finance Manager'),
('MARKETING_CONSENT', 2, 1, 'Consent', 'Data Steward');