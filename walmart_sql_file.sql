-- create database if not exists walmart;

-- CREATE TABLE IF NOT EXISTS Sales (
--   invoice_id VARCHAR(255) NOT NULL PRIMARY KEY,
--   branch VARCHAR(255) NOT NULL,
--   city VARCHAR(255) NOT NULL,
--   customer_type VARCHAR(255) NOT NULL,
--   gender VARCHAR(255) NOT NULL,
--   product_line VARCHAR(255) NOT NULL,
--   unit_price DECIMAL(12, 2) NOT NULL,
--   quantity INT NOT NULL,
--   tax_pct FLOAT NOT NULL,
--   total DECIMAL(14, 4) NOT NULL,
--   date DATETIME NOT NULL,
--   time TIME NOT NULL,
--   payment VARCHAR(255) NOT NULL,
--   cogs DECIMAL(12, 2) NOT NULL,
--   gross_margin_pct FLOAT NOT NULL,
--   gross_income DECIMAL(14, 4) NOT NULL,
--   rating FLOAT NOT NULL
-- );
-- ALTER TABLE sales
-- MODIFY COLUMN Date Date;
-- update sales
-- set Date = str_to_date(Date,'%Y-%m-%d')
-- MODIFY COLUMN Time Time;

-- adding new columns from existing ones
-- add time_of_day
select time,
case when time between '00:00:00' and '12:00:00' then 'Morning'
when time between '12:01:00' and '17:00:00' then 'Afternoon'
else 'Evening'
end as 'time_of_day'
 from sales;

alter table sales
add column time_of_day varchar(255);

update sales
set time_of_day = (
case when time between '00:00:00' and '12:00:00' then 'Morning'
when time between '12:01:00' and '17:00:00' then 'Afternoon'
else 'Evening'
end 
);

-- add month_name
select date,monthname(date) as month_name from sales;

alter table sales
add column month_name varchar(255);

update sales
set month_name = monthname(date);

-- add day_name
alter table sales
add column day_name varchar(255);

update sales
set day_name = dayname(date);

-- EDA
-- generic questions
-- 1.how many unique cities does the data have
select distinct city from sales;

-- 2.in which city is each branch
select distinct city,branch from sales

-- product questions
-- 1.how many product lines does the data have
select count(distinct product_line) from sales

-- 2.what is the most common payment method
select payment,count(*)as count from sales
group by 1
order by count desc

-- 3.what is the most selling product_line
select Product_line,count(*) as count from sales
group by 1
order by count desc

-- 4.what is the total revenue by month
select month_name,sum(total) as revenue from sales
group by month_name
order by revenue desc

-- 5.which month had the highest cogs(cost of good sold)
select month_name,sum(cogs) as cogs from sales
group by 1
order by cogs desc

-- 6.which product_line has the highest revenue
select Product_line,sum(total) as revenue from sales
group by 1
order by revenue desc limit 1

-- 7.what is the city with highest revene
select city,sum(total) as revenue from sales
group by 1
order by revenue desc limit 1

-- 8.which product has the highest vat
select product_line,round(avg(vat),2) as vat from sales
group by 1
order by vat desc limit 1

-- 9.fetch each product line and add a column to show whther  the product is good or bad. good if its greather than average sales
select product_line,
case when quantity > avg_quantity then 'good'
else 'bad'
end as product_merit
from sales,(SELECT AVG(quantity) AS avg_quantity FROM sales) AS avg_sales;

-- 10.which branch sold more products than average product sold
select branch,sum(quantity) from sales 
group by 1
having sum(quantity) > (select round(avg(quantity),2) from sales)

-- 11.what is the most common product line by gender
select distinct gender,product_line,count(*) as count from sales
group by 1,2
order by count desc,gender 

-- 12.average rating of each productline
select product_line, round(avg(rating),2) as avg_rating from sales
group by 1

-- 13.What is the price range (min and max) for each product line?
select product_line,max(unit_price) as max, min(unit_price) as min from sales
group by 1

-- 14.What is the average quantity sold for each product line
select product_line,avg(quantity) as quantity_sold from sales
group by 1

-- sale questions
-- 1.number of sales made in each time of the day per weekday
select time_of_day,day_name,count(*)as total_sales from sales
group by 1,2
order by 2,1 desc,total_sales desc

-- 2.which customer type brings the most revenue
select customer_type,sum(total) from sales
group by 1

-- 3.which city has the max vat/tax
select city,avg(vat)as vat from sales
group by 1
order by vat desc

-- 4.which customer types pay the most in vat
select customer_type,avg(vat) from sales
group by 1
order by avg(vat) desc

