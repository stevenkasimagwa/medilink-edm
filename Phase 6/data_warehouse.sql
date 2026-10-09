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
