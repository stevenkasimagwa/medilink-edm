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