-- ================================================================
-- E-COMMERCE SALES ANALYSIS — Advanced SQL Mini Project
-- Day 6: Advanced SQL Belajar
-- Database: SQLite | Period: Jan 2023 – Jun 2024
-- Tables: categories, products, customers, orders, order_items
-- ================================================================

-- ================================================================
-- SCHEMA OVERVIEW
-- ================================================================
-- categories (category_id, category_name, department)
-- products   (product_id, product_name, category_id, cost_price, sell_price, stock_qty)
-- customers  (customer_id, full_name, city, province, gender, join_date, segment)
-- orders     (order_id, customer_id, order_date, status, payment_method, shipping_cost)
-- order_items(item_id, order_id, product_id, quantity, unit_price, discount_pct)


-- ================================================================
-- QUERY 1: Monthly Revenue & Profit Analysis
-- Skills: GROUP BY, DATE FUNCTIONS, AGGREGATE, ARITHMETIC
-- ================================================================
SELECT
    strftime('%Y-%m', o.order_date)            AS bulan,
    COUNT(DISTINCT o.order_id)                 AS total_order,
    COUNT(DISTINCT o.customer_id)              AS unique_customer,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS gross_revenue,
    ROUND(SUM(oi.quantity * p.cost_price), 0)  AS total_cogs,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0))
        - SUM(oi.quantity * p.cost_price), 0)  AS gross_profit,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0))
        - SUM(oi.quantity * p.cost_price))
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY bulan
ORDER BY bulan;


-- ================================================================
-- QUERY 2: Revenue by Category & Department
-- Skills: MULTI-TABLE JOIN, GROUP BY multiple columns
-- ================================================================
SELECT
    cat.department,
    cat.category_name,
    COUNT(DISTINCT oi.item_id)                 AS total_item_sold,
    SUM(oi.quantity)                           AS total_qty,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0))
        - SUM(oi.quantity * p.cost_price), 0)  AS profit,
    ROUND(AVG(oi.discount_pct), 2)             AS avg_discount_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.status = 'Completed'
GROUP BY cat.department, cat.category_name
ORDER BY revenue DESC;


-- ================================================================
-- QUERY 3: Top 10 Products by Revenue
-- Skills: JOIN, GROUP BY, ORDER BY, LIMIT
-- ================================================================
SELECT
    p.product_name,
    cat.category_name,
    SUM(oi.quantity)                           AS total_qty_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0))
        - SUM(oi.quantity * p.cost_price), 0)  AS profit,
    ROUND(AVG(oi.discount_pct),1)              AS avg_disc
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.status = 'Completed'
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 10;


-- ================================================================
-- QUERY 4: Customer Segmentation Revenue Analysis
-- Skills: SUBQUERY, JOIN, GROUP BY
-- ================================================================
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id)              AS total_customer,
    COUNT(DISTINCT o.order_id)                 AS total_order,
    ROUND(AVG(sub.cust_revenue),0)             AS avg_revenue_per_cust,
    ROUND(SUM(sub.cust_revenue),0)             AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
JOIN (
    SELECT o2.customer_id,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS cust_revenue
    FROM orders o2
    JOIN order_items oi ON o2.order_id = oi.order_id
    WHERE o2.status = 'Completed'
    GROUP BY o2.customer_id
) sub ON sub.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_revenue DESC;


-- ================================================================
-- QUERY 5: RFM Analysis (Recency, Frequency, Monetary)
-- Skills: CTE, WINDOW FUNCTION (NTILE), CASE WHEN, Date arithmetic
-- ================================================================
WITH cust_rfm AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.segment,
        MAX(o.order_date)                          AS last_order_date,
        julianday('2024-07-01') - julianday(MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id)                 AS frequency,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS monetary
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)    AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)     AS m_score
    FROM cust_rfm
)
SELECT
    customer_id, full_name, segment,
    ROUND(recency_days,0)  AS recency_days,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2        THEN 'New Customers'
        WHEN r_score <= 2 AND m_score >= 4        THEN 'At Risk'
        WHEN (r_score + f_score + m_score) <= 6   THEN 'Lost Customers'
        ELSE 'Potential Loyalist'
    END AS rfm_label
