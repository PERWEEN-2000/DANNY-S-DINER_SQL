create database challange1
use challange1;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
product_id INTEGER
);
insert into sales
(customer_id,order_date,product_id)
VALUES
("A", "2021-01-01", 1),
  ("A", "2021-01-01", 2),
  ("A", "2021-01-07", 2),
  ("A", "2021-01-10", 3),
  ("A", "2021-01-11", 3),
  ("A", "2021-01-11", 3),
  ("B", "2021-01-01", 2),
  ("B", "2021-01-02", 2),
  ("B", "2021-01-04", 1),
  ("B", "2021-01-11", 1),
  ("B", "2021-01-16", 3),
  ("B", "2021-02-01", 3),
  ("C", "2021-01-01", 3),
  ("C", "2021-01-01", 3),
  ("C", "2021-01-07", 3);
  
  create table menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- CASE STUDY QUESTIONS--
  
  -- 1 What is the total amount each customer spent at the restaurant?
  SELECT s.customer_id, sum(m.price) as Total_Amt_spent
  FROM sales s inner join menu m using(product_id)
  group by 1;
  
-- 2 How many days has each customer visited the restaurant?
select  customer_id,count(*) as no_of_days_visited
from sales
group by customer_id;

-- 3 What was the first item from the menu purchased by each customer?
with first_item as (select distinct s.customer_id,m.product_name,s.order_date,
dense_rank() over(partition by customer_id order by order_date asc) as first_item_purchased
from menu m inner join sales s using(product_id))
select customer_id,product_name
from first_item 
where first_item_purchased = 1;

-- 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,s.product_id,count(s.product_id) as most_purchased_item
from sales s inner join menu m using(product_id)
group by 1,2
order by 3 desc
limit 1;
-- 5 Which item was the most popular for each customer?
with popular as(
select s.customer_id,m.product_name,count(*) as no_of_orders,
dense_rank() over(partition by customer_id order by count(*) desc) as popular_item
from sales s inner join menu m using(product_id)
group by 1,2)
select customer_id,product_name
from popular
where popular_item=1;

-- 6 Which item was purchased first by the customer after they became a member?
with purchased as (
select m.customer_id,u.product_name,s.product_id,
row_number() over (partition by customer_id order by s.order_date desc) as row_num
from sales s  inner join members m using(customer_id) inner join menu u using (product_id)
where s.order_date> m.join_date)
select customer_id,product_name
from purchased
where row_num =1
order by customer_id asc;

-- 7 Which item was purchased just before the customer became a member?
with purchased_P as (
select m.customer_id,u.product_name,s.product_id,
row_number() over (partition by customer_id order by s.order_date desc) as row_num
from sales s  inner join members m using(customer_id) inner join menu u using (product_id)
where order_date < join_date)
select customer_id,product_name
from purchased_P
where row_num =1
order by customer_id asc;

-- 8 What is the total items and amount spent for each member before they became a member?
select customer_id, count(*) as total_item , sum(u.price) as total_amt
from members m inner join sales s using (customer_id) inner join menu u using (product_id) 
where order_date < join_date
group by 1
order by customer_id asc;

-- 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
-- how many points would each customer have?
  with point as(select customer_id, product_name,price,
                if(product_name="sushi", price*20, price*10) as total_points
from sales s inner join menu m using(product_id))
select customer_id, sum(total_points) as points
from point
group by 1;

-- 10 In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?
with  point as(select *,case
when order_date- join_date>=0 and order_date-join_date<=6 then (price*20)
when product_name = "sushi" then price*20
else price*10
end as points
from sales inner join members using (customer_id) inner join menu using (product_id)
where month(order_date)= 01)
select customer_id, sum(points) as totalpoints
from point
group by 1
order by 1;