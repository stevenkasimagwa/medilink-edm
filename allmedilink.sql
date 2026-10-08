-- ============================================================================
-- MEDILINK HEALTH NETWORK ENTERPRISE DATA PLATFORM (COMPLETE SCRIPT)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PHASE 0 & 1: SETUP & LIFECYCLE POLICIES
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS `medilink`;
CREATE DATABASE IF NOT EXISTS medilink CHARACTER SET utf8mb4;
USE medilink;

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

-- ----------------------------------------------------------------------------
-- PHASE 2: GOVERNANCE FRAMEWORK REGISTERS
-- ----------------------------------------------------------------------------
CREATE TABLE data_ownership (
    object_name VARCHAR(64) PRIMARY KEY,
    data_owner VARCHAR(100),
    data_steward VARCHAR(100),
    custodian VARCHAR(100)
);

INSERT INTO data_ownership VALUES
('m_patient', 'Medical Director', 'D. Nakato (Steward)', 'IT Custodian'),
('billing', 'Finance Manager', 'J. Okello (Steward)', 'IT Custodian');

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

-- ----------------------------------------------------------------------------
-- PHASE 3: ARCHITECTURE & OPERATIONAL SCHEMA
-- ----------------------------------------------------------------------------
CREATE TABLE clinics (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_code VARCHAR(10) UNIQUE,
    clinic_name VARCHAR(100),
    district VARCHAR(60)
);

INSERT INTO clinics VALUES
(NULL, 'MP-KLA', 'MediLink Kampala', 'Kampala'),
(NULL, 'MP-MUK', 'MediLink Mukono', 'Mukono'),
(NULL, 'MP-MBR', 'MediLink Mbarara', 'Mbarara'),
(NULL, 'MP-GUL', 'MediLink Gulu', 'Gulu');

CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    role ENUM('DOCTOR', 'NURSE', 'LAB', 'PHARMACIST', 'ADMIN'),
    clinic_id INT,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
);

CREATE TABLE m_patient (
    patient_key INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(13),
    email VARCHAR(120),
    sex ENUM('M', 'F'),
    date_of_birth DATE,
    national_id_hash CHAR(64),
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'),
    home_district VARCHAR(60),
    status ENUM('ACTIVE', 'ARCHIVED') DEFAULT 'ACTIVE',
    source_count TINYINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_phone CHECK (phone REGEXP '^256[0-9]{9}$')
);

CREATE TABLE patient_source_links (
    link_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_key INT NOT NULL,
    source_system ENUM('LEGACY_A', 'LEGACY_B', 'PHARMACY_POS', 'PAPER_SCAN') NOT NULL,
    source_record_id VARCHAR(50) NOT NULL,
    matched_on VARCHAR(30),
    confidence DECIMAL(4, 3),
    UNIQUE (source_system, source_record_id),
    FOREIGN KEY (patient_key) REFERENCES m_patient(patient_key)
);

