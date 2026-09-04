# Sprint 2: Database Setup

create database Project_Last_Mile_Delivery;

use Project_Last_Mile_Delivery;

create table customers(
customer_id varchar(20) primary key,
customer_name varchar(100) not null,
city varchar(50),
delivery_zone_id varchar(10),
preferred_time_slot varchar(30),
customer_type varchar(20) not null,
account_since Date not null
);


create table orders(
order_id varchar(20) primary key,
customer_id varchar(20),
order_date Date not null,
delivery_zone_id varchar(10),
package_weight_kg decimal(5,2) not null check (package_weight_kg > 0),
service_type varchar(20),
priority varchar(10),
total_value decimal(10,2) not null  check (total_value > 0),
foreign key (customer_id) references customers(customer_id)
);


create table drivers(
driver_id varchar(10) primary key,
driver_name varchar(100) not null,
hire_date date not null,
rating decimal(3,2) check (rating between 0 and 5),
employment_type varchar(20),
is_active varchar(3)
); 


create table vehicles(
vehicle_id varchar(10) primary key,
vehicle_type varchar(20) not null,
fuel_type varchar(20) not null,
max_payload_kg decimal(7,2) not null,
depot varchar(10),
last_service_date Date,
is_active varchar(3) not null check (is_active in ("Yes", "No"))
);


create table deliveries(
delivery_id varchar(20) primary key,
order_id varchar(20),
driver_id varchar(10),
vehicle_id varchar(10),
assigned_date Date ,
actual_delivery_date Date,
status varchar(20),
delivery_attempt tinyint,
distance_km decimal(6,2),
delivery_duration_min int,
foreign key (order_id) references orders(order_id),
foreign key (driver_id) references drivers(driver_id),
foreign key (vehicle_id) references vehicles(vehicle_id)
);

select * from customers;
select * from orders;
select * from drivers;
select * from vehicles;
select * from deliveries;

# Sprint 3: Basic Analysis / Data Exploration

-- 1.	What is the total number of customers?
select count(*) as Total_customers from customers;

-- 2.	What is the total number of orders?
select count(*) as Total_orders from orders;

-- 3.	What is the total number of deliveries?
select count(*) as total_deliveries from deliveries;

-- 4.	What are the different service types available?
select distinct service_type from orders;

-- 5.	How many drivers are currently active?
select count(*) as Currenctly_active from drivers where is_active = "Yes" ;

-- 6.	What are the different vehicle types?
select distinct vehicle_type from vehicles;

-- 7.	What is the total order value?
select sum(total_value) as Total from orders;

-- 8.	What is the average package weight?
select avg(package_weight_kg) as avg_weight_kg from orders;

# Sprint 4: Objective-Based Analysis

-- 4.1 Understand Delivery Demand
-- Business Objective: The Operations team wants to understand where and how delivery orders are being generated.

-- ●	Compare the number of orders across delivery zones.
select delivery_zone_id, count(order_id) as no_of_orders from orders group by delivery_zone_id order by no_of_orders desc;

-- ●	Compare orders across different service types.
select service_type, count(order_id) as count_service from orders group by service_type;

-- ●	Compare orders based on priority.
select priority, count(order_id) as No_of_priority from orders group by priority;

-- ●	Examine how order volume changes over time.
select order_date, count(order_id) as no_orders from orders group by order_date order by order_date;

-- ●	Look at order value across different groups.
select priority, sum(total_value) as total_order_value from orders group by priority;


-- 4.2 Understand Customer Order Behaviour
-- Business Objective: The Customer team wants to understand how customers are using the delivery service.

-- ●	Compare customers based on the number of orders they place.
select c.customer_id, count(o.order_id) as number_of_orders from customers as c
join orders as o
on c.customer_id = o.customer_id
group by  c.customer_id;

-- ●	Identify customers with higher total order value.
select c.customer_id, c.customer_name, sum(o.total_value) as higher_total_value
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
order by higher_total_value desc;

-- ●	Compare customer activity across delivery zones.
select delivery_zone_id, count(order_id) as customer_activity from orders
group by delivery_zone_id
order by customer_activity desc;

