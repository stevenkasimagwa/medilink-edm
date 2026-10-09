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
