-- 10_automation.sql
-- Automation and orchestration structures

CREATE TABLE IF NOT EXISTS metadata.pipeline_run (
    run_id SERIAL PRIMARY KEY,
    pipeline_name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'queued',
    records_processed INTEGER DEFAULT 0,
    errors_logged INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS metadata.task_schedule (
    schedule_id SERIAL PRIMARY KEY,
    task_name VARCHAR(255) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    next_run_time TIMESTAMP,
    is_enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS metadata.data_alert (
    alert_id SERIAL PRIMARY KEY,
    alert_name VARCHAR(255) NOT NULL,
    severity VARCHAR(50) DEFAULT 'warning',
    alert_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

INSERT INTO metadata.task_schedule (task_name, frequency, next_run_time, is_enabled)
VALUES
    ('raw_to_staging_load', 'hourly', CURRENT_TIMESTAMP + INTERVAL '1 hour', TRUE),
    ('dq_validation_run', 'daily', CURRENT_DATE + INTERVAL '1 day', TRUE),
    ('warehouse_refresh', 'nightly', CURRENT_DATE + INTERVAL '1 day', TRUE);
