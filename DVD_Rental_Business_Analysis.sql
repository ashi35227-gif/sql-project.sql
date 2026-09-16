-- ============================================================
-- DVD RENTAL BUSINESS ANALYSIS
-- PostgreSQL | pgAdmin 4
-- ============================================================


-- ============================================================
-- Q1. How many customers are there?
-- ============================================================

SELECT COUNT(*) AS total_customers
FROM customer;


-- ============================================================
-- Q2. How many movies are there?
-- ============================================================

SELECT COUNT(*) AS total_movies
FROM film;


-- ============================================================
-- Q3. How many rentals have been made?
-- ============================================================

SELECT COUNT(*) AS total_rentals
FROM rental;


-- ============================================================
-- Q4. What are the 10 most expensive movies based on rental rate?
-- ============================================================

SELECT
    film_id,
    title,
    rental_rate
FROM film
ORDER BY rental_rate DESC
LIMIT 10;


-- ============================================================
-- Q5. What are the 10 longest movies?
-- ============================================================

SELECT
    film_id,
    title,
    length
FROM film
ORDER BY length DESC
LIMIT 10;


-- ============================================================
-- Q6. How many movies are there in each category?
-- ============================================================

SELECT
    c.name AS category,
    COUNT(f.film_id) AS number_of_movies
FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY number_of_movies DESC;


-- ============================================================
-- Q7. What are the 10 most rented movies?
-- ============================================================

SELECT
    f.title,
    COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY rental_count DESC
LIMIT 10;


-- ============================================================
-- Q8. What are the top 10 movies by rental revenue?
-- ============================================================

SELECT
    f.title,
    SUM(p.amount) AS total_revenue
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
JOIN payment p
    ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Q9. Which movies have never been rented?
-- ============================================================

SELECT
    f.film_id,
    f.title
FROM film f
LEFT JOIN inventory i
    ON f.film_id = i.film_id
LEFT JOIN rental r
    ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
ORDER BY f.title;


-- ============================================================
-- Q10. Which category has the highest number of rentals?
-- ============================================================

SELECT
    c.name AS category,
    COUNT(r.rental_id) AS total_rentals
FROM category c
JOIN film_category fc
    ON c.category_id = fc.category_id
JOIN inventory i
    ON fc.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY c.name
ORDER BY total_rentals DESC;


-- ============================================================
-- Q11. Which store generates more revenue?
-- ============================================================

SELECT
    i.store_id,
    SUM(p.amount) AS total_revenue
FROM inventory i
JOIN rental r
    ON i.inventory_id = r.inventory_id
JOIN payment p
    ON r.rental_id = p.rental_id
GROUP BY i.store_id
ORDER BY total_revenue DESC;


-- ============================================================
-- Q12. How much revenue does each movie category generate?
-- ============================================================

SELECT
    c.name AS category,
    SUM(p.amount) AS total_revenue
FROM category c
JOIN film_category fc
    ON c.category_id = fc.category_id
JOIN film f
    ON fc.film_id = f.film_id
JOIN inventory i
    ON f.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
JOIN payment p
    ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY total_revenue DESC;





select category.name, sum(payment.amount) as total_spend from category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN film
ON film_category.film_id = film.film_id
INNER JOIN inventory
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON rental.customer_id = payment.customer_id
GROUP BY  category.name
ORDER BY total_spend DESC;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spending
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) > 150
ORDER BY total_spending DESC;

SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount) AS total_revenue
FROM payment
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;


SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS total_rentals
FROM customer c
JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) > 30
ORDER BY total_rentals DESC;


SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spending,
    CASE
        WHEN SUM(p.amount) < 100 THEN 'Low Value'
        WHEN SUM(p.amount) <= 150 THEN 'Medium Value'
        ELSE 'High Value'
    END AS customer_segment
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spending DESC;


SELECT
    c.name AS category,
    AVG(f.rental_rate) AS average_rental_rate
FROM category c
JOIN film_category fc
    ON c.category_id = fc.category_id
JOIN film f
    ON fc.film_id = f.film_id
GROUP BY c.name
HAVING AVG(f.rental_rate) > 2.50
ORDER BY average_rental_rate DESC;


SELECT
    DATE_TRUNC('month', rental_date) AS month,
    COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY DATE_TRUNC('month', rental_date)
ORDER BY month;


SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(p.amount) DESC
    ) AS spending_rank
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY spending_rank;

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.store_id,
        SUM(p.amount) AS total_spending
    FROM customer c
    JOIN payment p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.store_id
),

ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY store_id
            ORDER BY total_spending DESC
        ) AS customer_rank
    FROM customer_spending
)

SELECT
    store_id,
    customer_id,
    first_name,
    last_name,
    total_spending,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY store_id, customer_rank;


WITH movie_rentals AS (
    SELECT
        c.name AS category,
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rental_count
    FROM category c
    JOIN film_category fc
        ON c.category_id = fc.category_id
    JOIN film f
        ON fc.film_id = f.film_id
    JOIN inventory i
        ON f.film_id = i.film_id
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    GROUP BY
        c.name,
        f.film_id,
        f.title
),

ranked_movies AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY rental_count DESC
        ) AS movie_rank
    FROM movie_rentals
)

SELECT
    category,
    film_id,
    title,
    rental_count
FROM ranked_movies
WHERE movie_rank = 1
ORDER BY category;



SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS customer_revenue,
    ROUND(
        SUM(p.amount) * 100.0 /
        (SELECT SUM(amount) FROM payment),
        2
    ) AS revenue_contribution_percentage
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY revenue_contribution_percentage DESC;


SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL
ORDER BY c.customer_id;


SELECT
    f.film_id,
    f.title
FROM film f
LEFT JOIN inventory i
    ON f.film_id = i.film_id
LEFT JOIN rental r
    ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
ORDER BY f.title;



WITH spending AS (
    SELECT
        customer_id,
        SUM(amount) AS total_spending
    FROM payment
    GROUP BY customer_id
),

rentals AS (
    SELECT
        customer_id,
        COUNT(rental_id) AS total_rentals,
        MAX(rental_date) AS last_rental_date
    FROM rental
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(s.total_spending, 0) AS total_spending,
    COALESCE(r.total_rentals, 0) AS total_rentals,
    r.last_rental_date,
    CASE
        WHEN COALESCE(s.total_spending, 0) > 150
             AND COALESCE(r.total_rentals, 0) > 30
        THEN 'High Value'

        WHEN COALESCE(s.total_spending, 0) >= 100
             AND COALESCE(r.total_rentals, 0) >= 20
        THEN 'Medium Value'

        ELSE 'Low Value'
    END AS customer_segment
FROM customer c
LEFT JOIN spending s
    ON c.customer_id = s.customer_id
LEFT JOIN rentals r
    ON c.customer_id = r.customer_id
ORDER BY total_spending DESC;
