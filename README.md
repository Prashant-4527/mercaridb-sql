# 🛒 MercariDB — SQL Learning Project

> A 30-day structured SQL learning project modeled after real e-commerce data scenarios — inspired by Mercari Japan's marketplace platform.

![SQL](https://img.shields.io/badge/SQL-SQLite%20%2F%20PostgreSQL-336791?logo=postgresql&logoColor=white)
![Days](https://img.shields.io/badge/Challenge-30%20Days-ff6b6b)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Inspiration](https://img.shields.io/badge/Inspired%20by-Mercari%20Japan-E40046?logo=data:image/png;base64,)

---

## 📌 About This Project

**MercariDB** is a 30-day SQL challenge built around a simulated Mercari-style e-commerce database. Instead of practicing SQL on generic toy datasets, every query here solves a **real business problem** that a data engineer or backend developer at Mercari Japan might face.

The project covers everything from basic SELECTs to complex window functions, CTEs, and query optimization.

---

## 🗄️ Database Schema

```
mercaridb
│
├── users           — User accounts (id, name, location, join_date, verified)
├── products        — Listings (id, seller_id, title, category, price, condition)
├── transactions    — Purchase records (id, buyer_id, seller_id, product_id, amount, date)
├── categories      — Product categories (id, name, parent_id)
├── reviews         — Seller ratings (id, reviewer_id, seller_id, rating, comment)
└── shipping        — Delivery info (id, transaction_id, carrier, status, delivered_at)
```

---

## 📅 30-Day Challenge Structure

### 🟢 Week 1 — Foundations (Days 1–7)
| Day | Topic | Business Question |
|-----|-------|------------------|
| 1 | SELECT, WHERE, ORDER BY | "Show me all active listings under ¥5,000" |
| 2 | Aggregate Functions | "What's the average selling price per category?" |
| 3 | GROUP BY, HAVING | "Which sellers have made more than 10 sales?" |
| 4 | ORDER BY, LIMIT, OFFSET | "Show top 10 cheapest listings in each category" |
| 5 | NULL handling | "Find all unverified users who have listed products" |
| 6 | JOINs (INNER, LEFT) | "Show every transaction with buyer and seller details" |

### 🟡 Week 2 — Intermediate (Days 8–14)
| Day | Topic | Business Question |
|-----|-------|------------------|
| 8 | Subqueries | "Find products priced above the category average" |
| 9 | CTEs (WITH clause) | "Identify top 10 sellers by revenue this quarter" |
| 10 | CASE WHEN | "Classify products as budget / mid-range / premium" |
| 11 | Multi-table JOINs | "Full transaction report with product, buyer, seller, shipping" |
| 12 | EXISTS / NOT EXISTS | "Find users who have never made a purchase" |
| 13 | UNION / INTERSECT | "Combine buyer and seller activity into one feed" |
| 14 | Practice day — combined challenge | Mini business report |

### 🟠 Week 3 — Advanced (Days 15–21)
| Day | Topic | Business Question |
|-----|-------|------------------|
| 15 | Window Functions (ROW_NUMBER) | "Rank sellers by sales volume in each category" |
| 16 | Window Functions (LAG/LEAD) | "Compare each user's purchase to their previous one" |
| 17 | Running totals | "Show cumulative revenue over time" |
| 18 | PARTITION BY | "Find each category's best-selling product" |
| 19 | Indexes & EXPLAIN | "Why is this query slow? How do we fix it?" |
| 20 | Views | "Create a reusable 'active_sellers' view" |
| 21 | Practice day — window function challenge | Seller performance dashboard |

### 🔴 Week 4 — Real-World Scenarios (Days 22–30)
| Day | Topic | Business Question |
|-----|-------|------------------|
| 22 | Cohort Analysis | "Retention rate of users by signup month" |
| 23 | Funnel Analysis | "How many users list → get offers → complete sales?" |
| 24 | Fraud Detection | "Flag suspicious high-volume accounts" |
| 25 | Geographic Analysis | "Top selling regions in Japan" |
| 26 | Price Trend Analysis | "How have prices changed week-over-week?" |
| 27 | Recommendation Logic | "Users who bought X also bought Y" |
| 28 | Performance Reporting | "Build a seller dashboard with KPIs" |
| 29 | Full schema optimization | "Redesign for scale: 10M users" |
| 30 | Final project | End-to-end business intelligence report |

---

## 💡 Sample Query

```sql
-- Day 15: Rank sellers by revenue within each category
WITH seller_revenue AS (
    SELECT
        p.category,
        t.seller_id,
        u.name AS seller_name,
        SUM(t.amount) AS total_revenue,
        COUNT(t.id) AS total_sales
    FROM transactions t
    JOIN products p ON t.product_id = p.id
    JOIN users u ON t.seller_id = u.id
    GROUP BY p.category, t.seller_id, u.name
)
SELECT
    category,
    seller_name,
    total_revenue,
    total_sales,
    RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rank_in_category
FROM seller_revenue
ORDER BY category, rank_in_category;
```

---

## 🎯 Why Mercari?

Mercari is Japan's largest C2C marketplace with over 20 million monthly active users. As a target company for my **AI Engineer career in Japan**, studying their data model gives me:

1. Real context for SQL practice (not abstract exercises)
2. Understanding of e-commerce data pipelines
3. Interview-ready answers to business-driven SQL questions

---

## 🛠️ Tech Stack

- **Database:** MySQL (local)
- **Tools:** MySQL Workbench
- **Language:** SQL

---

## 🚀 Getting Started

```bash
git clone https://github.com/Prashant-4527/mercaridb-sql.git
cd mercaridb-sql

# Open any .sql file in MySQL Workbench
# Run day1_setup.sql first to create the database
# Then run each day's file in order
```
---

## 📈 Progress Tracker

* Week 1 — Foundations 🟢 (Completed)
* Week 2 — Intermediate 🟠 (6/7)
* Week 3 — Advanced ⬜
* Week 4 — Real-World Scenarios ⬜

---

## 📬 Connect

- GitHub: [@Prashant-4527](https://github.com/Prashant-4527)
- Target: AI Engineer @ Mercari Japan 🇯🇵 by 2028
- Location: Jaipur, India 🇮🇳

---

*"The best way to learn SQL is to solve real problems. メルカリで日本を目指す！"*

