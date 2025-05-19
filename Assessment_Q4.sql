-- Calculate Customer Lifetime Value (CLV) based on account tenure and transaction volume
SELECT
    u.id AS customer_id,
    u.name,
    
    -- Calculate account tenure in months
    PERIOD_DIFF(DATE_FORMAT(CURRENT_DATE, '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')) AS tenure_months,

    -- Count total successful transactions per customer
    COUNT(s.id) AS total_transactions,

    -- Calculate estimated CLV:
    -- CLV = (transactions per month) * 12 * average profit per transaction (0.1% of avg transaction value)
    ROUND(
        (
            (COUNT(s.id) / NULLIF(PERIOD_DIFF(DATE_FORMAT(CURRENT_DATE, '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')), 0))
            * 12
            * (0.001 * AVG(s.amount))
        ),
        2
    ) AS estimated_clv

FROM users_customuser u
JOIN savings_savingsaccount s ON s.owner_id = u.id

-- Consider only successful transactions
WHERE s.transaction_status = 'SUCCESS'

GROUP BY u.id, u.name, u.date_joined

-- Exclude customers with zero tenure to avoid division by zero
HAVING tenure_months > 0

-- Order customers by estimated CLV descending
ORDER BY estimated_clv DESC;
