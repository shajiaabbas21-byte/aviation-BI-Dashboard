use airline;
select *  from airline_operations;
select count(*) from airline_operations;
select round(avg(departure_delay_min/60.0),2) as Avg_departure_delay_hrs
from airline_operations;
-- Performance KPIs
select 
	count(*) as total_flights, -- total no of flights
    round(avg(departure_delay_min/60.0),2) as Avg_departure_delay_hrs, -- departetures delay hours
	round(avg(arrival_delay_min/60.0),2) as Avg_arrival_delay_hrs,     -- arrival delay hours
    round(sum(case when departure_delay_min <= 15 then 1 else 0 end) * 100 / count(*),2) as on_time_percentage, -- on time flights percentage
	sum(passenger_count) as total_passenger,                                                                    -- total passengers travelled
    sum(profit_usd) as total_profit                                                                             -- total profit made
from airline_operations;

-- Airports with most delayed flights
select origin_airport as airport,
	count(*) as total_flights,
    round(avg(departure_delay_min/60.0),2) as Avg_delay_hrs,
	sum(case when departure_delay_min > 15 then 1 else 0 end) as delayed_flights
from airline_operations
group by origin_airport
order by delayed_flights desc
limit 10;

-- delay reson
select delay_reason as reason_for_delay,
	count(*) as occurance,
    round(avg(departure_delay_min/60.0),2) as Avg_delay_hrs,
    round(sum(departure_delay_min/60.0),2) as total_delay_hrs
from airline_operations
where departure_delay_min > 0
group by delay_reason
order by total_delay_hrs desc;

-- Monthly Flight Trends
select year,month,
	count(*) as total_flights,
    round(avg(departure_delay_min/60.0),2) as Avg_delay_hrs,
    sum(passenger_count) as total_passenger
from airline_operations
group by year,month
order by year,month;
    
-- Delay by day of week & Hour
select day_of_week as day,
	count(*) as count_of_flights,
    round(avg(departure_delay_min/60.0),2) as Avg_delay_hrs
from airline_operations
group by day_of_week
order by count_of_flights desc;

-- Top 10 Busiest Routes
select concat(origin_airport, '-' , destination_airport) as route,
	count(*) as total_flights,
    sum(passenger_count) as total_passenger,
    round(avg(occupancy_rate),2) as avg_occupancy
from airline_operations
group by origin_airport, destination_airport
order by total_flights desc
limit 10;

-- Aircraft performance

select 
	aircraft_type as aircraft,
	count(*) as total_flights,
    round(avg(departure_delay_min/60.0),2) as Avg_delay_hrs,
    round(avg(occupancy_rate),2) as avg_occupancy,
	round(avg(operational_efficiency_score),2)as avg_operational_efficiency 
from airline_operations
group by aircraft_type
order by Avg_delay_hrs desc;
	
-- Delay vs Customer satisfaction
select
	Case
		when departure_delay_min =0 then "no delay"
        when departure_delay_min between 1 and 15 then '1-15 min'
        when departure_delay_min between 16 and 45 then '16-45 min'
        when departure_delay_min between 46 and 120 then '46-120 min'
        else '+120 min'
	end as delay_flights,
    count(*) as total_flight,
    round(avg(customer_satisfaction),2) as avg_satisfaction
from airline_operations
group by delay_flights
order by avg_satisfaction desc;

-- on time % by airline
select airline,
	count(*) as total_flight,
    round(sum( case when departure_delay_min <= 15 then 1 else 0 end) * 100.0/ count(*),2) as on_time,
    round(avg(customer_satisfaction),2) as avg_satisfaction
from airline_operations
group by airline
order by on_time desc;

-- top 10 flights Profitability by route
select concat(origin_airport, '-' , destination_airport) as route,
	count(*) as total_flights,
    round(sum(ticket_revenue_usd),2) as total_revenue,
    round(sum(operational_cost_usd),2) as total_cost,
    round(sum(profit_usd),2) as total_profit
from airline_operations
group by origin_airport, destination_airport
order by total_profit desc
limit 10;

-- weather impact on declays
select weather_condition as weather,
	count(*) as total_flights,
	round(avg(departure_delay_min/60.0),2) as Avg_delay_hrs,
	round(sum( case when departure_delay_min > 15 then 1 else 0 end) * 100.0/ count(*),2) as delay_rate
from airline_operations
group by weather_condition
order by Avg_delay_hrs desc;

-- Delay risk & cancellation

select
	delay_category,
	count(*) as total_flight,
	round(avg(delay_risk_score),2) as avg_risk_score,
	round(avg(predicted_delay_probability),2) as avg_probility_prob
 from airline_operations
 group by delay_category
 order by avg_risk_score desc;
 
 -- top delay prone airport
select origin_airport,
	round(avg(departure_delay_min),2) as avg_delay
from airline_operations
group by origin_airport
order by avg_delay desc
limit 3;

-- creating view

CREATE OR REPLACE VIEW airline_clean AS 
SELECT 
    *,
    CONCAT(origin_airport, '-', destination_airport) AS route,
    STR_TO_DATE(CONCAT(year, '-', LPAD(month, 2, '0'), '-01'), '%Y-%m-%d') AS flight_date,
    CASE
        WHEN departure_delay_min = 0 THEN 'no delay'
        WHEN departure_delay_min <= 15 THEN '1-15 min'
        WHEN departure_delay_min <= 45 THEN '16-45 min'
        WHEN departure_delay_min <= 120 THEN '46-120 min'
        ELSE '120+ min'
    END AS delay_flights,
    ROUND((profit_usd / NULLIF(ticket_revenue_usd, 0)) * 100.0, 2) AS profit_margin
FROM airline_operations;        
        
 -- 
 SELECT 
    SUM(CASE WHEN departure_delay_min <= 15 THEN 1 ELSE 0 END) AS on_time_flights,
    SUM(CASE WHEN departure_delay_min > 15 THEN 1 ELSE 0 END) AS delayed_flights,
    COUNT(*) AS total_flights
FROM airline_operations;
--
select
	min(departure_delay_min) as min_value,
    max(departure_delay_min) as max_value,
    avg(departure_delay_min) as avg_value
from airline_operations;
