
--create Database Atlas

--====================Date Table
select * from Date
 --total no of Days 92
select *,format(date,'dddd') from Date


--====================================================HOtels
select * from hotels
--25 hotels presents

select property_name,count(*) no_of_hotels from hotels
group  by property_name

---no of hotels in the city
select distinct city,count(*) no_of_hotels from hotels
group by city


--=========rooms 
select * from rooms

--=============================================fact_aggregated_booking
select * from fact_aggregated_bookings

--========== duplicated check
select * from fact_bookings
where revenue_realized < 1
-- no duplicate
select distinct * from hotels

--================== fact bookings

select * from fact_bookings

select count(*) from fact_bookings
---134590 records

-- replace rating null with the 0
UPDATE fact_bookings
SET ratings_given = 0
WHERE ratings_given IS NULL;


select max(checkout_date) from fact_bookings
-- max checkout date is 06/08/22
select min(check_in_Date) from fact_bookings
-- min check in date 01/05/22

select * from fact_bookings
where check_in_date > '2022-07-31'
---- o records found where check in after july

------==== duplicate check
WITH rankes AS (
    SELECT 
        booking_id, 
        RANK() OVER (PARTITION BY booking_id ORDER BY booking_id) AS r
    FROM fact_bookings
)
SELECT booking_id, r 
FROM rankes
WHERE r > 1;

----======= no duplicated id 


--== amount check null or less values
select * from fact_bookings
where revenue_realized < 1 or revenue_realized is null
-- no null values found

select * from fact_bookings
where no_guests < 1 or no_guests is null
--- no null values found


-----==			=============final table-======================
select * from fact_bookings
select f.booking_id,f.booking_date,f.booking_platform,h.city,f.property_id,h.property_name,h.category,r.room_class,f.booking_status,
f.check_in_date,f.checkout_date,f.no_guests,f.ratings_given,f.revenue_generated,f.revenue_realized 
into fact_table_1
from fact_bookings f join rooms r
on f.room_category=r.room_id
join hotels h
on f.property_id = h.property_Id

SELECT * FROM fact_table_1
--------========================FINAL TABLE==============================

/*
select A.property_id,A.check_in_date,B.city,SUM(B.revenue_realized) COLLECTED_REVENUE ,SUM(B.revenue_generated) EXPECTED_REVENUE
from fact_aggregated_bookings A
join fact_table_1 B
on a.property_id=B.property_id AND A.check_in_date=B.check_in_date
WHERE A.property_id='16558'
GROUP BY A.check_in_date,A.property_id,B.city
ORDER BY property_id
*/

---========================== measures

----- total revenue
select sum(revenue_realized) total_revenue from fact_bookings  --1,708,771,229
select sum(revenue_generated) expected_revenue from fact_bookings --2,007,546,215


-- TOTAL GUEST
select sum(no_guests) GUEST from fact_bookings
--274,134

--- Total Bookings
select  count(distinct booking_id) total_bookings from fact_bookings --134,590

select  booking_status,count(distinct booking_id) total_bookings
from fact_bookings
group by booking_status

--cancelled booking = 33,420
--checked out = 94,411
--no show (neither cancelled neither attend)= 6,759 


--- Total rooms
select sum(capacity) total_rooms 
from (
select distinct property_id,capacity from fact_aggregated_bookings
) as x

select distinct f.property_id,capacity,h.property_name,h.city from fact_aggregated_bookings f
left join hotels h
on f.property_id=h.property_id
----select * from hotels

select *--count(distinct property_id) 
from fact_aggregated_bookings






--- ================Cancellaction percent
select count(*) total_Cancelled, round(count(*) * 100.0/(select count(*) from fact_bookings),2) cancel_ratio
from fact_bookings
where booking_status ='Cancelled'
--====33420 cancelled , 24.83 %

---============ no show percent
select count(*) total_no_show, round(count(*) * 100.0/(select count(*) from fact_bookings),2) no_show_ratio
from fact_bookings
where booking_status ='No Show'

--============booking percent on date
select *,round(total_Booking*100.0/total_capacity,2) booking_percent 
from (
select check_in_date,sum(successful_bookings) total_Booking,sum(capacity) total_capacity 
from fact_aggregated_bookings
group by check_in_date)
as x
order by check_in_date

--- bookings plateform
select distinct booking_platform from fact_bookings

---total booking by the city 
select * from hotels h join fact_aggregated_bookings f
on h.property_id=f.property_id
