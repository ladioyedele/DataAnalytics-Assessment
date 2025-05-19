# SQL Analysis: COWRY WISE ASSESSMENT

## Overview

This repository contains SQL scripts that answer four key business questions using data from the `users_customuser`, `plans_plan`, and `savings_savingsaccount` tables. The goal was to extract actionable insights around customer behavior, account engagement, transaction frequency, and estimated value.

Each query was crafted to follow best practices:
- Single, focused query per use case
- Clear structure with Common Table Expressions (CTEs) where appropriate
- Proper indentation and formatting
- In-line comments to explain complex logic
- Avoidance of double-counting and redundant joins

  ---

## Question 1: Identify Customers with Funded Savings and Investment Plans

### Objective
Find customers who have at least one funded savings plan **and** one funded investment plan, with their total deposits.

### Solution Approach
- A CTE was used to pre-aggregate deposits by `plan_id` to avoid double-counting due to multiple transactions.
- Distinct savings and investment plans were counted for each customer.
- Only users with at least one of each type were included.
- The result was ordered by total deposits to highlight high-value customers.

### Challenges and Resolution
- One challenge was ensuring the **customer name field was consistent and readable**. In the dataset, the `users_customuser` table had separate `first_name` and `last_name` fields. I updated the dataset using an SQL `UPDATE` query to concatenate them into a single `name` field for easier reference in all queries.
- Another challenge was ensuring **accurate aggregation of deposit values**. Multiple transactions linked to a single plan could inflate totals. To solve this, I aggregated deposits by `plan_id` first, then summed them per customer.
- Handling **duplicate or overlapping plan types** for users required filtering and counting only distinct plan IDs for each category.
- Lastly, ensuring only **truly funded accounts** were included meant joining only users with actual deposits, rather than just checking plan flags.

---

## Question 2: Segment Customers by Transaction Frequency

### Objective
Group customers into frequency bands (High, Medium, Low) based on their average number of monthly transactions.

### Solution Approach
- CTE 1: Grouped transactions by user and month.
- CTE 2: Calculated the average number of monthly transactions per user.
- CTE 3: Joined this with user info and classified users into segments.
- The final SELECT grouped and summarized by frequency category.

### Frequency Categories
- High Frequency: ≥ 10 transactions/month
- Medium Frequency: 3–9 transactions/month
- Low Frequency: ≤ 2 transactions/month

### Challenges and Resolution
Ensuring time was grouped by month required formatting the date string correctly. Sorting the frequency categories in the correct order also required a custom `ORDER BY` logic. Additionally, balancing performance with clarity using multiple CTEs required careful structuring to avoid subquery redundancy.

---

## Question 3: Find Active Plans with No Transactions in Over a Year

### Objective
Identify savings or investment plans that are still active but have not had any transactions in the past 365 days.

### Solution Approach
- Filtered plans to exclude those marked as archived or deleted.
- Joined only those plans that had **at least one** transaction (no LEFT JOIN).
- Aggregated by plan ID to find the latest transaction date.
- Filtered for plans where `DATEDIFF` exceeded 365 days.

### Challenges and Resolution
- A key challenge was distinguishing between plans that were inactive and those that had **never had a transaction**. To comply with the requirement, only previously active plans were considered using an `INNER JOIN`.
- Ensuring performance didn’t degrade when grouping large transaction tables also required testing and tuning the use of `MAX()` over joined data.

---

## Question 4: Estimate Customer Lifetime Value (CLV)

### Objective
Estimate CLV for each customer using this formula:

```
CLV = (total_transactions / tenure_months) * 12 * (0.001 * average_transaction_value)
```

### Solution Approach
- Calculated account tenure using the `PERIOD_DIFF` between join date and current date.
- Counted only successful transactions.
- Averaged transaction values to calculate average profit per transaction (0.1% of amount).
- Filtered out customers with 0-month tenure to avoid division errors.

### Challenges and Resolution
- Preventing **division by zero** was essential for users with zero or same-month tenure.
- Normalizing the CLV across customers with different join dates and activity levels added complexity to the formula.
- Ensuring only **relevant (successful)** transactions were used added an additional filter and safeguard to ensure CLV estimates reflect actual customer engagement.

---

## Summary

All SQL scripts:
- Are optimized for readability and reusability.
- Use CTEs and logical query blocks.
- Avoid common pitfalls like duplication, bad joins, and inaccurate groupings.
- Are formatted and commented for ease of understanding and collaboration.
