-- Task 6: Layered CTEs for Readability

WITH order_revenue AS (
    SELECT
        orders.id AS order_id,
        orders.customer_id,

        SUM(
            order_items.quantity * order_items.unit_price
        ) AS total_order_revenue

    FROM orders

    JOIN order_items
        ON order_items.order_id = orders.id

    WHERE orders.status = 'delivered'

    GROUP BY
        orders.id,
        orders.customer_id
),

customer_revenue AS (
    SELECT
        customers.id AS customer_id,
        customers.name AS customer_name,
        customers.country,

        SUM(
            order_revenue.total_order_revenue
        ) AS total_customer_revenue

    FROM customers

    JOIN order_revenue
        ON order_revenue.customer_id = customers.id

    GROUP BY
        customers.id,
        customers.name,
        customers.country
),

country_average_revenue AS (
    SELECT
        country,

        AVG(
            total_customer_revenue
        ) AS average_customer_revenue

    FROM customer_revenue

    GROUP BY country
)

SELECT
    customer_revenue.country,
    customer_revenue.customer_name,
    customer_revenue.total_customer_revenue,
    country_average_revenue.average_customer_revenue

FROM customer_revenue

JOIN country_average_revenue
    ON country_average_revenue.country =
       customer_revenue.country

WHERE
    customer_revenue.total_customer_revenue >
    country_average_revenue.average_customer_revenue

ORDER BY
    customer_revenue.country,
    customer_revenue.total_customer_revenue DESC;
