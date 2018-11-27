
Descritpion: Sample queries for querying existing data

Aliases:
r   = reservation_bookreservation
ri  = resy_info
u   = user_info
uu  = user_user
vi  = venue_info
li  = location_info
s   = reservation_bookreservationstatus






Queries:

1. 
"Count of reservations by active users
active users = r.date_created < [90 days]"

select  r1.user_id active_user, 
        count(r1.id) Total_Reservations, 
        sum(r1.num_seats) Total_covers 
from reservation_bookreservation r1 
join reservation_bookreservationstatus s on s.reservation_id=r1.id 
join user_user u on u.id=r1.user_id and u.foreign_type='resy_app'  
where r1.cancellation_id is null 
        and r1.is_walkin!=1 and r1.date_booked < '2018-10-31' and u.foreign_id in 
(select r2.user_id from resy_info r2 where r2.date_created between '2018-08-02' and '2018-10-31')
group by 1;

SELECT u.id, count(ri.id)
FROM USER_INFO AS U
INNER JOIN resy_info ri on ri.user_id = u.id
INNER JOIN venue_info v on v.id = ri.venue_id
where u.DATE_CREATED > '2017-01-01' and u.DATE_CREATED < '2017-12-31'
and ri.date_created >= u.date_created 
and v.location_id = 1
//and count(ri.id)>=2
GROUP BY u.id
//GROUP BY "MONTH"
//ORDER BY "MONTH"
;

2.
"Reference table of location ids, city names, number of venues, and number of reservations"

select li.id "location_info.id", li.name "location_info.name", count(distinct v.id) "venue_info.id", count(r.id) "res..bookres..id"
from reservation_bookreservation r 
join venue_info v on v.id=r.venue_id and v.is_active=1
inner join location_info li on li.id=v.location_id
group by li.id, li.name
order by li.id
;
// "had to add li.name to group by to be able to select li.name"

"Top 10 restaurants wrt reservations in metro cities. 
When there are less than 10 venues it's b/c the city likely 
went live that year & only had those venues active. 
The query used excludes inactive venues, cancellations, no shows, and walkins. 
"

// Top 10 restaurants in different cities: 1, 2, 4, 5, (8,22,12,19), (22), 12, 192
select g."Restaurant", 
g."City",
g."Total_Reservations", 
g."Total_Covers" 
from (
select r.venue_id "venue_id", v.name "Restaurant",
        li.name "City", count(r.id) "Total_Reservations", sum(r.num_seats) "Total_Covers"  
from reservation_bookreservation r 
join reservation_bookreservationstatus s on s.reservation_id=r.id 
join venue_info v on v.id=r.venue_id and v.is_active=1
inner join location_info li on li.id=v.location_id
where r.venue_id !=1278
and r.cancellation_id is null
and s.status_id!=2
and v.location_id in (1)
and year(r.date_created)=2018
and r.date_created <= '2018-11-01'
group by "venue_id", "City", "Restaurant"
order by "City", "Total_Reservations" desc
) g
limit 10;

"Query of a sub-sub-query"

select resys."res_count", count(resys."user_id") as "user_count"
from
(select count(distinct r.id) as "res_count", active_users."user_id"
from
(
select u.id as "user_id", r.id as "res_id"
FROM USER_info AS u
JOIN resy_info r on r.user_id = u.id
where R.DATE_CREATED > '2018-07-20' and R.DATE_CREATED < '2018-11-01'
) as active_users
JOIN resy_info r on r.user_id = active_users."user_id"
group by active_users."user_id"
order by "res_count" desc 
) as resys
group by resys."res_count"
order by resys."res_count"
;


"Reservations per month and per city. Uses pivot to create a separate column for each city"
// According to a Snowflake engineer, "The pivot command requires a constant value. 
// You could try to get away with a stored procedure function that generates the columns, 
// but thats uncharted territory."
// A solution is to print the desired list of cities, then copy&paste into the query as an actual string.