-- ●	Look at differences between business and individual customers.
select customer_type, count(customer_id) as no_of_customers from customers group by customer_type;

-- ●	Examine customer ordering patterns over time.
select year(order_date) as order_year, month(order_date) as order_month, count(order_id) as total_orders from orders
group by year(order_date), month(order_date) order by order_year, order_month; 


-- 4.3 Evaluate Delivery Performance
-- Business Objective: The Operations team wants to understand how well deliveries are being completed.

-- ●	Compare delivery outcomes across different zones (zone information is on the orders table, so you will need to connect orders and deliveries).
select o.delivery_zone_id, d.status, count(d.delivery_id) as total_delivery from deliveries as d
join orders as o
on o.order_id = d.order_id group by o.delivery_zone_id, d.status order by o.delivery_zone_id, total_delivery desc;

-- ●	Examine delivery duration.
select avg(delivery_duration_min) as avg_duration,
max(delivery_duration_min) as slowest_delivery,
min(delivery_duration_min) as fastest_delivery from deliveries;

-- ●	Compare delivery outcomes by status (Delivered, Failed, Pending, Rescheduled) — these are not a simple success/failure split, so consider what each status actually represents.
select status, count(delivery_id) from deliveries group by status;

-- ●	Identify areas with higher delivery activity or poorer outcomes.
select o.delivery_zone_id, count(d.delivery_id) AS total_deliveries from orders as o
join deliveries as d
on o.order_id = d.order_id
group by o.delivery_zone_id
order by total_deliveries desc;

-- ●	Compare delivery performance over time.
select year(actual_delivery_date) as delivery_year, month(actual_delivery_date) as delivery_month,
count(delivery_id) as total_deliveries
from deliveries
group by  year(actual_delivery_date), month(actual_delivery_date)
order by  delivery_year, delivery_month;


-- 4.4 Understand Driver and Vehicle Performance
-- Business Objective: The Operations team wants to understand how its delivery resources are being utilized and how they are performing.

-- ●	Compare the number of deliveries handled by drivers.
select dr.driver_id, dr.driver_name, count(d.delivery_id) no_of_deliveries from drivers as dr
join deliveries as d
on dr.driver_id = d.driver_id group by dr.driver_id, dr.driver_name order by no_of_deliveries desc;

-- ●	Compare driver performance across delivery outcomes.
select dr.driver_id, dr.driver_name, d.status, count(d.delivery_id) as total_deliveries from drivers as dr
join deliveries as d 
on dr.driver_id = d.driver_id
group by dr.driver_id, dr.driver_name, d.status
order by    dr.driver_id, total_deliveries desc;

-- ●  Examine delivery duration across drivers.
select dr.driver_id, dr.driver_name, avg(d.delivery_duration_min) as avg_delivery_duration
from drivers as dr
join deliveries as d
on dr.driver_id = d.driver_id
group by  dr.driver_id, dr.driver_name
order by avg_delivery_duration;

-- ●	Compare vehicle usage across different vehicle types.
select vehicle_type, count(vehicle_id) as total_vehicles from vehicles group by vehicle_type order by total_vehicles desc;

-- ●	Look at delivery performance across different vehicles.
select v.vehicle_type, count(d.status) from deliveries as d
join vehicles as v
on v.vehicle_id = d.vehicle_id group by v.vehicle_type;


-- 4.5 Identify Delivery Problems
-- Business Objective: The Operations team wants to understand why some deliveries require additional effort or fail to complete successfully.

-- ●	Examine which deliveries required multiple attempts before succeeding.
select delivery_id, max(delivery_attempt) as maximum_delivery from deliveries 
where status = "Delivered" 
group by delivery_id having maximum_delivery > 1;
 
-- ●	Identify common delivery statuses and problem patterns.
select status, count(delivery_id) AS problem_count
from deliveries
where status in ('Failed', 'Pending', 'Rescheduled',"Delivered")
group by status
order by problem_count desc;

-- ●	Compare delivery performance for orders with multiple attempts.
-- ●	Examine whether certain zones experience more delivery problems.

