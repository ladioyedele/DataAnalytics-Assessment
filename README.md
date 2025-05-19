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

## Question 1: Customers with Both Funded Savings and Investment Plans

### Approach

The task was to identify customers holding both a savings plan and an investment plan, and summarize their total deposits.

I joined customer data with plans and deposits, counting distinct savings and investment plans separately. To avoid inflating totals due to multiple deposits per plan, I pre-aggregated deposits at the plan level before summing them by customer. This ensured accuracy.

A notable early step was concatenating the `first_name` and `last_name` columns into a unified `name` field, since the dataset lacked a combined full name — making outputs more readable.

### Challenges & Solutions

* **Error: No 'name' column in users table**
  Initially, I tried selecting a `name` field that didn’t exist, causing SQL errors. I resolved this by updating the dataset to create a `name` column by concatenating `first_name` and `last_name`.

* **Double counting deposits due to join duplication**
  Summing deposits directly in joins gave inflated values because a plan could have many transactions. I solved this by summing deposits per plan first in a CTE, then aggregating by customer.

* **Unexpectedly high savings counts (200+ plans for some customers)**
  This seemed suspicious, so I wrote diagnostic queries to check the distribution of plan counts and looked for duplicates or anomalies in the data. It helped confirm data integrity and whether the numbers were realistic.

---

## Question 2: Customer Transaction Frequency Segmentation

### Approach

The goal was to classify customers based on average monthly transaction volume into High, Medium, or Low frequency groups.

I grouped transactions by customer and month, counted monthly transactions, then averaged these counts per customer to get a monthly average. Joining with user data allowed me to assign frequency categories.

Finally, I summarized how many customers fell into each category and calculated average transaction counts for those segments.

### Challenges & Solutions

* **Error: Can't group by derived column in HAVING clause**
  My initial attempt to group by a case statement caused errors. I fixed this by doing the categorization inside a CTE and then grouping on that pre-calculated field.

* **Grouping by month correctly**
  Extracting the year and month from transaction dates was tricky. Using `DATE_FORMAT(transaction_date, '%Y-%m')` made it straightforward to group transactions monthly.

* **Ordering frequency categories logically**
  Alphabetical order wouldn't reflect the logical frequency hierarchy. I used a CASE statement in ORDER BY to fix the display order.

---

## Question 3: Identifying Inactive Plans (No Transactions Over 1 Year)

### Approach

I needed to find active plans without any transactions in the past 365 days.

I joined plans with transactions, filtered out archived and deleted plans, and calculated the date of last transaction per plan. Using `DATEDIFF`, I measured inactivity duration and filtered for those exceeding 365 days.

### Challenges & Solutions

* **Including plans with no transactions caused NULL errors in DATEDIFF**
  Initially, I included all plans with a LEFT JOIN, but plans without transactions produced NULLs causing `DATEDIFF` errors. The requirement specified previously active plans only, so switching to an INNER JOIN solved this by excluding plans with no transaction history.

* **Filtering archived and deleted plans**
  Early results were skewed by irrelevant plans. After learning about `is_archived` and `is_deleted` flags, I added filters to exclude them.

* **Calculating days inactive accurately**
  I confirmed that the difference between `CURRENT_DATE` and the last transaction date accurately reflected inactivity.

---

## Question 4: Estimating Customer Lifetime Value (CLV)

### Approach

The CLV formula combined transaction count, account tenure, and average transaction value, assuming a 0.1% profit margin per transaction.

I computed tenure in months, filtered only successful transactions, and applied the formula:

```
CLV = (total_transactions / tenure_months) * 12 * (0.001 * avg_transaction_value)
```

Customers with zero tenure were excluded to avoid division by zero.

### Challenges & Solutions

* **Division by zero errors for new customers**
  Some users had zero months tenure causing errors. I added a HAVING clause to exclude these cases.

* **Including failed transactions skewed results**
  Initially, I counted all transactions, but failed or reversed ones inflated CLV. Adding a `WHERE transaction_status = 'SUCCESS'` filter fixed this.

* **Complex multi-part formula in SQL**
  Nesting counts, averages, and calculations required careful structuring and use of `NULLIF` to avoid divide-by-zero. Rounding ensured clean output.
---

## Summary

All SQL scripts:
- Are optimized for readability and reusability.
- Use CTEs and logical query blocks.
- Avoid common pitfalls like duplication, bad joins, and inaccurate groupings.
- Are formatted and commented for ease of understanding and collaboration.
