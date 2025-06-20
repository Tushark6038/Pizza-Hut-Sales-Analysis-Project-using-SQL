use pizzahut;
create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id) );
-- Note: For all csv files we have used Import Table Wizard 


-- Questions :
-- Retrieve the total number of orders placed. 

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;
    
    
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM((order_details.quantity * pizzas.price)),
            2) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;



-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;



-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY SUM(order_details.quantity) DESC;



-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) as Hour, COUNT(order_id) as Order_count
FROM
    orders
GROUP BY HOUR(orders.time);



-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category; 



-- Group the orders by date and calculate the average number of pizzas ordered per day.


SELECT 
    ROUND(AVG(quantity), 0) AS Avg_Order_Quantity
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;
    
    
    
-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc limit 3;



-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM((order_details.quantity * pizzas.price)),
                                2) AS Total_Sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;




-- Analyze the cumulative revenue generated over time.


select date, sum(revenue) over (order by date) as cum_revenue from
(select orders.date, sum(order_details.quantity * pizzas.price) as revenue 
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.date
order by orders.date) as sales;




-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select category, name,revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id 
group by pizza_types.category, pizza_types.name
order by revenue desc) as sales) as a
where rn<=3;
