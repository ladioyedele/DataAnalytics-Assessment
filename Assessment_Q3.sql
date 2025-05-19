-- Find active plans (savings or investment) with no transactions in the last 365 days
SELECT
    p.id AS plan_id,
    p.owner_id,
    
    -- Classify plan type
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    
    -- Date of last transaction for the plan
    MAX(s.transaction_date) AS last_transaction_date,
    
    -- Number of days since last transaction
    DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days

FROM plans_plan p

-- Join to get transactions for each plan (only plans with transactions)
JOIN savings_savingsaccount s ON s.plan_id = p.id

-- Only consider active, non-archived, and non-deleted plans
WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1)
  AND p.is_archived = 0
  AND p.is_deleted = 0

GROUP BY p.id, p.owner_id, type

-- Filter for plans inactive for more than 365 days
HAVING DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) > 365

-- Order by most inactive first
ORDER BY inactivity_days DESC;
