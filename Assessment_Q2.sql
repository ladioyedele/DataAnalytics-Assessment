-- Step 1: Calculate monthly transaction counts per user
WITH MonthlySummary AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_tx_count
    FROM savings_savingsaccount
    GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m')
),

-- Step 2: Calculate average monthly transactions per user
UserAverages AS (
    SELECT
        owner_id,
        AVG(monthly_tx_count) AS avg_transactions_per_month
    FROM MonthlySummary
    GROUP BY owner_id
),

-- Step 3: Join user data and classify frequency segment
UserFrequency AS (
    SELECT
        u.id AS owner_id,
        u.name,
        ROUND(ua.avg_transactions_per_month, 2) AS avg_transactions_per_month,
        CASE
            WHEN ua.avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN ua.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_segment
    FROM users_customuser u
    JOIN UserAverages ua ON u.id = ua.owner_id
)

-- Step 4: Aggregate by frequency category with counts and averages
SELECT
    frequency_segment AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM UserFrequency
GROUP BY frequency_segment
ORDER BY 
    CASE frequency_segment
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;
