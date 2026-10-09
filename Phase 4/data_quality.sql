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