FROM rfm_scored
ORDER BY rfm_total DESC;


-- ================================================================
-- QUERY 6: Revenue by Province
-- Skills: JOIN, GROUP BY, ORDER BY
-- ================================================================
SELECT
    c.province,
    COUNT(DISTINCT o.order_id)                 AS total_order,
    COUNT(DISTINCT c.customer_id)              AS unique_customer,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0))
        / COUNT(DISTINCT o.order_id), 0)       AS avg_order_value
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.province
ORDER BY revenue DESC;


-- ================================================================
-- QUERY 7: Payment Method Performance
-- Skills: JOIN, GROUP BY, AVG aggregate
-- ================================================================
SELECT
    o.payment_method,
    COUNT(DISTINCT o.order_id)                 AS total_order,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS revenue,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0) AS avg_item_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY o.payment_method
ORDER BY total_order DESC;


-- ================================================================
-- QUERY 8: Order Status & Cancellation Rate
-- Skills: GROUP BY, SUBQUERY dalam SELECT, percentage calculation
-- ================================================================
SELECT
    status,
    COUNT(*) AS total_order,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct
FROM orders
GROUP BY status
ORDER BY total_order DESC;


-- ================================================================
-- QUERY 9: Cohort Retention Analysis
-- Skills: CTE, julianday(), GROUP BY multiple, self-join pattern
-- ================================================================
WITH first_order AS (
    SELECT customer_id, MIN(strftime('%Y-%m', order_date)) AS cohort_month
    FROM orders WHERE status='Completed' GROUP BY customer_id
),
monthly_orders AS (
    SELECT o.customer_id, strftime('%Y-%m', o.order_date) AS order_month
    FROM orders o WHERE o.status='Completed'
)
SELECT
    f.cohort_month,
    m.order_month,
    COUNT(DISTINCT m.customer_id) AS retained_customers,
    CAST(
        (julianday(m.order_month || '-01') - julianday(f.cohort_month || '-01')) / 30
    AS INTEGER) AS months_since_join
FROM first_order f
JOIN monthly_orders m ON f.customer_id = m.customer_id
GROUP BY f.cohort_month, m.order_month
ORDER BY f.cohort_month, m.order_month;


-- ================================================================
-- QUERY 10: Discount Impact Analysis
-- Skills: CASE WHEN bucketing, multi-aggregate, margin analysis
-- ================================================================
SELECT
    CASE
        WHEN oi.discount_pct = 0        THEN '0% (No Discount)'
        WHEN oi.discount_pct <= 5       THEN '1-5%'
        WHEN oi.discount_pct <= 10      THEN '6-10%'
        WHEN oi.discount_pct <= 15      THEN '11-15%'
        ELSE '16%+'
    END AS discount_bucket,
    COUNT(*)                            AS total_items,
    SUM(oi.quantity)                    AS total_qty,
    ROUND(AVG(oi.quantity),2)           AS avg_qty_per_item,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)),0) AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * oi.discount_pct/100.0),0)       AS discount_given,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0))
        - SUM(oi.quantity * p.cost_price), 0) AS profit
FROM order_items oi
JOIN orders o   ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY discount_bucket
ORDER BY discount_given DESC;

-- ================================================================
-- END OF QUERIES
-- SQL Skills Demonstrated:
--   ✅ Multi-table JOIN (INNER JOIN, self-join via CTE)
--   ✅ Aggregate Functions: SUM, AVG, COUNT, ROUND
--   ✅ GROUP BY with HAVING
--   ✅ CTE (Common Table Expression) — WITH clause
--   ✅ Window Functions — NTILE(5) OVER (ORDER BY ...)
--   ✅ CASE WHEN — conditional bucketing & labeling
--   ✅ Subquery in FROM and WHERE clauses
--   ✅ Date Functions — strftime(), julianday()
--   ✅ LIMIT & ORDER BY
--   ✅ Arithmetic: Revenue, COGS, Profit, Margin %
-- ================================================================
