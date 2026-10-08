-- 09_analytics.sql
-- Analytics views and KPI definitions

CREATE TABLE IF NOT EXISTS marts.kpi_definition (
    kpi_id SERIAL PRIMARY KEY,
    kpi_name VARCHAR(255) NOT NULL,
    metric_expression TEXT NOT NULL,
    owner_team VARCHAR(150),
    refresh_frequency VARCHAR(50) DEFAULT 'daily'
);

CREATE VIEW marts.vw_patient_utilization AS
SELECT
    p.patient_number,
    COUNT(e.encounter_id) AS visit_count,
    ROUND(AVG(e.total_charge), 2) AS avg_charge,
    MAX(e.encounter_date) AS last_visit
FROM marts.dim_patient p
LEFT JOIN marts.fact_encounter e ON p.patient_sk = e.patient_sk
GROUP BY p.patient_number;

CREATE VIEW marts.vw_provider_performance AS
SELECT
    dp.provider_name,
    dp.specialty,
    COUNT(f.encounter_id) AS total_encounters,
    ROUND(SUM(f.total_charge), 2) AS total_revenue
FROM marts.dim_provider dp
LEFT JOIN marts.fact_encounter f ON dp.provider_sk = f.provider_sk
GROUP BY dp.provider_name, dp.specialty;

INSERT INTO marts.kpi_definition (kpi_name, metric_expression, owner_team)
VALUES
    ('Monthly Patient Visits', 'COUNT(encounter_id)', 'Clinical Analytics'),
    ('Average Cost per Encounter', 'AVG(total_charge)', 'Finance Analytics');
