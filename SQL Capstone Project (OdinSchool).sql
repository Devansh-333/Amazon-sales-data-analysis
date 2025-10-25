-- Create database
create database Amazon_DS;
use Amazon_DS;
SELECT * FROM amazon;
-- Feature Engineering

ALTER TABLE amazon
ADD COLUMN time_of_day VARCHAR(10);

UPDATE amazon
SET time_of_day = CASE
    WHEN HOUR(Time) >= 0 AND HOUR(Time) < 12 THEN 'Morning'
    WHEN HOUR(Time) >= 12 AND HOUR(Time) < 18 THEN 'Afternoon'
    ELSE 'Evening'
END;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE amazon
drop COLUMN time_od_day;

ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);

UPDATE amazon
SET dayname = DATE_FORMAT(Time, '%a'); -- '%a' gives day name (Mon, Tue, wed and so on)
SELECT dayname, COUNT(*) AS transaction_count
FROM amazon
GROUP BY dayname
ORDER BY transaction_count DESC;

UPDATE amazon
SET dayname = DATE_FORMAT(CONCAT(date, ' ', Time), '%a'); -- Combining date and time


ALTER TABLE amazon
ADD COLUMN month_name VARCHAR(10);

UPDATE amazon
SET month_name = DATE_FORMAT(Date, '%b'); -- '%b' gives abbreviated month name (Jan, Feb, Mar)

-- Exploratory Data Analysis (EDA)

select * from amazon;

-- 1. What is the count of distinct cities in the dataset?

select Count(Distinct city) as distinct_cities
FROM amazon;

-- result-: there are 3 distinct cities in the dataset

-- 2. For each branch, what is the corresponding city?

select branch, city
from amazon
group by branch, city;

/*
 Result- branch A belongs to yangon
		 branch B belongs to Naypyitaw
         branch C belongs to Mandalay
*/         

-- 3.What is the count of distinct product lines in the dataset?

select count( distinct `product line`) AS distinct_product_lines
from amazon;

-- Result - there 6 different product lines

-- 4.Which payment method occurs most frequently?

select Distinct (payment), count(*) as Frequent_Payment
from amazon
group by payment
order by Frequent_Payment desc limit 1;

-- result- Ewallet has been used for 345 times more than the other two i.e., Ewallet is the most frequent one.

-- 5.Which product line has the highest sales?

select `Product line`, sum(total) as highest_sales
from amazon
group by `Product line`
order by highest_sales desc
limit 1;

-- Result - "Food and beverages" has the highest sales i.e. "56144.844000000005".

-- 6.How much revenue is generated each month?

select month_name, sum(total) as highest_sales
from amazon
group by month_name
order by highest_sales desc;

/* Result:- The revenue generated in "January" is "116291.86800000005"
			The revenue generated in "February" is "109455.50700000004"
            The revenue generated in "March" is "97219.37399999997"
*/

-- 7.In which month did the cost of goods sold reach its peak?         

SELECT month_name, sum(cogs) AS highest_cogs
FROM amazon
group by month_name
order by highest_cogs desc
limit 1;

-- Result- the highest cost of goods sold i.e. cogs is in "January" which is "110754.16000000002".

-- 8.Which product line generated the highest revenue?

 

SELECT `Product line`, sum(`total`) AS highest_revenue
FROM amazon
group by `Product line`
order by highest_revenue desc;

-- Result- "Food and beverages" generate highest revenue i.e.,"56144.844000000005".

-- 9.In which city was the highest revenue recorded?

SELECT city, sum(`total`) AS Total_revenue
FROM amazon
group by city
order by Total_revenue desc
limit 1;

-- Result- "Naypyitaw" has the Highest revenue i.e., "110568.70649999994".

-- 10.Which product line incurred the highest Value Added Tax?
select * from amazon ; 

SELECT `Product line`, sum(`Tax 5%`) AS Total_VAT
FROM amazon
group by `Product line`
order by Total_VAT desc limit 1;

-- Result - "Food and beverages" generated highest VAT.

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

select `product line`, 
    SUM(total) as total_sales,
    CASE 
        when sum(total) > (
            select avg(total_sales) 
            from (
                select 
                    SUM(total) AS total_sales 
                from
                    amazon 
                group by 
                    `product line`
            ) as subquery
        ) 
        then 'Good' 
        else 'Bad' 
        
end sales_category
from amazon
group by `product line`;
    
-- Result-  only health and beauty products performed badly rest all worked above average that means Good

-- 12.Identify the branch that exceeded the average number of products sold.

Select branch
from amazon
group by branch
having avg(quantity) > (select avg(quantity) from amazon);
 
 -- Result Branch "C" exceeds the average number of product sold
 
 -- 13.Which product line is most frequently associated with each gender?
 
 select distinct (`product line`), gender , count(*) as most_frequent
 from amazon
 group by `product line`,gender
 order by  most_frequent desc;
 
/* result- Females are more frequent in fashion, Food and beverages, Sports and travel 
and males are in Health and beauty, Electronic accessories and Home and lifestyle 
although in Electronic accessories there not much difference
*/

-- 14.Calculate the average rating for each product line.

 select `product line`, avg(`rating`) as avg_rating
 from amazon
 group by `product line`
  order by avg_rating desc;
 
 -- Result- the following are the average rating for each product line.
 
 -- 15.Count the sales occurrences for each time of day on every weekday.
 

