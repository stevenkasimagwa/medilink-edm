-- 00_database.sql
-- Medilink EDM foundation setup

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS curated;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS governance;
CREATE SCHEMA IF NOT EXISTS security;
CREATE SCHEMA IF NOT EXISTS metadata;

SET search_path TO public, raw, staging, curated, marts, governance, security, metadata;

CREATE TABLE IF NOT EXISTS metadata.datasource (
    datasource_id SERIAL PRIMARY KEY,
    source_name VARCHAR(255) NOT NULL,
    source_type VARCHAR(100) NOT NULL,
    owner_team VARCHAR(150),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS governance.data_steward (
    steward_id SERIAL PRIMARY KEY,
    steward_name VARCHAR(255) NOT NULL,
    team_name VARCHAR(150),
    email VARCHAR(255),
    access_level VARCHAR(100) DEFAULT 'standard'
);

COMMENT ON SCHEMA raw IS 'Raw ingested data from source systems';
COMMENT ON SCHEMA staging IS 'Validated and standardized staging model';
COMMENT ON SCHEMA curated IS 'Curated enterprise data domain records';
COMMENT ON SCHEMA marts IS 'Analytics-ready data marts';
COMMENT ON SCHEMA governance IS 'Governance tables and stewardship definitions';
COMMENT ON SCHEMA security IS 'Security, audit, and privacy controls';
COMMENT ON SCHEMA metadata IS 'Metadata and lineage tracking';
