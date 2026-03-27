# MercariDB — SQL Mastery Project

A 30-day structured SQL learning project built around a real-world
marketplace database inspired by **Mercari Japan** — Japan's largest
consumer-to-consumer marketplace.

---

## About This Project

This is not just a tutorial follow-along.
Every query is written in the context of **real business problems**
a Data Analyst or Data Scientist would face at a company like Mercari.

The goal: go from zero SQL knowledge to **international job-ready**
in 30 days — targeting Data Science / AI Engineering roles in Japan and Germany.

---

## Database Schema

**Current: `users` table**

| Column | Type | Description |
|---|---|---|
| user_id | INT (PK) | Auto-incremented unique ID |
| username | VARCHAR(50) | Unique username |
| email | VARCHAR(100) | Unique email address |
| country | VARCHAR(50) | User's country |
| age | INT | User's age (nullable) |
| created_at | DATETIME | Account creation timestamp |

**Coming soon:** `products`, `orders`, `payments`, `categories`, `reviews`

---

## Progress Tracker

| Day | Topic | Status |
|---|---|---|
| Day 1 | Database setup, CREATE TABLE, PRIMARY KEY, data types | ✅ Done |
| Day 2 | SELECT, FROM, WHERE, comparison operators, LIKE, IS NULL | ✅ Done |
| Day 3 | AND, OR, NOT, IN, BETWEEN, LIKE patterns, bracket rules | ✅ Done |
| Day 4 | ORDER BY, LIMIT, OFFSET | 🔄 In Progress |
| Day 5 | Aggregate functions: COUNT, SUM, AVG, MIN, MAX | ⏳ Upcoming |
| Day 6 | GROUP BY + HAVING | ⏳ Upcoming |
| Day 7 | Practice + Mini Project | ⏳ Upcoming |
| Day 8-14 | JOINs, Subqueries, UNION | ⏳ Upcoming |
| Day 15-21 | Window Functions, CTEs, CASE WHEN | ⏳ Upcoming |
| Day 22-30 | Query Optimization, Indexes, Normalization, Mock Interviews | ⏳ Upcoming |

---

## How to Run

1. Install MySQL Community Server (free) from mysql.com
2. Install MySQL Workbench (GUI)
3. Run `day1_setup.sql` first — creates the database and loads data
4. Run any other day's file using `Ctrl + Shift + Enter` in Workbench

Each file is **fully rerunnable** — uses `DROP TABLE IF EXISTS` and
`CREATE DATABASE IF NOT EXISTS` so you never get duplicate errors.

---

## Tech Stack

- MySQL 8.0
- MySQL Workbench
- Python + Pandas (coming in later weeks for data analysis)

---

## Goal

**Target role:** AI Engineer / Data Scientist
**Target companies:** Mercari Japan, other top Japanese tech firms
**Target timeline:** July 2028

---

*Built with discipline. One day at a time.*

