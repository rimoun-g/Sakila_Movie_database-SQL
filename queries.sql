/*Questions solutions*/

/* Q1 - What is the number of movies in each family-friendly category?*/ 
WITH 
updated_cats AS 
	(SELECT fc.film_id, c.name
    FROM film_category fc
    JOIN category c
    ON c.category_id = fc.category_id), 
updated_qrental AS 
    (SELECT DISTINCT f.title AS film_title, uc.name, f.rental_duration, ntile(4) OVER 			(PARTITION BY f.rental_duration) AS standard_quartile
    FROM film f
    JOIN updated_cats uc
    ON uc.film_id = f.film_id
    WHERE uc.name IN ('Family', 'Children', 'Music', 'Animation', 'Comedy','Games')
    ORDER BY 4,3)

SELECT name, count(*)
FROM updated_qrental
GROUP BY 1
ORDER BY 2;


/*  Q2 - What is the number of rental orders for each store per month?*/
SELECT Date_TRUNC('month', r.rental_date) Rental_month, i.store_id, COUNT(*) Count_rentals
FROM rental r
LEFT JOIN inventory i
ON i.inventory_id = r.inventory_id
GROUP BY 1,2
ORDER BY 3 DESC;



/* Q3 - What is the number total number of rentals for the top 10 customers based on the highest rental orders per month?*/

WITH 
top_10 AS 
	(SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) fullname, COUNT(*) 		pay_countpermon, SUM(p.amount)
	FROM payment p
	JOIN customer c
	ON p.customer_id = c.customer_id
	GROUP BY 1,2
	ORDER BY 3 DESC, 2
	LIMIT 10)

SELECT fullname, SUM(pay_countpermon)
FROM (SELECT DATE_TRUNC('month', p.payment_date) pay_mon, t.fullname, COUNT(DATE_TRUNC('month', p.payment_date)) pay_countpermon, SUM(p.amount)
FROM payment p
JOIN top_10 t
ON p.customer_id = t.customer_id
GROUP BY 1,2                                       
ORDER BY 2,3 DESC) sub
GROUP BY 1
ORDER BY 2 DESC;



/*  Q4 - Who are the customers with highest difference in rental orders from a month to another?*/
WITH
top_10 AS
	(SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) fullname, COUNT(*) 		pay_countpermon, SUM(p.amount) total_rents
	FROM payment p
	JOIN customer c
	ON p.customer_id = c.customer_id
	GROUP BY 1,2
	ORDER BY 3 DESC, 2
	LIMIT 10)

SELECT DATE_TRUNC('month', p.payment_date) pay_mon, t.fullname, COUNT(DATE_TRUNC('month', p.payment_date)) pay_countpermon, SUM(p.amount), SUM(p.amount) - LAG(SUM(p.amount)) OVER (PARTITION BY t.fullname ORDER BY DATE_TRUNC('month', p.payment_date)) difference
FROM payment p
JOIN top_10 t
ON p.customer_id = t.customer_id
GROUP BY 1,2;   


