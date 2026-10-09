-- 1. District and Clinic Visit Rollup
SELECT 
    dc.district,
    dc.clinic_name,
    DATE_FORMAT(f.visit_date, '%Y-%m') AS yr_mo,
    COUNT(*) AS visits
FROM fact_visits f
JOIN dim_clinic dc 
    USING (clinic_sk)
GROUP BY 
    dc.district,
    dc.clinic_name,
    yr_mo WITH ROLLUP;


-- 2. DRILL-DOWN: top 5 diagnoses network-wide
SELECT 
    diagnosis_code,
    COUNT(*) AS cases,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM fact_visits
GROUP BY diagnosis_code
ORDER BY rnk
LIMIT 5;


-- 3. Revenue Share by Payment Mode
SELECT 
    DATE_FORMAT(visit_date, '%Y-%m') AS yr_mo,
    payment_mode,
    SUM(total_amount) AS revenue,
    ROUND(
        100.0 * SUM(total_amount) / SUM(SUM(total_amount)) 
        OVER (PARTITION BY DATE_FORMAT(visit_date, '%Y-%m')), 1
    ) AS pct
FROM (
    SELECT 
        f.visit_date, 
        f.total_amount, 
        'CASH' AS payment_mode
    FROM fact_visits f
) x
GROUP BY 
    yr_mo, 
    payment_mode;


-- 4. 3-Month Moving Average of Visits
SELECT 
    yr_mo,
    visits,
    ROUND(
        AVG(visits) OVER (
            ORDER BY yr_mo 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )
    ) AS ma_3m
FROM (
    SELECT 
        DATE_FORMAT(visit_date, '%Y-%m') AS yr_mo, 
        COUNT(*) AS visits
    FROM fact_visits 
    GROUP BY yr_mo
) t;


-- 5. 30-Day Readmission Percentage
SELECT 
    ROUND(
        100.0 * COUNT(*) / NULLIF(
            (
                SELECT COUNT(*) 
                 FROM (
                    SELECT 
                        patient_sk, 
                        visit_date,
                        LEAD(visit_date) OVER (PARTITION BY patient_sk ORDER BY visit_date) AS nxt
                    FROM fact_visits
                ) a 
                WHERE nxt IS NOT NULL
            ), 
            0
        ), 
        1
    ) AS readmit_within_30d_pct
FROM (
    SELECT 
        patient_sk, 
        visit_date,
        LEAD(visit_date) OVER (PARTITION BY patient_sk ORDER BY visit_date) AS nxt
    FROM fact_visits
) b
WHERE nxt IS NOT NULL 
  AND DATEDIFF(nxt, visit_date) <= 30;