CREATE TABLE visits (
    visit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_key INT NOT NULL,
    clinic_id INT NOT NULL,
    staff_id INT,
    visit_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    visit_type ENUM('OPD', 'ANC', 'IMMUNIZATION', 'ADMISSION', 'LAB') NOT NULL,
    diagnosis_code VARCHAR(10),
    diagnosis_note VARCHAR(200),
    status ENUM('ACTIVE', 'ARCHIVED') DEFAULT 'ACTIVE',
    FOREIGN KEY (patient_key) REFERENCES m_patient(patient_key),
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE billing (
    bill_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    service ENUM('CONSULTATION', 'LAB', 'MEDICATION', 'ADMISSION', 'PROCEDURE'),
    amount DECIMAL(12, 2) CHECK (amount >= 0),
    payment_mode ENUM('CASH', 'MOBILE_MONEY', 'INSURANCE'),
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- ----------------------------------------------------------------------------
-- PHASE 4: STAGING & DATA QUALITY CLEANSING
-- ----------------------------------------------------------------------------
CREATE TABLE stg_legacy_a (
    src_id INT PRIMARY KEY,
    pname VARCHAR(120),
    phone_no VARCHAR(25),
    gender VARCHAR(10),
    dob_raw VARCHAR(25),
    nid VARCHAR(25),
    last_visit DATE
);

INSERT INTO stg_legacy_a VALUES
(1, 'nakato sarah', '0772 100 001', 'F', '1990-05-12', 'CM90123456ABC', '2024-11-02'),
(2, 'NAKATO SARAH', '256772100001', 'Female', '12/05/1990', '', '2025-01-15'),
(3, 'Okello John ', '+256772100002', 'M', '1985-3-3', 'CM85112233', '2024-12-20'),
(4, 'acheb gloria', '0771003003', 'f', '', '', '2025-02-01'),
(5, 'Mwesigwa D', '0782 455 901', 'male', '1978/09/22', 'CM78998877', '2024-10-30'),
(6, 'Unknown Child', '0', 'M', '', '', '2025-02-03');

CREATE TABLE stg_legacy_b (
    src_id INT PRIMARY KEY,
    name VARCHAR(120),
    phone VARCHAR(25),
    email VARCHAR(120),
    sex VARCHAR(10),
    dob DATE,
    updated_at DATE
);

INSERT INTO stg_legacy_b VALUES
(101, 'Sarah Nakato', '256772100001', 's.nakato@gmail.com', 'F', '1990-05-12', '2025-03-01'),
(102, 'J. Okello', '0772100002', 'okello.j@outlook.com', 'M', '1985-03-03', '2025-02-10'),
(103, 'Gloria Acheb', '256771003003', NULL, 'F', NULL, '2025-01-20');

ALTER TABLE stg_legacy_a
    ADD COLUMN name_clean VARCHAR(120),
    ADD COLUMN phone_norm VARCHAR(13),
    ADD COLUMN sex_clean ENUM('M', 'F'),
    ADD COLUMN dob_clean DATE;

SET SQL_SAFE_UPDATES = 0;
UPDATE stg_legacy_a
SET name_clean = CONCAT(UPPER(SUBSTRING(TRIM(pname), 1, 1)), LOWER(SUBSTRING(TRIM(pname), 2)));

UPDATE stg_legacy_a
SET phone_norm = CASE
    WHEN REGEXP_REPLACE(phone_no, '[^0-9]', '') LIKE '256%' 
         AND LENGTH(REGEXP_REPLACE(phone_no, '[^0-9]', '')) = 12
    THEN REGEXP_REPLACE(phone_no, '[^0-9]', '')
    WHEN LENGTH(REGEXP_REPLACE(phone_no, '[^0-9]', '')) = 10
    THEN CONCAT('256', SUBSTRING(REGEXP_REPLACE(phone_no, '[^0-9]', ''), 2))
    ELSE NULL
END;

UPDATE stg_legacy_a 
SET sex_clean = CASE UPPER(TRIM(gender))
    WHEN 'M' THEN 'M' 
    WHEN 'MALE' THEN 'M' 
    WHEN 'F' THEN 'F' 
    WHEN 'FEMALE' THEN 'F' 
END;

UPDATE stg_legacy_a 
SET dob_clean = STR_TO_DATE(dob_raw, '%Y-%m-%d') 
WHERE dob_raw REGEXP '^[0-9]{4}-';

UPDATE stg_legacy_a 
SET dob_clean = STR_TO_DATE(dob_raw, '%d/%m/%Y')
WHERE dob_clean IS NULL AND dob_raw REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

CREATE VIEW v_dq_scorecard AS
SELECT
    ROUND(100 * SUM(phone IS NOT NULL) / COUNT(*), 1) AS phone_complete_pct,
    ROUND(100 * SUM(date_of_birth IS NOT NULL) / COUNT(*), 1) AS dob_complete_pct,
    ROUND(100 * SUM(sex IS NOT NULL) / COUNT(*), 1) AS sex_complete_pct,
    COUNT(*) AS total_records,
    COUNT(DISTINCT CONCAT(full_name, IFNULL(phone, 'x'))) AS potential_dupes
FROM m_patient;

-- ----------------------------------------------------------------------------
-- PHASE 5: MASTER DATA MANAGEMENT (MDM)
-- ----------------------------------------------------------------------------
ALTER TABLE stg_legacy_b 
    ADD COLUMN phone_norm VARCHAR(13), 
    ADD COLUMN name_clean VARCHAR(120);

UPDATE stg_legacy_b
SET phone_norm = CONCAT('256', SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ''), -9)),
    name_clean = CONCAT(UPPER(SUBSTRING(TRIM(name), 1, 1)), LOWER(SUBSTRING(TRIM(name), 2)));

CREATE VIEW v_all_sources AS
SELECT 'LEGACY_A' AS src_system, src_id, phone_norm, name_clean, sex_clean AS sex, dob_clean AS dob, NULL AS email, last_visit AS updated_at
FROM stg_legacy_a WHERE phone_norm IS NOT NULL
UNION ALL
SELECT 'LEGACY_B' AS src_system, src_id, phone_norm, name_clean, NULL AS sex, dob, email, updated_at
FROM stg_legacy_b WHERE phone_norm IS NOT NULL;

