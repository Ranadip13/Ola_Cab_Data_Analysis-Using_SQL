create database Ola_Cabs;

use Ola_Cabs;

/* 1. Find hour of 'pickup' and 'confirmed_at' time, and make a column of weekday as 
"Sun,Mon, etc"next to pickup_datetime */
select pickup_datetime, dayname(str_to_date(pickup_date, "%d-%m-%Y")) as Weekday,
hour(str_to_date(pickup_time, "%H:%i:%s")) as Pickup_Hours,
hour(str_to_date(Confirmed_at, "%d-%m-%Y %H:%i")) as Confirmed_Hours
from data;


/* 2. Make a table with count of bookings with booking_type = p2p 
catgorized by booking mode as 'phone', 'online','app',etc */
select Booking_mode, count(*) No_Of_Booking
from data
where Booking_type = "p2p"
group by Booking_mode;


/* 3. Create columns for pickup and drop ZONES 
(using Localities data containing Zone IDs against each area) 
and fill corresponding values against pick-area and drop_area, using Sheet'Localities'
*/
create view PickupZones as
select Booking_id, PickupArea, zone_id as PickupZone
from data d left join Localities l
on d.PickupArea = l.Area;

create view DropZones as
select Booking_id, DropArea, zone_id as DropZone
from data d left join Localities l
on d.DropArea = l.Area;

select *
from PickupZones pz inner join DropZones dz using(Booking_id);

-- ---------------------------------------------------------------------
with PickupZones as(
					select Booking_id, PickupArea, zone_id as PickupZone
					from data d left join Localities l
					on d.PickupArea = l.Area),
		DropZones as(select Booking_id, DropArea, zone_id as DropZone
					from data d left join Localities l
					on d.DropArea = l.Area)

select *
from PickupZones pz inner join DropZones dz using(Booking_id);

/* 4. Find top 5 Pickup zones in terms of  total revenue */
SELECT zone_id as PickUpZone, Sum(fare) as TotalRevenue
FROM Data as D left join Localities as L
on D.pickuparea = L.Area
where Service_status = 'done'
Group By Zone_id
Order By 2 DESC
Limit 5;


/* 5. Find top 5 drop zones in terms of  average revenue */
select zone_id as DropZone, avg(Fare) as AverageRevenue
from data d left join localities l
on d.DropArea = l.Area
where Service_status = 'done'
group by DropZone
order by Revenue desc
limit 5;

/* 6. Make a list of top 10 driver by driver numbers 
in terms of fare collected where service_status is done, done-issue
*/
 select Driver_number, sum(Fare) as FareCollected
 from data
 where Service_status in ("done", "done-issue")
 group by Driver_number
 order by sum(Fare) desc
 limit 10;
 
 /* 7. Identify the top 5 drivers involved in ride cancellations. */
select distinct Driver_number, count(*) as No_of_cancellations
 from data join localities on PickupArea=Area
 where Service_status in ('cancelled', 'cancelled-issue')
 group by Driver_number
 order by 2 desc
 limit 5; 

/* 8. Houe wise average booking in a day. */
select hour(str_to_date(pickup_time, "%H:%i:%s")) as Hours, count(*) TotalBooking
from data
group by hours
order by 2 desc;


/* 9. Make a hourwise table of bookings for week between Nov01-Nov-07 
and highlight the hours with more than average no.of bookings day wise
*/
-- Hourwise table of bookings for week between Nov01-Nov-07 --
select hour(str_to_date(pickup_time, "%H:%i:%s")) as Hours, count(*) TotalBooking
from data
where str_to_date(pickup_date, "%d-%m-%Y") between "2013-11-01" and "2013-11-07"
group by hours
order by 1 asc;

-- Finding average daily booking --
select avg(NoOfBooking)
from (select day(str_to_date(pickup_date, "%d-%m-%Y")) as Days, count(*) as NoOfBooking
	from data
	group by day(str_to_date(pickup_date, "%d-%m-%Y"))) as TempTable;

-- Final Answer --
select hour(str_to_date(pickup_time, "%H:%i:%s")) as Hours, count(*) as TotalBooking
from data
where str_to_date(pickup_date, "%d-%m-%Y") between "2013-11-01" and "2013-11-07"
group by hours
having TotalBooking > (select avg(NoOfBooking)
					from (select day(str_to_date(pickup_date, "%d-%m-%Y")) as Days, count(*) as NoOfBooking
						from data
						group by day(str_to_date(pickup_date, "%d-%m-%Y"))) as TempTable)
order by 2 desc;
