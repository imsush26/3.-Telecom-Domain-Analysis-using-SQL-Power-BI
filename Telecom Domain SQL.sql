select * from dim_dates;
select * from dim_cities;
select * from dim_plan;
select * from fact_itv_metrics;
select * from fact_market_share;
select * from fact_plan_revenue;

#1)Total Revenue
select round(sum(itv_revenue_crores),2) as total_revenue_crores from fact_itv_metrics;

#2)Avg Revenue 
select round(avg(itv_revenue_crores),2) as avg_revenue_crores from fact_itv_metrics;

#3)Avg of arpu
select avg(arpu) as Avg_revenue_per_user from fact_itv_metrics;

#4)Total Active Users 
select round(sum(active_users_lakhs),2) as Total_active_users_lakhs from fact_itv_metrics;

#5)Total Unsubscribed Users
select round(sum(unsubscribed_users_lakhs),2) as Total_Unsubscribed_Users_lakhs from fact_itv_metrics;

#6)Average of active users per month
select month_name,round(avg(active_users_lakhs),2) as active_users_per_month_lakh from fact_itv_metrics
group by month_name;

#7)Average of ms_pct
select round(avg(ms_pct)) as Market_Share_percentage from fact_market_share;

#8)Total Revenue for all periods before 5G implementation
select time_period,round(sum(itv_revenue_crores),2) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="Before 5G"
group by time_period;

#9)Total Revenue for all periods after 5G implementation
select time_period,round(sum(itv_revenue_crores),2) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="After 5G"
group by time_period;

#10)ARPU of periods before 5G implementation
select time_period,avg(arpu) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="Before 5G"
group by time_period;

#11)ARPU of periods after 5G implementation
select time_period,avg(arpu) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="After 5G"
group by time_period;

#12)Total active users for all periods before 5G implementation
select time_period,round(sum(active_users_lakhs),2) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="Before 5G"
group by time_period;

#13)Total active users for all periods after 5G implementation
select time_period,round(sum(active_users_lakhs),2) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="After 5G"
group by time_period;

#14)Total unsubscribed users for all periods before 5G implementation
select time_period,round(sum(unsubscribed_users_lakhs),2) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="Before 5G"
group by time_period;

#15)Total unsubscribed users for all periods before 5G implementation
select time_period,round(sum(unsubscribed_users_lakhs),2) from fact_itv_metrics 
inner join dim_dates on fact_itv_metrics.`month_name`=dim_dates.`month_name`
where dim_dates.`before/after_5G`="After 5G"
group by time_period;

#16) Percentage growth in revenue before and after 5g implementation for each city
WITH revenue AS (
SELECT 
city_name,
sum(CASE WHEN `before/after_5g` = 'Before 5G' THEN itv_revenue_crores END) AS Total_revenue_before_5g,
sum(CASE WHEN `before/after_5g` = 'After 5G' THEN itv_revenue_crores END) AS Total_revenue_after_5g
FROM  fact_itv_metrics  join dim_cities on fact_itv_metrics.city_code = dim_cities.city_code  
join  dim_dates   on  fact_itv_metrics.month_name = dim_dates.month_name
GROUP BY city_name
)
SELECT 
city_name,
Total_revenue_before_5g,
Total_revenue_after_5g,
((Total_revenue_after_5g - Total_revenue_before_5g) / Total_revenue_before_5g) * 100 AS percentage_growth
FROM revenue;

#17) Percentage growth in revenue before and after 5g implementation for each Plan
with revenuePLAN as (
select plans,
sum(case when `before/after_5g` = 'Before 5G' then plan_revenue_crores end) as Total_planrevenue_before_5g,
sum(case when  `before/after_5g` = 'After 5G' then plan_revenue_crores end) as Total_planrevenue_after_5g
from fact_plan_revenue join dim_dates on fact_plan_revenue.`date`= dim_dates.`date`
group by plans
)
select 
plans,
Total_planrevenue_before_5g,
Total_planrevenue_after_5g,
((Total_planrevenue_after_5g - Total_planrevenue_before_5g) / Total_planrevenue_before_5g) * 100 
as percentage_growth
from revenuePlan;

#18) City wise active users in lakh before 5g and after 5g 
SELECT city_name,
sum(CASE WHEN `before/after_5g` = 'Before 5G' THEN active_users_lakhs END) AS Total_activeuser_before_5g,
sum(CASE WHEN `before/after_5g` = 'After 5G' THEN active_users_lakhs END) AS Total_activeuser_after_5g
FROM  fact_itv_metrics  join dim_cities on fact_itv_metrics.city_code = dim_cities.city_code  
join  dim_dates   on  fact_itv_metrics.month_name = dim_dates.month_name
GROUP BY city_name;

#19) Market share over months for all companies
select month_name,
avg(case when fact_market_share.`company`="itv" then ms_pct end) as itv_marketshare,
avg(case when fact_market_share.`company`="Aiirtel" then ms_pct end) as Aiirtel_marketshare,
avg(case when fact_market_share.`company`="Lio" then ms_pct end) as Lio_marketshare,
avg(case when fact_market_share.`company`="DADAFONE" then ms_pct end) as DADAFONE_marketshare,
avg(case when fact_market_share.`company`="Others" then ms_pct end) as Others_marketshare
from fact_market_share join fact_itv_metrics on fact_market_share.`date`=fact_itv_metrics.`date`
group by month_name;

#20) Top Plans by revenue
select plans,sum(plan_revenue_crores) as revenue from fact_plan_revenue
group by plans;

#21) Monthly trend of avg ARPU before and after 5g
SELECT fact_itv_metrics.month_name,
avg(CASE WHEN `before/after_5g` = 'Before 5G' THEN arpu END) AS Avg_arpu_before_5g,
avg(CASE WHEN `before/after_5g` = 'After 5G' THEN arpu END) AS Avg_arpu_after_5g
FROM  fact_itv_metrics join dim_dates on fact_itv_metrics.month_name=dim_dates.month_name
 GROUP BY fact_itv_metrics.month_name;

#22) Monthly trend of avg active users before and after 5g
select fact_itv_metrics.month_name,
avg(case when `before/after_5G`="Before 5G" then active_users_lakhs end) as avg_activeuser_before_5g,
avg(case when `before/after_5G`="After 5G" then active_users_lakhs end) as avg_activeuser_before_5g
from fact_itv_metrics join dim_dates on fact_itv_metrics.month_name=dim_dates.month_name
group by fact_itv_metrics.month_name;

#23) Monthly trend of unsubscribed users before 5g and after 5g
select fact_itv_metrics.month_name,
sum(case when `before/after_5G`="Before 5G"  then unsubscribed_users_lakhs end) as unsubUser_before_5g,
sum(case when `before/after_5G`="After 5G" then unsubscribed_users_lakhs end) as unsubUser_after_5g
from fact_itv_metrics join dim_dates on fact_itv_metrics.month_name=dim_dates.month_name
group by fact_itv_metrics.month_name;