INSERT INTO m_patient (full_name, phone, sex, date_of_birth, email, source_count)
WITH ranked AS (
    SELECT s.*,
           ROW_NUMBER() OVER (PARTITION BY phone_norm ORDER BY updated_at DESC) AS rn,
           COUNT(*) OVER (PARTITION BY phone_norm) AS n_src
    FROM v_all_sources s
)
SELECT name_clean, phone_norm, sex, dob, email, n_src
FROM ranked 
WHERE rn = 1;

INSERT INTO patient_source_links (patient_key, source_system, source_record_id, matched_on, confidence)
SELECT m.patient_key, s.src_system, s.src_id, 'PHONE', 0.950
FROM v_all_sources s 
JOIN m_patient m ON m.phone = s.phone_norm;

CREATE TABLE mdm_review_queue (
    queue_id INT AUTO_INCREMENT PRIMARY KEY,
    src_system VARCHAR(20),
    src_id INT,
    reason VARCHAR(60),
    raised_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_by VARCHAR(60) NULL,
    resolved_at DATETIME NULL
);

INSERT INTO mdm_review_queue (src_system, src_id, reason)
SELECT 'LEGACY_A', src_id, 'NO_PHONE_CANNOT_MATCH' 
FROM stg_legacy_a
WHERE phone_norm IS NULL;

-- ----------------------------------------------------------------------------
-- PHASE 6: DATA WAREHOUSE & ETL
-- ----------------------------------------------------------------------------
CREATE TABLE dim_clinic (
    clinic_sk INT AUTO_INCREMENT PRIMARY KEY,
    clinic_id INT UNIQUE,
    clinic_code VARCHAR(10),
    clinic_name VARCHAR(100),
    district VARCHAR(60)
);

INSERT INTO dim_clinic (clinic_id, clinic_code, clinic_name, district)
SELECT clinic_id, clinic_code, clinic_name, district FROM clinics;

CREATE TABLE dim_patient (
    patient_sk INT AUTO_INCREMENT PRIMARY KEY,
    patient_key INT UNIQUE,
    full_name VARCHAR(120),
    sex CHAR(1),
    age_band VARCHAR(10),
    home_district VARCHAR(60)
);

INSERT INTO dim_patient (patient_key, full_name, sex, age_band, home_district)
SELECT patient_key, full_name, sex,
    CASE 
        WHEN date_of_birth IS NULL THEN 'UNKNOWN'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 5 THEN '0-4'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18 THEN '5-17'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 60 THEN '18-59'
        ELSE '60+' 
    END,
    home_district
FROM m_patient 
WHERE status = 'ACTIVE';

CREATE TABLE dim_date (
    d DATE PRIMARY KEY,
    yr SMALLINT,
    qtr TINYINT,
    mo TINYINT,
    mo_name VARCHAR(12),
    dow VARCHAR(10)
);

