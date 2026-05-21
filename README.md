# 🛒 MercariDB Analytics — SQL Capstone Project

<div align="center">

**A production-quality SQL analytics project built on a simulated Mercari Japan marketplace.**
*From raw data to business intelligence — using pure SQL.*

[![SQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat)]()
[![Concepts](https://img.shields.io/badge/Concepts-30+-orange?style=flat)]()
[![Inspired by](https://img.shields.io/badge/Inspired%20by-Mercari%20Japan-E40046?logo=data:image/png;base64,)]()

> **Learning repo →** [mercaridb-mysql-30days](https://github.com/Prashant-4527/mercaridb-mysql-30days)
> **This repo →** The capstone. Real business questions. Real SQL. Real insights.

</div>

---

## 📌 What Is This Project?

This is not a tutorial follow-along.

MercariDB Analytics is a **self-directed capstone project** where I designed a realistic
C2C marketplace database, loaded it with meaningful seed data, and then answered
**real business questions** that a Data Analyst at Mercari Japan would actually face.

Every query in this project starts with a business question — not a SQL exercise.
The schema is normalized to 3NF. The analysis covers sellers, buyers, products,
markets, and growth opportunities. The insights are written in plain language.

**Built after 30 days of structured SQL study. Written from scratch.**

---

## 🗄️ Database Schema

```
mercaridb
│
├── users          — user_id (PK), username, email, country, age, referred_by, created_at
│
├── products       — product_id (PK), seller_id (FK), title, category,
│                    price (DECIMAL), status, created_at
│
├── orders         — order_id (PK), product_id (FK), buyer_id (FK),
│                    amount (DECIMAL), order_date
│
└── [your tables]  — add any extra tables you create

Relationships:
  users ──< products  (one seller → many listings)
  users ──< orders    (one buyer  → many orders)
  products ──< orders (one product → one order)
```

**Design decisions:**
- `DECIMAL(10,2)` for all monetary values — never FLOAT for money
- `NOT NULL` on all critical fields — data integrity enforced at DB level
- `FOREIGN KEY` constraints — referential integrity guaranteed
- Fully normalized to **3NF** — no redundancy, no update anomalies

---

## 📊 Dataset Overview

| Table    | Rows | Description                              |
|----------|------|------------------------------------------|
| users    | XX   | Registered buyers and sellers            |
| products | XX   | Product listings across N categories     |
| orders   | XX   | Completed purchase transactions          |

**Countries covered:** India, Japan, USA, Germany, China, Mexico
**Categories covered:** Electronics, Fashion, Books, Photography, Sports

---

## 🔍 Business Questions Answered

### Section 1 — Platform Overview
> *"How big is our platform? What are the core KPIs?"*

| # | Question |
|---|----------|
| 1 | Total users, products, orders, and revenue in one dashboard query |
| 2 | Active vs sold product ratio across the platform |
| 3 | Average order value + median order value |
| 4 | Platform coverage — unique countries and market count |
| 5 | New user registrations — this month vs last month |

---

### Section 2 — Seller Analysis
> *"Who are our best sellers? Who is underperforming?"*

| # | Question |
|---|----------|
| 1 | Seller health report — sell-through rate, revenue, tier classification |
| 2 | Top N sellers by revenue with market share percentage |
| 3 | Sellers with no completed sales — dead accounts |
| 4 | Revenue concentration — what % of revenue comes from top 3 sellers? |
| 5 | Seller ranking with RANK() per country |

---

### Section 3 — Buyer Behaviour
> *"Who are our buyers? How do they spend?"*

| # | Question |
|---|----------|
| 1 | Buyer segmentation — Whale / High / Mid / Low value |
| 2 | Referred vs organic buyer spending comparison |
| 3 | Average spend by generation — Teen / Gen Z / Millennial |
| 4 | Buyers who placed only one order — churn risk |
| 5 | Top buyer per country |

---

### Section 4 — Product Intelligence
> *"What's selling? What's sitting? What's overpriced?"*

| # | Question |
|---|----------|
| 1 | Price tier distribution — Budget / Mid-range / Premium |
| 2 | Top product per category by price (RANK per partition) |
| 3 | Products priced above their category average |
| 4 | Conversion rate per category — sold vs listed |
| 5 | Dead stock — products with zero orders |

---

### Section 5 — Market Analysis
> *"Where is our revenue coming from? Where should we expand?"*

| # | Question |
|---|----------|
| 1 | Revenue and user count per country |
| 2 | Cross-country transaction flow matrix |
| 3 | Market classification — Core / Growing / Emerging |
| 4 | APAC vs Europe vs Americas comparison |
| 5 | Country-wise user type pivot |

---

### Section 6 — Growth Opportunities
> *"What should we fix? Who should we target?"*

| # | Question |
|---|----------|
| 1 | Inactive users — never bought, never sold |
| 2 | Buyers who haven't tried selling — conversion opportunity |
| 3 | Underperforming categories — low conversion rate |
| 4 | Referral program effectiveness — referred vs organic LTV |
| 5 | Full opportunity summary with recommended actions |

---

## 💡 Key Findings

> *(Fill this in with your actual query results — your own words)*

**Finding 1 — [Give it a title]**
[Write 2-3 sentences describing what you found and why it matters]

**Finding 2 — [Title]**
[Your insight here]

**Finding 3 — [Title]**
[Your insight here]

**Finding 4 — [Title]**
[Your insight here]

**Finding 5 — [Title]**
[Your insight here]

---

## 🛠️ SQL Techniques Used

This project demonstrates the full SQL stack — from foundations to expert level.

**Foundations**
- `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `OFFSET`
- `GROUP BY` + `HAVING`
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `CASE WHEN` for conditional logic and classification

**Joins + Subqueries**
- `INNER JOIN`, `LEFT JOIN`, `SELF JOIN`, 3-table joins
- Scalar subqueries, correlated subqueries, derived tables
- `EXISTS` / `NOT EXISTS` — NULL-safe filtering
- `UNION`, `UNION ALL` for set operations

**Advanced SQL**
- Window functions: `ROW_NUMBER`, `RANK`, `DENSE_RANK`
- Offset functions: `LAG`, `LEAD`, `NTILE`
- Running totals + moving averages with `OVER(ROWS BETWEEN...)`
- CTEs (`WITH` clause) — multi-step analytical pipelines
- Recursive CTEs — referral chain traversal

**Production Techniques**
- `EXPLAIN` + index creation for query optimization
- `VIEWS` — reusable analytical layers
- `STORED PROCEDURES` — parameterized business logic
- `TRANSACTIONS` + ACID properties
- `NULLIF()` + `COALESCE()` — NULL-safe calculations
- `DECIMAL` over `FLOAT` for monetary accuracy

---

## 💎 Signature Queries

### 1. Seller Health Scorecard

```sql
WITH seller_listings AS (
    SELECT seller_id,
           COUNT(*)                                            AS total_listed,
           SUM(CASE WHEN status = 'sold' THEN 1 ELSE 0 END)  AS total_sold,
           COALESCE(SUM(o.amount), 0)                         AS revenue
    FROM products p
    LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY seller_id
)
SELECT
    u.username,
    u.country,
    sl.total_listed,
    sl.total_sold,
    ROUND(sl.total_sold * 100.0 / NULLIF(sl.total_listed, 0), 1) AS sell_through_pct,
    sl.revenue,
    CASE
        WHEN sl.revenue >= 50000 THEN 'Diamond'
        WHEN sl.revenue >= 20000 THEN 'Gold'
        WHEN sl.revenue >= 5000  THEN 'Silver'
        WHEN sl.revenue > 0      THEN 'Bronze'
        ELSE                          'No Sales'
    END AS seller_tier,
    RANK() OVER (ORDER BY sl.revenue DESC) AS revenue_rank
FROM seller_listings sl
INNER JOIN users u ON sl.seller_id = u.user_id
ORDER BY sl.revenue DESC;
```

---

### 2. Cross-Country Transaction Flow

```sql
SELECT
    buyer.country  AS from_country,
    seller.country AS to_country,
    COUNT(*)       AS transactions,
    SUM(o.amount)  AS total_value,
    CASE
        WHEN buyer.country = seller.country THEN 'Domestic'
        ELSE                                     'International'
    END AS flow_type,
    RANK() OVER (ORDER BY SUM(o.amount) DESC) AS value_rank
FROM orders o
INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
INNER JOIN products p   ON o.product_id = p.product_id
INNER JOIN users seller ON p.seller_id  = seller.user_id
GROUP BY buyer.country, seller.country
ORDER BY total_value DESC;
```

---

### 3. Complete User Lifecycle View

```sql
CREATE OR REPLACE VIEW complete_user_profile AS
WITH seller_data AS (
    SELECT p.seller_id,
           COUNT(p.product_id)                                    AS listings,
           SUM(CASE WHEN p.status='sold' THEN 1 ELSE 0 END)      AS sold_items,
           COALESCE(SUM(o.amount), 0)                             AS seller_revenue
    FROM products p LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.seller_id
),
buyer_data AS (
    SELECT buyer_id, COUNT(*) AS total_orders, SUM(amount) AS total_spent
    FROM orders GROUP BY buyer_id
)
SELECT
    u.username, u.country, u.age,
    CASE
        WHEN u.age < 20 THEN 'Teen'
        WHEN u.age BETWEEN 20 AND 26 THEN 'Gen Z'
        WHEN u.age BETWEEN 27 AND 42 THEN 'Millennial'
        ELSE 'Other'
    END AS generation,
    CASE
        WHEN sd.listings > 0 AND bd.total_orders > 0 THEN 'Power User'
        WHEN bd.total_orders > 0                      THEN 'Buyer'
        WHEN sd.listings > 0                          THEN 'Seller'
        ELSE                                               'Inactive'
    END AS user_type,
    COALESCE(sd.listings, 0)       AS total_listings,
    COALESCE(sd.seller_revenue, 0) AS seller_revenue,
    COALESCE(bd.total_orders, 0)   AS orders_placed,
    COALESCE(bd.total_spent, 0)    AS total_spent,
    RANK() OVER (ORDER BY COALESCE(sd.seller_revenue, 0) DESC) AS seller_rank,
    RANK() OVER (ORDER BY COALESCE(bd.total_spent, 0)    DESC) AS buyer_rank
FROM users u
LEFT JOIN seller_data sd ON u.user_id = sd.seller_id
LEFT JOIN buyer_data  bd ON u.user_id = bd.buyer_id;
```

---

## 🚀 How to Run

```bash
# 1. Clone the repo
git clone https://github.com/Prashant-4527/mercaridb-capstone.git
cd mercaridb-capstone

# 2. Open MySQL Workbench (or any MySQL client)

# 3. Run schema first
# schema/01_schema.sql → creates all tables
# schema/02_seed_data.sql → loads all data

# 4. Run any analysis file
# analysis/01_platform_overview.sql
# analysis/02_seller_analysis.sql
# ... etc.
```

**Requirements:** MySQL 8.0+ · MySQL Workbench · Git

---

## 📁 Project Structure

```
mercaridb-capstone/
│
├── README.md
│
├── schema/
│   ├── 01_schema.sql            ← CREATE TABLE statements (3NF design)
│   └── 02_seed_data.sql         ← INSERT statements (realistic data)
│
├── analysis/
│   ├── 01_platform_overview.sql
│   ├── 02_seller_analysis.sql
│   ├── 03_buyer_behaviour.sql
│   ├── 04_product_intelligence.sql
│   ├── 05_market_analysis.sql
│   └── 06_growth_opportunities.sql
│
├── views/
│   └── dashboard_views.sql      ← Reusable analytical views
│
├── advanced/
│   ├── window_functions.sql
│   ├── cte_pipelines.sql
│   └── stored_procedures.sql
│
└── insights/
    └── KEY_FINDINGS.md          ← Plain-language business insights
```

---

## 🔗 Related

| Project | Description |
|---------|-------------|
| [mercaridb-mysql-30days](https://github.com/Prashant-4527/mercaridb-mysql-30days) | 30-day structured SQL learning journey |
| [Mercari-analytics-report](https://github.com/Prashant-4527/Mercari-analytics-report) | Earlier analytics report (Week 1-2 level) |
| [EduTrack-oop-numpy](https://github.com/Prashant-4527/Edutrack-oop-numpy) | Python OOP + NumPy analytics system |

---

## 👤 About

**Prashant** — BCA Student @ Maharaja College Jaipur
Self-directing a multi-year curriculum toward an AI Engineering role at Mercari Japan by 2028.

**Stack:** Python · MySQL · NumPy · Pandas (in progress) · DSA (daily)
**Languages:** English · Hindi · Japanese (N4 → N3) · German (A2)
**Target:** METI IPA Internship 2027 → Mercari Japan 2028 🇯🇵

[![GitHub](https://img.shields.io/badge/GitHub-Prashant--4527-black?logo=github)](https://github.com/Prashant-4527)

---

*Built from scratch. Every query written by hand. No shortcuts.*
*メルカリで日本を目指す！*
