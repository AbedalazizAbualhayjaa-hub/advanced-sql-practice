
-- Task 1: Ranking Within Groups

WITH customer_spending AS (
    SELECT
        customers.id AS customer_id,
        customers.country,
        customers.name AS customer_name,
        COALESCE(
            SUM(order_items.quantity * order_items.unit_price),
            0
        ) AS total_spent
    FROM customers
    LEFT JOIN orders
        ON orders.customer_id = customers.id
        AND orders.status = 'delivered'
    LEFT JOIN order_items
        ON order_items.order_id = orders.id
    GROUP BY
        customers.id,
        customers.country,
        customers.name
)

SELECT
    country,
    customer_name,
    total_spent,

    RANK() OVER (
        PARTITION BY country
        ORDER BY total_spent DESC
    ) AS spending_rank,

    DENSE_RANK() OVER (
        PARTITION BY country
        ORDER BY total_spent DESC
    ) AS dense_spending_rank,

    ROW_NUMBER() OVER (
        PARTITION BY country
        ORDER BY total_spent DESC, customer_id
    ) AS row_number

FROM customer_spending
ORDER BY
    country,
    spending_rank,
    customer_name;
