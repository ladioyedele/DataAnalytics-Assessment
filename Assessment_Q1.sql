-- Fixing the name column by concatenating first name and last columns
UPDATE users_customuser
SET name = CONCAT(first_name, ' ', last_name);

-- Calculate total deposits per customer and identify customers 
-- with at least one funded savings plan and one funded investment plan
WITH Deposits AS (
    SELECT 
        owner_id, 
        SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
)

SELECT
    p.owner_id,
    u.name,
    -- Count distinct savings plans per customer
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    -- Count distinct investment plans per customer
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    d.total_deposits
FROM plans_plan p
JOIN users_customuser u ON p.owner_id = u.id
JOIN Deposits d ON p.owner_id = d.owner_id  -- Include only customers with deposits
GROUP BY p.owner_id, u.name, d.total_deposits
HAVING 
    -- Must have at least one funded investment plan
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) >= 1
    -- Must have at least one funded savings plan
    AND COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) >= 1
ORDER BY d.total_deposits DESC;
