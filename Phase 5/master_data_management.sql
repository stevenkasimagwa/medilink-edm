ALTER TABLE stg_legacy_b 
    ADD COLUMN phone_norm VARCHAR(13), 
    ADD COLUMN name_clean VARCHAR(120);

SET SQL_SAFE_UPDATES = 0;

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