// Reservations per app city per month
select *
from (
select
month(r.date_created) Month,
year(r.date_created) Year,
date_from_parts(Year, Month, 1) Month_Year,
li.name City,
count(distinct r.user_id) Total_Users
from reservation_bookreservation r
inner join reservation_bookreservationstatus s on r.id = s.reservation_id and s.status_id != 2
join venue_info v on v.id=r.venue_id and v.is_active=1
join location_info li on li.id=v.location_id
where
r.cancellation_id is null
and r.venue_id != 1278
and City in ('New York','Los Angeles', 'San Francisco','Washington D.C.','Austin', 'London')
group by Month, Year, City
order by Month_Year
) g
pivot
(sum(g.Total_Users)
for City in ('New York','Los Angeles', 'San Francisco','Washington D.C.','Austin', 'London')
) piv
order by Month_Year desc
;


"Print list of in-app cities"

select listagg(distinct '''' || li.name || '''' ,', ') 
from location_info li
where li.show_in_app = TRUE
;


"Reservations per month and per source. Uses case when to create a different column for each source"

select 
date_from_parts(year(r.date_created), month(r.date_created), 1) Month_Year,
    count(case when   
            r.source_id not like 'resy_os' and 
            r.source_id not like 'resy_app' and 
            r.source_id not like 'resy.com' and 
            r.source_id not like 'Airbnb' and 
            r.source_id not like 'Instagram' and 
            r.source_id not like '%facebook'and 
            r.source_id not like '%import%' 
        then 
            r.id end) Widget_Resys,            
     count(case when 
            r.source_id like 'Airbnb' or 
            r.source_id like 'Instagram' or
            r.source_id like '%facebook' or
            r.source_id like '%import%'
         then 
            r.num_seats end) Third_Party_Resys,
     count(case when r.source_id like 'resy_app'  then r.id end) Resy_App_Resys,
     count(case when r.source_id like 'resy_os' and r.is_walkin = 0 then r.id end) Resy_OS_Resys,  //not excluding walkins bc table is missing
// //     sum(case when r.source_id like 'resy_os' and r.is_walkin = 0 and not exists (select 1 from wait_list_waitlist w where w.reservation_id = r.id) then r.num_seats end) Resy_OS_Covers
// //     sum(case when r.source_id like 'resy_os' and (r.is_walkin = 1 or exists (select 1 from wait_list_waitlist w where w.reservation_id = r.id)) then r.num_seats end) Walkin_Covers
     count(case when r.source_id like 'resy.com' then r.id  end) Resycom_Resys,
count(distinct r.id) Total_Resys,
count(case when r.source_id like 'resy.com' or  r.source_id like 'resy_app' then r.id end) Resy_Platform_Resys,
sum(r.num_seats) Total_Covers
// //     sum(case when r.source_id like 'resy.com' or  r.source_id like 'resy_app' then r.id end)/sum(r.id) Percent_Resy_Platform_Resys // wrong, not per month
from reservation_bookreservation r 
  inner join reservation_bookreservationstatus s on r.id = s.reservation_id and s.status_id != 2
where  
  r.cancellation_id is null
  and r.venue_id != 1278
  and r.date_created >= '2016-09-01'
group by month(r.date_created), year(r.date_created)
order by Month_Year
;

// Using listagg to combine cells
SELECT u.id, count(ri.id) as "resyCount" , listagg(v.location_id , ',') within group (order by ri.day)  as "venueLocations", listagg(ri.day, ', ')
FROM USER_INFO AS U
RIGHT JOIN resy_info ri on ri.user_id = u.id
INNER JOIN venue_info v on v.id = ri.venue_id
where u.DATE_CREATED > '2017-01-01' and u.DATE_CREATED < '2017-12-31'
and ri.date_created >= u.date_created 
GROUP BY u.id
having "resyCount" >= 2 and "resyCount" <= 10
and "venueLocations" RLIKE '.*[^0-9]1[^0-9].*'
ORDER BY "resyCount" desc
;


"New registered User counts per month per city using the user_locations_max table"

// What is the number of new registered users, broken out by month, in 2018 by App city?

select date_from_parts(year(u.date_created), month(u.date_created), 1) Month_Year, //count(distinct ulm.user_id) New_Users

count(case when li.name like 'New York' then ulm.user_id end) NYC, 
count(case when li.name like 'Los Angeles' then ulm.user_id end) LA,
count(case when li.name like 'San Francisco' then ulm.user_id end) SF,            
count(case when li.name like 'Washington D.C.' then ulm.user_id end) Wash_DC,            
count(case when li.name like 'Austin' then ulm.user_id end) Austin,            
count(case when li.name like 'London' then ulm.user_id end) London            
            
from EXPERIMENTAL.PUBLIC.USER_LOCATIONS_BY_MAX ulm
join user_info u on u.id = ulm.user_id
//join user_user uu on uu.id = ulm.user_id
join location_info li on li.id = ulm.location
where u.date_created >= '2016-10-01' and u.date_created <= '2018-09-30'
and li.name in ('New York','Los Angeles', 'San Francisco','Washington D.C.','Austin', 'London')
group by Month_Year
order by Month_Year
;


----------------how the user location was identified---------------------------------------
"Locations attendance for each user from user_user and their counts"
Create TABLE experimental.public.user_locations (User_ID Number(20,0), Location Number(20,0), resycount NUMBER(20,0)) 
AS
select u.id as "user ID", v.location_id as "Location", count(ri.id) as "resyCount"
 from user_info as u
  JOIN resy_info ri on ri.user_id = u.id
  left outer JOIN venue_info v on v.id = ri.venue_id

GROUP BY u.id, v.location_id
ORDER BY u.id, "resyCount" desc
;



"Selecting only a location with max number of reservations for each user= simple algorythm. In order to display all content a trick is to join a table with itself"
create table experimental.public.user_locations_by_max (User_ID NUMBER(20,0), Location Number (20,0), resycount NUMBER(20,0)) 
AS

SELECT ul.User_id, ul.location, ul.resycount
FROM user_locations ul
INNER JOIN (
    SELECT User_id, MAX(resycount) resycount
    FROM user_locations
    GROUP BY user_id
) ul2 ON ul.user_id = ul2.user_id AND ul.resycount = ul2.resycount
order by user_id



"Creating a table with only active users from user_info (<90 days)"
Create TABLE experimental.public.active_users (User_ID NUMBER(20,0), resycount NUMBER(20,0)) 
AS
select u.id as "active_user_ID", count(r.id) as "num of res for 90 days"
FROM USER_info AS u
JOIN resy_info r on r.user_id = u.id
where R.DATE_CREATED > '2018-07-01' and R.DATE_CREATED < '2018-09-31'
GROUP BY u.id
order by u.id
;

"Displaying users by market"
select ul.location,li.code, count(ul.user_id) 
from EXPERIMENTAL.PUBLIC.USER_LOCATIONS_BY_MAX as ul
inner join PC_FIVETRAN_DB.AURORA_CORE.LOCATION_INFO as li on li.id=ul.location
group by ul.location, li.code//, count (ul.user_id)
order by ul.location asc

"displaying ACTIVE users by market"
select ul.location ,li.code, count(ul.user_id) as "num of active users"
from EXPERIMENTAL.PUBLIC.USER_LOCATIONS_BY_MAX as ul
join EXPERIMENTAL.PUBLIC.active_users au on au.user_id=ul.user_id
inner join PC_FIVETRAN_DB.AURORA_CORE.LOCATION_INFO as li on li.id=ul.location
group by ul.location, li.code
order by ul.location asc


// Active users with all their completed reservation info

select uu.id, r.id, li.name, v.id
//select uu.id
from user_user as uu
inner join 
(
select u.id as user_id, ri.id as res_id
FROM USER_info AS u
JOIN resy_info ri on ri.user_id = u.id
where Ri.DATE_CREATED > '2018-07-01' and Ri.DATE_CREATED < '2018-10-01'
) as au on uu.foreign_id=au.user_id
inner join reservation_bookreservation r on r.user_id=uu.id
// //left join reservation_cancellation c on r.cancellation_id = c.id 
left join reservation_bookreservationstatus s on r.id = s.reservation_id
inner join venue_info v on v.id = r.venue_id
inner join location_info li on li.id = v.location_id
where
r.cancellation_id is null
//and u.foreign_type = 'resy_app'
and r.venue_id != 1278
;

"Setting and using a variable"
// The set function also only takes a constant, not the multiple results from a subquery.
set (min, max)=(40, 70);
select $min;
select avg(salary) from emp where age between $min and $max;

