-- Task 7: Recursive Category Tree

WITH RECURSIVE category_tree AS (

    -- Anchor query: select top-level categories
    SELECT
        id,
        name,
        parent_id,
        0 AS depth,
        name AS path,
        printf('%010d', id) AS sort_path

    FROM categories

    WHERE parent_id IS NULL

    UNION ALL

    -- Recursive query: select the children
    SELECT
        categories.id,
        categories.name,
        categories.parent_id,
        category_tree.depth + 1 AS depth,

        category_tree.path || ' > ' || categories.name
            AS path,

        category_tree.sort_path || '.' ||
        printf('%010d', categories.id)
            AS sort_path

    FROM categories

    JOIN category_tree
        ON categories.parent_id = category_tree.id
)

SELECT
    id,
    name,
    depth,
    path

FROM category_tree

ORDER BY sort_path;