DELIMITER //
CREATE PROCEDURE fill_dim_date(IN start_d DATE, IN days INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < days DO
        INSERT IGNORE INTO dim_date
        SELECT 
            DATE_ADD(start_d, INTERVAL i DAY),
            YEAR(DATE_ADD(start_d, INTERVAL i DAY)),
            QUARTER(DATE_ADD(start_d, INTERVAL i DAY)),
            MONTH(DATE_ADD(start_d, INTERVAL i DAY)),
            MONTHNAME(DATE_ADD(start_d, INTERVAL i DAY)),
            DAYNAME(DATE_ADD(start_d, INTERVAL i DAY));
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL fill_dim_date('2024-01-01', 800);

CREATE TABLE fact_visits (
    visit_sk BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_date DATE NOT NULL,
    clinic_sk INT NOT NULL,
    patient_sk INT NOT NULL,
    visit_type VARCHAR(20),
    diagnosis_code VARCHAR(10),
    consult_amount DECIMAL(10, 2),
    lab_amount DECIMAL(10, 2),
    med_amount DECIMAL(10, 2),
    total_amount DECIMAL(10, 2),
    KEY idx_fv_date (visit_date),
    KEY idx_fv_clinic (clinic_sk)
);

INSERT INTO fact_visits (
    visit_date, clinic_sk, patient_sk, visit_type, diagnosis_code,
    consult_amount, lab_amount, med_amount, total_amount
)
SELECT 
    DATE(v.visit_date), 
    dc.clinic_sk, 
    dp.patient_sk, 
    v.visit_type, 
    v.diagnosis_code,
    COALESCE(SUM(CASE WHEN b.service = 'CONSULTATION' THEN b.amount END), 0),
    COALESCE(SUM(CASE WHEN b.service = 'LAB' THEN b.amount END), 0),
    COALESCE(SUM(CASE WHEN b.service = 'MEDICATION' THEN b.amount END), 0),
    COALESCE(SUM(b.amount), 0)
FROM visits v
JOIN dim_clinic dc ON dc.clinic_id = v.clinic_id
JOIN dim_patient dp ON dp.patient_key = v.patient_key
LEFT JOIN billing b ON b.visit_id = v.visit_id
GROUP BY v.visit_id, DATE(v.visit_date), dc.clinic_sk, dp.patient_sk, v.visit_type, v.diagnosis_code;

-- ----------------------------------------------------------------------------
-- PHASE 7: METADATA MANAGEMENT
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- PHASE 8: SECURITY, PRIVACY & TRIGGERS
-- ----------------------------------------------------------------------------
CREATE TABLE data_classification (
    object_name VARCHAR(64) PRIMARY KEY,
    level ENUM('PUBLIC', 'INTERNAL', 'CONFIDENTIAL', 'RESTRICTED')
);

INSERT INTO data_classification VALUES
('m_patient', 'RESTRICTED'), 
('visits', 'RESTRICTED'),
('fact_visits', 'CONFIDENTIAL'), 
('dim_clinic', 'INTERNAL');

ALTER TABLE m_patient ADD COLUMN nid_sha CHAR(64);

UPDATE m_patient m
JOIN patient_source_links l ON l.patient_key = m.patient_key AND l.source_system = 'LEGACY_A'
JOIN stg_legacy_a a ON a.src_id = l.source_record_id
SET m.nid_sha = SHA2(a.nid, 256)
WHERE a.nid IS NOT NULL AND a.nid <> '';

CREATE VIEW v_patient_directory AS
SELECT 
    patient_key,
    CONCAT(LEFT(full_name, 1), '***') AS name_masked,
    CONCAT('256***', RIGHT(phone, 3)) AS phone_masked,
    sex, 
    home_district
FROM m_patient 
WHERE status = 'ACTIVE';

CREATE ROLE IF NOT EXISTS 'ml_reception', 'ml_clinician', 'ml_analyst', 'ml_auditor';

GRANT SELECT ON medilink.v_patient_directory TO 'ml_reception';
GRANT SELECT, INSERT, UPDATE ON medilink.m_patient TO 'ml_clinician';
GRANT SELECT ON medilink.fact_visits TO 'ml_analyst';
GRANT SELECT ON medilink.* TO 'ml_auditor';

CREATE USER IF NOT EXISTS 'agnes'@'%' IDENTIFIED BY 'StrongPass1!';
GRANT 'ml_reception' TO 'agnes'@'%';
SET DEFAULT ROLE ALL TO 'agnes'@'%';

DELIMITER //
CREATE TRIGGER trg_billing_immutable
BEFORE UPDATE ON billing FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Billing rows are immutable. Insert an adjustment row instead.';
END //
DELIMITER ;

CREATE TABLE master_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_key INT,
    changed_by VARCHAR(64),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    detail VARCHAR(400)
);

DELIMITER //
CREATE TRIGGER trg_master_audit
AFTER UPDATE ON m_patient FOR EACH ROW
BEGIN
    INSERT INTO master_audit (patient_key, changed_by, detail)
    VALUES (
        NEW.patient_key, 
        CURRENT_USER(),
        CONCAT('phone:', IFNULL(OLD.phone, '-'), '->', IFNULL(NEW.phone, '-'),
               ' name:', IFNULL(OLD.full_name, '-'), '->', IFNULL(NEW.full_name, '-'))
    );
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- PHASE 10: AUTOMATION & EVENT SCHEDULING
-- ----------------------------------------------------------------------------
SET GLOBAL event_scheduler = ON;

CREATE TABLE dq_scorecard_log (
    run_date DATE PRIMARY KEY,
    phone_complete DECIMAL(5, 2),
    dob_complete DECIMAL(5, 2),
    dupes INT
);

DELIMITER //
CREATE EVENT ev_nightly_dq
ON SCHEDULE EVERY 1 DAY
DO 
BEGIN
    INSERT INTO dq_scorecard_log
    SELECT CURDATE(), phone_complete_pct, dob_complete_pct, potential_dupes
    FROM v_dq_scorecard;
END //
DELIMITER ;

DELIMITER //
CREATE EVENT ev_archive_old_visits
ON SCHEDULE EVERY 1 DAY
DO 
BEGIN
    UPDATE visits 
    SET status = 'ARCHIVED'
    WHERE status = 'ACTIVE' 
      AND visit_date < NOW() - INTERVAL 10 DAY;
END //
DELIMITER ;
