# Marketplace Revenue Leakage & Gap Analysis using SQL

A SQL project that finds out  why a marketplace's profit is lower than its sales suggest . Using a marketplace database, I measured how much money is lost to discounts, returns, logistics costs and payment gateway fees.

 Domain:  E-commerce & Marketplace Analytics
 Tool:  SQL (pgAdmin)

---

  Problem Statement

Sales can look healthy while profit shrinks. This project checks where the money goes by analysing products, orders, discounts, returns, logistics and payment fees, then points out the biggest leakage sources.

---

  Database Tables

| Table | What it stores |
|---|---|
| `products_v2` | Product ID, category, cost price |
| `orders_v2` | Orders, selling price, quantity, payment method, customer |
| `discounts_v2` | Discount amount per order |
| `returns_v2` | Return flag and return reason |
| `logistics_cost_v2` | Shipping and reverse shipping cost |
| `payment_fees_v2` | Fee percentage for each payment method |

---

  How Profit Is Calculated

```
Profit = (Selling Price - Cost Price) x Quantity
         - Discount
         - Shipping Cost
         - Reverse Shipping Cost
         - Payment Fee (Fee % of order value)
```

`COALESCE` is used so missing discounts or logistics costs count as 0.

---

  Tasks Covered

| # | Analysis |
|---|---|
| 1 | Total revenue, cost and profit |
| 2 | Sales, cost and profit by category |
| 3 | Loss-making products |
| 4 | Discount usage (orders and total amount) |
| 5 | Orders and sales by payment method |
| 6 | Average profit: discounted vs non-discounted orders |
| 7 | Revenue and profit lost to returns |
| 8 | Returns and revenue lost by return reason |
| 9 | Orders where logistics cost is over 20% of order value |
| 10 | Payment fees by method and the effect on profit |
| 11 | Leakage breakdown per order (discount, returns, logistics, fees) |
| 12 | Product ranking by net profit |
| 13 | Profit margin variation by category |
| 14 | Customers with a high return rate |
| 15 | Executive summary of all leakage factors |

---

  SQL Concepts Used

- Joins (`JOIN`, `LEFT JOIN`) across 5 tables
- Aggregations (`SUM`, `COUNT`, `AVG`) with `GROUP BY` and `HAVING`
- CTEs (`WITH`) and subqueries
- Window function (`RANK() OVER`)
- `CASE WHEN` for conditional totals
- `COALESCE` and `NULLIF` for NULLs and divide-by-zero

---

  Key Business Questions Answered

- Is the business actually making money, or just making sales?
- Which categories and products make a profit, and which lose money?
- Do discounts increase profit or only volume?
- How much do returns, logistics and payment fees reduce profit?
- Which customers return products far more than average?

---

  Repository Structure

```
sql/        # SQL queries for all 15 tasks
data/       # Dataset files
README.md

Skills Used

SQL, Joins, CTEs, Window Functions, Data Analysis, Profitability Analysis, Business Gap Analysis