select dayname, time_of_day, 
Count(*) AS sales_count
from amazon
group by dayname, time_of_day
order by dayname;

-- 16.Identify the customer type contributing the highest revenue.

select `customer type`, max(total) as highest_Revenue
 from amazon
 group by `customer type`
 order by highest_Revenue desc
 limit 1 ;
 
 -- result- the highest revenue is generated by the Members.
 
 -- 17.Determine the city with the highest VAT percentage.
 
 select City, max(`tax 5%`) as highest_VAT
 from amazon
 group by City
 order by highest_VAT desc
 limit 1;
 
 -- Result- Naypyitaw is the city highest in the VAT
 
 -- 18.Identify the customer type with the highest VAT payments.
 
 select * from amazon;
 select `customer type`, max(`tax 5%`) as highest_VAT
 from amazon
 group by `customer type`
 order by highest_VAT desc
 limit 1;
 
 -- Result- members pays the highest VAT.
 
 -- 19.What is the count of distinct customer types in the dataset?
 
 select distinct(`customer type`) , count(*) as total_customer_type
 from amazon
 group by `customer type`
 order by  total_customer_type desc;
 
 -- Result - Members are 501 and Normal are 499.
 
 -- 20.What is the count of distinct payment methods in the dataset?

  select distinct(`payment`) , count(*) as dist_payments_methods
 from amazon
 group by `payment`
 order by  dist_payments_methods desc;
 
/* Result - Ewallets = 345, Cash = 344 and Creditcard = 311 
  there not much diffenece in the count but still ewallet and cash is most preffered */
  
-- 21.Which customer type occurs most frequently?

select `customer type`, count(*) as occurs_frequently
 from amazon
 group by `customer type`
 order by occurs_frequently desc
 limit 1;
  
-- Result - Members occurs most frequently

-- 22.Identify the customer type with the highest purchase frequency.

select `customer type`, count(*) as purchase_frequency 
from amazon
group by `customer type`
order by purchase_frequency desc
limit 1;

-- Result- members have highest purchase frequency.

-- 23.Determine the predominant gender among customers.

select gender, count(*) as predominant_gender
from amazon
group by gender
order by predominant_gender desc
limit 1;

-- Result - Females are predominant

-- 24. Examine the distribution of genders within each branch.

select branch, gender, count(*) as gender_count
from amazon
group by branch, gender
order by  field(branch, 'A', 'B', 'C'), 
    field(gender, 'Male', 'Female');
-- Result - the distribution of malw in A,B and c is (179,170 and 150) similarly females (161,162 and 178).    

-- 25.Identify the time of day when customers provide the most ratings.

select time_of_day,count(rating) as most_rating
 from amazon
 group by time_of_day
 order by most_rating desc 
 limit 1;
 
 -- Result -  afternoon is a time when customers prove most rating.
 
 -- 26.Determine the time of day with the highest customer ratings for each branch.
 
 with RankedRatings as (
 select branch, time_of_day, Count(rating) as most_rating,
rank() over (partition by  branch order by Count(rating) desc) as total_rank
from amazon   
group by branch, time_of_day
)
select branch, time_of_day, most_rating
from RankedRatings
where total_rank = 1;
   
-- Result - Afternoon is a time for each branch when the customers gives rating the most.

-- 27. Identify the day of the week with the highest average ratings.

select dayname,avg(rating) as avg_rating
 from amazon
 group by dayname 
 order by avg_rating desc
 limit 1;

-- Result -  Monday is the day with highest avgerage rating.

-- 28.Determine the day of the week with the highest average ratings for each branch.

select branch, dayname, avg_rating
from
(
select branch, dayname, avg(rating) as avg_rating,
Rank() over (partition by branch order by avg(rating) desc) as avg_rank
from amazon
group by branch, dayname
) as RankedDays
where avg_rank = 1
order by branch;

-- Result- branch A gets highest average rating on friday , B on monday, C on friday,

-- OVERALL CONCLUSIONS-:

-- The Food and beverages product line dominates in both sales and VAT contributions, making it the top-performing product line.
   /* We must try to increase sales in other product line we must put other product lines in relavent suggestions as well
    along with the similar products.
    Conduct surveys or analyze reviews to understand customer perceptions of 
    underperforming product lines and address any concerns.*/
    
-- Ewallet is the preferred payment method, possibly due to its convenience.

   /* But we must try to Improve Payment Experience  ensure that all payment methods are equally 
   convenient and secure. specially optimize the user experience for 
   credit card payments or introduce incentives for using different payment methods.
   as credit card payments are fast and it gives users liberty to spend more and for security purpose as well
   as credit card companies often offers fraud protection.
   */
   
-- Members, especially females, are the most active and valuable customer group.
/* Develop targeted marketing campaigns to attract more male customers or non-member customers.
 like we can offer membership incentives to non-members or discounts and create promotions focusing towards males.
 */

-- Afternoon and Monday emerge as significant times for customer engagement and feedback.
  /* time-limited offers or flash sales during less active times like mornings or weekends to drive traffic and sales.*/
  
  
-- Branch C is performing well.
/* Analyze why Branch C is performing better and replicate successful strategies across other branches. 
   This could involve staff training, product assortment adjustments, or local marketing initiatives.
   */


 
 
    


 
 
 


 

















