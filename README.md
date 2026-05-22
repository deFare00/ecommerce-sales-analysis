# 🛒 E-Commerce Sales Analysis — Advanced SQL Project

![SQL](https://img.shields.io/badge/SQL-SQLite-blue?style=flat-square&logo=sqlite)
![Status](https://img.shields.io/badge/Status-Completed-success?style=flat-square)
![Data](https://img.shields.io/badge/Records-4%2C715%20order%20items-orange?style=flat-square)

> **Day 6 of Advanced SQL Learning Journey**
> Mini project analyzing 18 months of e-commerce transaction data using SQL — covering revenue analysis, customer segmentation, RFM scoring, and business insights.

---

## 📌 Project Overview

This project simulates a real-world data analyst task: given a transactional database from an Indonesian e-commerce platform, extract meaningful business insights using advanced SQL techniques.

**Period Analyzed:** January 2023 – June 2024 (18 months)
**Database:** SQLite
**Tool:** DB Browser for SQLite

---

## 🗄️ Database Schema

The database consists of **5 relational tables** with **4,715 order item records**:

```
categories ──< products ──< order_items >── orders >── customers
```

| Table | Rows | Description |
|---|---|---|
| `categories` | 10 | Product categories & departments |
| `products` | 27 | Product catalog with cost & sell price |
| `customers` | 300 | Customer data with city, province & segment |
| `orders` | 1,874 | Order header with status & payment method |
| `order_items` | 4,715 | Order detail with quantity, price & discount |

---

## 📊 Analyses Performed

| # | Analysis | SQL Concepts Used |
|---|---|---|
| 01 | Monthly Revenue & Profit Trend | `JOIN`, `GROUP BY`, `strftime()`, Arithmetic |
| 02 | Revenue by Category & Department | Multi-table `JOIN`, Aggregate functions |
| 03 | Top 10 Products by Revenue | `ORDER BY`, `LIMIT` |
| 04 | Customer Segmentation Analysis | Subquery, `AVG`, `GROUP BY` |
| 05 | RFM Analysis (Recency, Frequency, Monetary) | `CTE`, `NTILE()` Window Function, `CASE WHEN` |
| 06 | Revenue by Province | `JOIN`, Geographic grouping |
| 07 | Payment Method Performance | Aggregate, `GROUP BY` |
| 08 | Order Status & Cancellation Rate | Subquery in `SELECT`, Percentage calc |
| 09 | Cohort Retention Analysis | Double `CTE`, `julianday()` |
| 10 | Discount Impact Analysis | `CASE WHEN` bucketing, Margin analysis |

---

## 💡 Key Findings

### 1. Electronics Dominates Revenue
**Laptop category alone contributed Rp13.96 Billion (58% of total revenue)**, with MacBook Air M2 as the #1 product. This indicates heavy revenue concentration risk — the business is highly dependent on a single category.

### 2. Discount is NOT the Main Purchase Driver
Products with **0% discount generated the highest net revenue (Rp12.96B)**. MacBook Air M2 and iPhone 15 — the top 2 products — had average discounts of only 4.4% and 5.7% respectively. Customers buy because of demand, not discounts.

### 3. RFM Customer Distribution
Out of 300 customers analyzed:

| RFM Label | Count | Action |
|---|---|---|
| 🏆 Champions | 50 | Retain & reward |
| 💎 Loyal Customers | 83 | Maintain engagement |
| ⭐ Potential Loyalist | 54 | Push to loyal tier |
| 🆕 New Customers | 22 | Onboard properly |
| ⚠️ At Risk | 16 | Win-back campaign (urgent) |
| 💀 Lost Customers | 75 | Minimal re-engagement effort |

### 4. Healthy Cancellation Rate
Total cancellation + return rate is **9.76%** — below the industry average of 15-20%. However, **returned orders (5.44%) exceed cancellations (4.32%)**, suggesting post-delivery dissatisfaction that needs to be addressed through better product descriptions or quality control.

### 5. Geographic Spending is Consistent
Average order value across provinces ranges from **Rp11.6M (Sulawesi Selatan)** to **Rp14.1M (Jawa Barat)** — only an 18% gap. This suggests expansion outside Java is viable, as spending behavior is relatively uniform nationally.

---

## 📁 Repository Structure

```
ecommerce-sales-analysis/
│
├── README.md
├── ecommerce.db                        ← SQLite database
│
├── queries/
│   └── ecommerce_queries.sql           ← All 10 annotated SQL queries
│
└── csv_output/
    ├── 01_monthly_revenue_profit.csv
    ├── 02_revenue_by_category.csv
    ├── 03_top10_products.csv
    ├── 04_customer_segment.csv
    ├── 05_rfm_analysis.csv
    ├── 06_revenue_by_province.csv
    ├── 07_payment_method.csv
    ├── 08_order_status.csv
    ├── 09_cohort_retention.csv
    └── 10_discount_impact.csv
```

---

## 🛠️ How to Run

1. Download and install [DB Browser for SQLite](https://sqlitebrowser.org/)
2. Open `ecommerce.db` via **File → Open Database**
3. Go to **Execute SQL** tab
4. Copy-paste any query from `queries/ecommerce_queries.sql`
5. Hit **▶ Execute** and explore the results

---

## 📚 SQL Skills Demonstrated

```sql
✅ Multi-table JOIN (4-table joins)
✅ Aggregate Functions — SUM, AVG, COUNT, ROUND
✅ GROUP BY with multiple columns
✅ CTE — Common Table Expression (WITH clause)
✅ Window Functions — NTILE(5) OVER (ORDER BY ...)
✅ CASE WHEN — conditional bucketing & RFM labeling
✅ Subquery — in FROM and SELECT clauses
✅ Date Functions — strftime(), julianday()
✅ DISTINCT — accurate counting on joined tables
✅ Percentage Calculation & Margin Analysis
```

---

## ⚠️ Limitations & Future Improvements

- Dataset is synthetic — real-world data would show more extreme patterns
- No demographic data (age, income) to enrich customer profiling
- No traffic/impression data — conversion rate analysis is not possible
- No competitor benchmarking — hard to contextualize the 24.9% margin
- Future: add **time-series forecasting** and **cohort retention heatmap visualization**

---

## 👤 Author

**Defarhan Nugraha Fadhali**
Aspiring Data Analyst | SQL · Data Visualization

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/defarhan-nugraha-fadhali-769001222/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=flat-square&logo=github)](https://github.com/deFare00)

---

*This project is part of my Advanced SQL learning journey. All data is synthetically generated for educational purposes.*
