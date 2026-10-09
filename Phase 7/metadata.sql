ALTER TABLE visits
    MODIFY diagnosis_code VARCHAR(10) COMMENT 'ICD-10 3-char code, e.g. A09 (diarrhoea)',
    MODIFY visit_type ENUM('OPD', 'ANC', 'IMMUNIZATION', 'ADMISSION', 'LAB') COMMENT 'OPD=outpatient, ANC=antenatal care';

CREATE TABLE glossary (
    term VARCHAR(60) PRIMARY KEY,
    definition VARCHAR(300),
    owner VARCHAR(100)
);

INSERT INTO glossary VALUES
('Golden Record', 'Single trusted version of a patient built by MDM survivorship', 'D. Nakato'),
('OPD Attendance', 'Count of visit rows with visit_type=OPD per period', 'Head of Clinical Services'),
('Revenue', 'SUM(fact_visits.total_amount); excludes cancelled visits', 'Finance Manager');

CREATE TABLE data_lineage (
    lineage_id INT AUTO_INCREMENT PRIMARY KEY,
    source_object VARCHAR(100),
    target_object VARCHAR(100),
    transformation VARCHAR(300)
);

INSERT INTO data_lineage VALUES
(NULL, 'stg_legacy_a + stg_legacy_b', 'm_patient', 'Normalize phone/name, match on phone, survivorship latest-wins'),
(NULL, 'visits + billing', 'fact_visits', 'Pivot billing amounts to columns, join dims');
