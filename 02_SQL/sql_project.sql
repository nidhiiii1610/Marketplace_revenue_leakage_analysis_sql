Task 1

What is the total sales revenue, total cost, and total profit of the marketplace across all orders?

select 
sum(o.selling_price * o.quantity) as total_revenue, 
 ROUND(SUM((o.selling_price - p.cost_price) * o.quantity - COALESCE(d.discount_amount,0) 
	   - COALESCE(l.shipping_cost,0)
	   - COALESCE(l.reverse_shipping_cost,0) 
	   - (o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100 ),2)
	   As total_profit, 
	   SUM(p.cost_price * o.quantity)    
        AS total_cost
    FROM orders_v2 o
    JOIN products_v2 p 
        ON p.product_id = o.product_id
 LEFT JOIN discounts_v2 d
        ON o.order_id = d.order_id
		LEFT JOIN logistics_cost_v2 l
		ON l.order_id = o.order_id
		LEFT JOIN payment_fees_v2 y
		ON y.payment_method = o.payment_method;

--------------------------------

Task 2:-
For each product category, what are the total sales, total cost, and total profit?

select p.category, sum(o.selling_price * o.quantity) as total_sales,
SUM(p.cost_price * o.quantity)  as total_cost,
ROUND(SUM((o.selling_price - p.cost_price) * o.quantity - COALESCE(l.shipping_cost, 0) - COALESCE(d.discount_amount, 0) 
- (o.selling_price * o.quantity) * COALESCE(y.fee_percentage,0)/100 - COALESCE(l.reverse_shipping_cost,0)),2) as total_profit
from orders_v2 o JOIN products_v2 p 
ON p.product_id = o.product_id
LEFT JOIN discounts_v2 d 
ON o.order_id = d.order_id
LEFT JOIN payment_fees_v2 y
ON y.payment_method = o.payment_method
LEFT JOIN logistics_cost_v2 l 
ON o.order_id = l.order_id
group by p.category;

--------------------------------------------------------
Task 3

Which products have generated negative total profit across all orders?

select p.product_id,p.category,
ROUND(SUM(
    (o.selling_price - p.cost_price) * o.quantity 
    - COALESCE(l.shipping_cost, 0) 
    - COALESCE(l.reverse_shipping_cost, 0)
    - COALESCE(d.discount_amount, 0) 
    - (o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100),2
) AS total_profit
from orders_v2 o JOIN products_v2 p 
ON p.product_id = o.product_id
LEFT JOIN discounts_v2 d 
ON o.order_id = d.order_id
LEFT JOIN payment_fees_v2 y
ON y.payment_method = o.payment_method
LEFT JOIN logistics_cost_v2 l 
ON o.order_id = l.order_id
group by p.product_id
Having 
SUM(
    (o.selling_price - p.cost_price) * o.quantity 
    - COALESCE(l.shipping_cost, 0) 
    - COALESCE(l.reverse_shipping_cost, 0)
    - COALESCE(d.discount_amount, 0) 
    - (o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100
) < 0;

--------------------------------------------------------
Task 4
How many orders received a discount, and
what is the total discount amount applied across the marketplace?

select count(DISTINCT order_id) as total_number_of_orders_with_discount, 
sum(discount_amount) as total_discount_amount from discounts_v2;

------------

Task 5
How many orders and how much sales value comes from each payment method?

select payment_method, count(order_id) as count_of_orders, SUM(selling_price * quantity) as sales
from orders_v2
group by payment_method;

select * from payment_fees_v2
select * from orders_v2
select * from products_v2

ALTER TABLE orders_v2
ALTER COLUMN selling_price TYPE INT
USING selling_price::INT;

-------------------

Task 6
Question:
How does average profit per order differ between discounted orders and non-discounted orders?

--Profit per order on discounted orders 
--= Profit - discount - shipping_cost - reverse_shipping_cost- fees percent (calculated based on total
 --price of order do multiplied selling_price with qty and then fees_percent

 --Profit per order on non-discounted orders 
--= Profit - shipping_cost - reverse_shipping_cost- fees percent (calculated based on total
 --price of order do multiplied selling_price with qty and then fees_percent

select * from discounts_v2

WITH discounted AS (
    SELECT 
        o.order_id, 
       SUM((o.selling_price - p.cost_price) * o.quantity - COALESCE(d.discount_amount,0) 
	   - COALESCE(l.shipping_cost,0)
	   - COALESCE(l.reverse_shipping_cost,0) 
	 - (o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100 )
	   As total_profit_discounted
    FROM orders_v2 o
    JOIN products_v2 p 
        ON p.product_id = o.product_id
 LEFT JOIN discounts_v2 d
        ON o.order_id = d.order_id
		LEFT JOIN logistics_cost_v2 l
		ON l.order_id = o.order_id
		LEFT JOIN payment_fees_v2 y
		ON y.payment_method = o.payment_method
      WHERE o.order_id IN (
        SELECT order_id 
        FROM discounts_v2 
        WHERE discount_amount > 0)
    GROUP BY o.order_id
),

non_discounted AS (
    SELECT 
        o.order_id, 
        SUM((o.selling_price - p.cost_price) * o.quantity 
	   - COALESCE(l.shipping_cost,0)
	   - COALESCE(l.reverse_shipping_cost,0) 
	 -(o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100) AS total_profit_non_discounted
    FROM orders_v2 o
    JOIN products_v2 p 
        ON p.product_id = o.product_id
		 LEFT JOIN discounts_v2 d
        ON o.order_id = d.order_id
		LEFT JOIN logistics_cost_v2 l
		ON l.order_id = o.order_id
		LEFT JOIN payment_fees_v2 y
		ON y.payment_method = o.payment_method	
	  WHERE o.order_id NOT IN (
    SELECT order_id
    FROM discounts_v2 d 
    WHERE d.order_id = o.order_id 
      AND d.discount_amount > 0)
    GROUP BY o.order_id
)
SELECT 
    (SELECT AVG(total_profit_discounted) FROM discounted) AS discounted_avg_profit,
    (SELECT AVG(total_profit_non_discounted) FROM non_discounted) AS non_discounted_avg_profit;

----------------------------------

Task 7

What is the total revenue and profit lost due to returned orders?

select 
sum(o.selling_price * o.quantity) as total_revenue_lost, 
sum((o.selling_price - p.cost_price) * o.quantity - COALESCE(d.discount_amount,0) 
- COALESCE(l.shipping_cost, 0) - COALESCE(l.reverse_shipping_cost,0) 
- (o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100 )
AS total_profit_lost
from orders_v2 o JOIN products_v2 p 
ON o.product_id = p.product_id
LEFT JOIN returns_v2 r
ON r.order_id = o.order_id
LEFT JOIN logistics_cost_v2 l
ON l.order_id = o.order_id
LEFT JOIN discounts_v2 d
ON o.order_id = d.order_id
LEFT JOIN payment_fees_v2 y
ON y.payment_method = o.payment_method
where r.return_flag = 'Y';

----------------------------------------

Task 8

For each return reason, how many returns occurred and how much revenue was lost?

select * from returns_v2

select r.return_reason, count(r.return_id), SUM(o.selling_price * o.quantity) from returns_v2 r JOIN orders_v2 o
ON o.order_id = r.order_id
where r.return_flag = 'Y'
group by r.return_reason;

-----------------------------------------
Task 9: Logistics Cost Burden
Question:
Which orders have logistics cost (shipping + reverse shipping) greater than 20% of order value?

select l.order_id, SUM(
COALESCE(l.shipping_cost,0) 
+ COALESCE(l.reverse_shipping_cost,0)) as logistics_cost,
SUM(o.selling_price * o.quantity) as order_value, 
SUM(
(o.selling_price * o.quantity)
*20/100.00) as twenty_per_of_order_value
FROM orders_v2 o
LEFT JOIN logistics_cost_v2 l ON l.order_id = o.order_id
WHERE o.selling_price > 0 AND o.quantity > 0 -------added this to avoid order value giving 0 in the output
group by l.order_id
having SUM(
COALESCE(l.shipping_cost,0) + COALESCE(l.reverse_shipping_cost,0))
 > SUM(
(o.selling_price * o.quantity) 
*20/100.00)
order by logistics_cost DESC;
---------------------------------------------------------------
Task 10
How much total payment gateway fee is paid for each payment method, and how does it affect net profit?

select * from payment_fees_v2

select y.payment_method , 
 SUM(
        ((o.selling_price * o.quantity) - COALESCE(d.discount_amount, 0)) 
        * COALESCE(y.fee_percentage, 0) / 100
    ) AS total_payment_fee,
 SUM(
        (o.selling_price - p.cost_price) * o.quantity 
        - COALESCE(l.shipping_cost,0) 
        - COALESCE(l.reverse_shipping_cost,0)  
        - (
            ((o.selling_price * o.quantity) - COALESCE(d.discount_amount, 0)) 
            * COALESCE(y.fee_percentage, 0) / 100
          )
        - COALESCE(d.discount_amount)
    ) AS Net_Profit
from 
orders_v2 o LEFT JOIN discounts_v2 d
ON o.order_id = d.order_id
JOIN products_v2 p
ON o.product_id = p.product_id
LEFT JOIN payment_fees_v2 y
ON y.payment_method = o.payment_method
LEFT JOIN logistics_cost_v2 l
ON l.order_id = o.order_id
group by y.payment_method;

---------------------------------------------------------------------------------


Task 11

For each order, calculate how much value is lost due to discounts, returns, 
logistics cost, and payment fees, and identify which factor causes the highest leakage overall.

SELECT 
    o.order_id, 

    SUM(COALESCE(d.discount_amount,0)) AS discount_amount_leakage, 

    SUM(
        COALESCE(l.shipping_cost,0) + COALESCE(l.reverse_shipping_cost,0)
    ) AS total_logistic_leakage, 

    SUM(
        ((o.selling_price * o.quantity) - COALESCE(d.discount_amount,0)) 
        * COALESCE(y.fee_percentage,0)/100
    ) AS payment_fees, 

    SUM(
        CASE 
            WHEN r.return_flag = 'Y' 
            THEN (o.selling_price * o.quantity) - COALESCE(d.discount_amount,0)
            ELSE 0
        END
    ) AS return_leakage
FROM orders_v2 o
LEFT JOIN discounts_v2 d ON o.order_id = d.order_id
JOIN products_v2 p ON o.product_id = p.product_id
LEFT JOIN returns_v2 r ON o.order_id = r.order_id
LEFT JOIN payment_fees_v2 y ON y.payment_method = o.payment_method
LEFT JOIN logistics_cost_v2 l ON l.order_id = o.order_id
GROUP BY o.order_id;

---------------------------------------------------------------------------

Task 13:- Which categories show high variation in profit margins across orders compared to others?

With order_margins AS (
    Select 
        p.category,o.order_id,
        (o.selling_price * o.quantity) AS revenue,
		(
            (o.selling_price - p.cost_price) * o.quantity
            - COALESCE(d.discount_amount, 0)
            - COALESCE(l.shipping_cost, 0)
            - COALESCE(l.reverse_shipping_cost, 0)
            - ((o.selling_price * o.quantity) - COALESCE(d.discount_amount, 0)) 
              * COALESCE(y.fee_percentage, 0) / 100
        ) AS profit

    from orders_v2 o
    join products_v2 p ON p.product_id = o.product_id
    left join discounts_v2 d ON o.order_id = d.order_id
    left join logistics_cost_v2 l ON o.order_id = l.order_id
    left join payment_fees_v2 y ON y.payment_method = o.payment_method
)

SELECT 
    category,
    ROUND(AVG(profit / NULLIF(revenue, 0)*100), 2) AS avg_profit_margin

FROM order_margins
GROUP BY category
ORDER BY avg_profit_margin DESC;

---------------------------------------------------

Task 12:
Rank all products based on net profit contribution, from highest to lowest.

Select p.product_id,
SUM(
(o.selling_price - p.cost_price) * o.quantity 
- COALESCE(d.discount_amount,0)
-COALESCE(l.shipping_cost,0)
-COALESCE(l.reverse_shipping_cost,0)
- ((o.selling_price * o.quantity) - COALESCE(d.discount_amount)) * COALESCE(y.fee_percentage,0)/100)
as profit,
RANK() OVER( 
ORDER BY SUM(
(o.selling_price - p.cost_price) * o.quantity 
- COALESCE(d.discount_amount,0)
-COALESCE(l.shipping_cost)
-COALESCE(l.reverse_shipping_cost)
- ((o.selling_price * o.quantity) - COALESCE(d.discount_amount)) 
* COALESCE(y.fee_percentage,0)/100)
DESC) as ranking_products
 from orders_v2 o
    join products_v2 p ON p.product_id = o.product_id
    left join discounts_v2 d ON o.order_id = d.order_id
    left join logistics_cost_v2 l ON o.order_id = l.order_id
    left join payment_fees_v2 y ON y.payment_method = o.payment_method)
	GROUP BY p.product_id
ORDER BY ranking_products ASC;

-----------------------------------------------------------------------------

SELECT
  p.product_id,
  SUM(
    (o.selling_price - p.cost_price) * o.quantity
    - COALESCE(d.discount_amount, 0)
    - COALESCE(l.shipping_cost, 0)
    - COALESCE(l.reverse_shipping_cost, 0)
    - ((o.selling_price * o.quantity)
       - COALESCE(d.discount_amount, 0))
       * COALESCE(y.fee_percentage, 0) / 100
  ) AS profit
FROM orders_v2 o
JOIN products_v2 p       ON p.product_id    = o.product_id
LEFT JOIN discounts_v2 d      ON o.order_id = d.order_id
LEFT JOIN logistics_cost_v2 l ON o.order_id = l.order_id
LEFT JOIN payment_fees_v2 y   ON y.payment_method = o.payment_method
GROUP BY p.product_id
ORDER BY profit DESC;
--------------------------------------------------------------------------------------
	
Task 14: High-Risk Customers

Which customers have a return rate significantly higher than the marketplace average?

Forumala used:- Return Rate % = (Total Returns / Total Orders) × 100


With customer_return_rate 
AS(
select o.customer_id, count(r.return_id),
ROUND
(
count(r.return_id)*100 
/NULLIF(count(o.order_id),0),2
)as return_rate
FROM orders_v2 o LEFT JOIN returns_v2 r 
ON o.order_id = r.order_id
group by o.customer_id),

marketplace_avg AS (
Select ROUND(AVG(return_rate),2) as avg_overall from customer_return_rate 
) 
Select c.customer_id, c.return_rate from customer_return_rate c CROSS JOIN marketplace_avg m
where c.return_rate > m.avg_overall
order by c.return_rate DESC;

----------------------------------------------------------------------------------------

Task 15:
Create a consolidated summary showing:
total sales
total profit
total discounts
total returns loss
total logistics cost
total payment fees

SELECT 

    -- Total Sales
    SUM(o.selling_price * o.quantity) AS total_revenue,

    -- Total Profit
    SUM(
        (o.selling_price - p.cost_price) * o.quantity 
        - COALESCE(d.discount_amount,0) 
        - COALESCE(l.shipping_cost,0)
        - COALESCE(l.reverse_shipping_cost,0) 
        - (o.selling_price * o.quantity) * COALESCE(y.fee_percentage, 0) / 100
    ) AS total_profit,

    -- Total Discount
    SUM(COALESCE(d.discount_amount,0)) AS total_discount,

    -- Total Return Leakage
    SUM(
        CASE 
            WHEN r.return_flag = 'Y' 
            THEN (o.selling_price * o.quantity) - COALESCE(d.discount_amount,0)
            ELSE 0
        END
    ) AS total_return_leakage,

    -- Total Logistics Cost
    SUM(
        COALESCE(l.shipping_cost,0) + COALESCE(l.reverse_shipping_cost,0)
    ) AS total_logistics_cost,

    -- Total Payment Fees
    SUM(
        ((o.selling_price * o.quantity) - COALESCE(d.discount_amount,0)) 
        * COALESCE(y.fee_percentage,0)/100
    ) AS total_payment_fees

FROM orders_v2 o
JOIN products_v2 p ON p.product_id = o.product_id
LEFT JOIN discounts_v2 d ON o.order_id = d.order_id
LEFT JOIN returns_v2 r ON o.order_id = r.order_id
LEFT JOIN logistics_cost_v2 l ON o.order_id = l.order_id
LEFT JOIN payment_fees_v2 y ON y.payment_method = o.payment_method;