-- 5.What is the month-over-month or year-over-year growth rate in revenue
select month_name,revenue,prev_month_revenue,((revenue-prev_month_revenue)/prev_month_revenue)*100 as growth_rate from
(select month_name,revenue,lag(revenue) over(order by revenue desc)as prev_month_revenue from
(select month_name,sum(total)as revenue from sales
group by 1) sales) sales


-- customer questions
-- 1.how many unique customer types does the data have
select distinct customer_type from sales

-- 2.how many unique payment methods does the data have
select distinct payment from sales

-- 3.most common customer type
select customer_type,count(*) from sales
group by 1
order by count(*) desc limit 1

-- 4.which custoner types buys the most
select customer_type,count(*) from sales
group by 1
order by count(*) desc limit 1

-- 5.what is the gender of  most of the customers
select gender,count(*) from sales
group by 1
order by count(*) desc

-- 6.what is the gender distribution per branch
select gender,branch,count(branch) from sales
group by 1,2
order by gender,branch,count(branch) desc

-- 7.which time of the day do customers give the most rating 
select time_of_day,avg(rating) as avg from sales
group by 1
order by avg desc

-- 8.which time of the day do customers give the most rating per branch
select time_of_day,branch, avg(rating) as rating from sales
group by 1,2
order by branch,time_of_day desc

-- 9.which day of the week has the best avg rating 
select day_name,avg(rating)as avg from sales
group by 1 
order by avg desc

-- 10.which day of the week has the best avg rating per branch
select day_name,branch, avg(rating) as rating from sales
group by 1,2
order by branch,day_name

-- Branch Questions
-- 1.Which branch is the most profitable based on total revenue
select branch,sum(total) as revenue from sales
group by 1
order by revenue desc

-- 2.How do sales vary between branches? Are there specific product lines or customer types that perform better in one branch compared to others
select branch,product_line,sum(total) as sales from sales
group by 1,2

-- revenue and profit questions
-- 1.What is the total revenue (gross sales) for each product line
select product_line,sum(total) as revenue from sales
group by 1

-- 2.What is the total cost of goods sold (COGS) for each product line
select product_line,sum(cogs) as total_cost from sales
group by 1

-- 3.What is the total Value Added Tax (VAT) collected for each product line
select product_line,sum(vat) as total_vat from sales
group by 1

-- 4.What is the gross profit (gross income) for each product line
select product_line,sum(gross_income) as gross_income from sales
group by 1

-- 5.What is the gross margin percentage for each product line?
select product_line,sum(gross_margin_percentage) as gross_margin from sales
group by 1

-- 6.Which product line has the highest gross profit
select * from sales
select product_line,max(gross_income) as highest_gross_profit from sales
group by 1

-- 7.Which product line has the lowest gross margin percentage?
select product_line,min(gross_income) as lowest_gross_profit from sales
group by 1

-- 8.What is the total VAT collected for each branch?
select branch,sum(vat) as total_vat from sales
group by 1
order by 1

-- 9.What is the total COGS for each branch?
select branch,sum(cogs) as total_cogs from sales
group by 1
order by 1

-- 10.Which branch has the highest total revenue?
select branch,sum(total) as total_revenue from sales
group by 1
order by total_revenue desc

-- 11.What is the average gross margin percentage for each branch?
select branch,avg(gross_margin_percentage) as avg_margin from sales
group by 1
order by branch

-- 12.What is the gross margin percentage distribution by customer type?
select customer_type,avg(gross_margin_percentage) as avg_margin from sales
group by 1

-- 13.What is the gross margin percentage distribution by payment method?
select payment,avg(gross_margin_percentage) as avg_margin from sales
group by 1

-- 14.What is the month-over-month  growth rate in gross profit?
select month_name,current_gross_profit,((current_gross_profit-prev_gross_profit)/prev_gross_profit)*100 as growth_rate from
(select month_name,current_gross_profit,lag(current_gross_profit) over(order by month_name) as prev_gross_profit from
(select month_name,sum(gross_income) as current_gross_profit from sales
group by 1)sales) sales

-- 15.Which product lines have a gross margin percentage above a certain threshold (e.g., 2%)?
select product_line, avg(gross_margin_percentage) as avg_margin from sales
group by 1
having avg_margin > 2

-- 16.Which customer types contribute the most to gross profit?
select customer_type, sum(gross_income) as gross_profit from sales
group by 1
order by gross_profit desc

-- 17.What is the overall gross margin percentage for the entire dataset?
select avg(gross_margin_percentage)as avg_gross_percentage from sales

-- 18.What is the overall gross profit for the entire dataset?
select avg(gross_income)as avg_gross_income from sales

-- 19.What is the overall VAT collected for the entire dataset?
select sum(vat)as total_vat from sales


