-- 05_mdm.sql
-- Master data management and match logic

CREATE TABLE IF NOT EXISTS curated.golden_record (
    golden_record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_record_id VARCHAR(255),
    entity_type VARCHAR(100) NOT NULL,
    canonical_value VARCHAR(255),
    match_confidence NUMERIC(5,2),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS curated.record_match (
    match_id SERIAL PRIMARY KEY,
    left_record_id VARCHAR(255) NOT NULL,
    right_record_id VARCHAR(255) NOT NULL,
    match_score NUMERIC(5,2) NOT NULL,
    match_type VARCHAR(100),
    matched_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS curated.survivorship_rule (
    rule_id SERIAL PRIMARY KEY,
    entity_type VARCHAR(100) NOT NULL,
    field_name VARCHAR(150) NOT NULL,
    priority_order INTEGER NOT NULL,
    rule_expression TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO curated.survivorship_rule (entity_type, field_name, priority_order, rule_expression)
VALUES
    ('patient', 'first_name', 1, 'prefer most recent non-null value'),
    ('patient', 'dob', 1, 'prefer source with highest completeness'),
    ('patient', 'email', 2, 'prefer value from master hospital system');
