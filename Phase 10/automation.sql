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
