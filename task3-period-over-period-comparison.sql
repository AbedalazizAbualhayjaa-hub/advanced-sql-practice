-- Task 3: Period-over-Period Comparison

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', orders.order_date) AS revenue_month,

        SUM(
            order_items.quantity * order_items.unit_price
        ) AS total_revenue

    FROM orders

    JOIN order_items
        ON order_items.order_id = orders.id

    WHERE orders.status = 'delivered'

    GROUP BY
        strftime('%Y-%m', orders.order_date)
),

revenue_comparison AS (
    SELECT
        revenue_month,
        total_revenue,

        LAG(total_revenue) OVER (
            ORDER BY revenue_month
        ) AS previous_month_revenue,

        LEAD(total_revenue) OVER (
            ORDER BY revenue_month
        ) AS next_month_revenue

    FROM monthly_revenue
)

SELECT
    revenue_month,
    total_revenue,
    previous_month_revenue,
    next_month_revenue,

    total_revenue - previous_month_revenue
        AS absolute_change,

    CASE
        WHEN previous_month_revenue IS NULL
            OR previous_month_revenue = 0
        THEN NULL

        ELSE ROUND(
            (
                total_revenue - previous_month_revenue
            ) * 100.0 / previous_month_revenue,
            2
        )
    END AS percentage_change,

    CASE
        WHEN previous_month_revenue IS NULL
            THEN 'No previous month'

        WHEN total_revenue > previous_month_revenue
            THEN 'Grew'

        WHEN total_revenue < previous_month_revenue
            THEN 'Shrank'

        ELSE 'Stayed flat'
    END AS revenue_status

FROM revenue_comparison

ORDER BY revenue_month;
