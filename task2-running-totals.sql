-- Task 2: Running Totals

WITH daily_country_revenue AS (
    SELECT
        orders.order_date,
        customers.country,
        SUM(
            order_items.quantity * order_items.unit_price
        ) AS daily_revenue_by_country

    FROM orders

    JOIN customers
        ON customers.id = orders.customer_id

    JOIN order_items
        ON order_items.order_id = orders.id

    WHERE orders.status = 'delivered'

    GROUP BY
        orders.order_date,
        customers.country
),

daily_total_revenue AS (
    SELECT
        order_date,
        SUM(daily_revenue_by_country) AS daily_revenue_overall

    FROM daily_country_revenue

    GROUP BY order_date
),

overall_running_total AS (
    SELECT
        order_date,
        daily_revenue_overall,

        SUM(daily_revenue_overall) OVER (
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue_overall

    FROM daily_total_revenue
),

country_running_total AS (
    SELECT
        order_date,
        country,
        daily_revenue_by_country,

        SUM(daily_revenue_by_country) OVER (
            PARTITION BY country
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue_by_country

    FROM daily_country_revenue
)

SELECT
    country_running_total.order_date,
    country_running_total.country,
    country_running_total.daily_revenue_by_country,
    overall_running_total.daily_revenue_overall,
    overall_running_total.cumulative_revenue_overall,
    country_running_total.cumulative_revenue_by_country

FROM country_running_total

JOIN overall_running_total
    ON overall_running_total.order_date =
       country_running_total.order_date

ORDER BY
    country_running_total.order_date,
    country_running_total.country;
