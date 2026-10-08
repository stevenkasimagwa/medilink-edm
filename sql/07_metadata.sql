-- 07_metadata.sql
-- Metadata catalog and mapping definitions

CREATE TABLE IF NOT EXISTS metadata.business_term (
    term_id SERIAL PRIMARY KEY,
    term_name VARCHAR(255) NOT NULL,
    description TEXT,
    domain VARCHAR(150),
    owner VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS metadata.asset_catalog (
    asset_id SERIAL PRIMARY KEY,
    asset_name VARCHAR(255) NOT NULL,
    asset_type VARCHAR(100) NOT NULL,
    schema_name VARCHAR(100),
    owner_team VARCHAR(150),
    criticality VARCHAR(50) DEFAULT 'standard'
);

CREATE TABLE IF NOT EXISTS metadata.column_mapping (
    mapping_id SERIAL PRIMARY KEY,
    source_column VARCHAR(255) NOT NULL,
    target_column VARCHAR(255) NOT NULL,
    transformation_rule TEXT,
    source_system VARCHAR(100)
);

INSERT INTO metadata.business_term (term_name, description, domain, owner)
VALUES
    ('Patient ID', 'Unique patient identification across systems', 'identity', 'Data Governance'),
    ('Encounter Date', 'Date of clinical encounter', 'clinical', 'Clinical Data Steward'),
    ('Diagnosis Code', 'Standardized diagnosis reference code', 'clinical', 'Clinical Coding Lead');
