
Descritpion: Sample queries for querying existing data

Aliases:
r   = reservation_bookreservation
ri  = resy_info
u   = user_info
uu  = user_user
vi  = venue_info
li  = location_info
s   = reservation_bookreservationstatus






===============================================Queries====================================================================
 
#---------------Basic queries we will be using a lot for pulling registered users and their reservations-------------------
--select only register users in user_user:
--there are 2 ways:longer but surely correct is to join 2 user yables and impose the condition Uu.foreign_type = 'resy_app'
--#1
select  uu.ID as uu_id, uu.foreign_id as uu_foreign_ID, u.ID as u_id,uu.mobile_number, u.date_created
FROM USER_info AS u
inner join user_user as uu on u.ID=uu.foreign_id
where Uu.foreign_type = 'resy_app'
order by u.date_created asc;
--for 2018-12-20 the results is 4,780,942

--#2 --skip join: gives almost the same results except 1 test user in user_user table that has Uu.foreign_type = 'resy_app' but is not in user_info
select  uu.foreign_id, uu.id 
from user_user as uu
where Uu.foreign_type = 'resy_app'
;
--for 2018-12-20 the result is 4,780,943


-- in order to view the user who is in user_user table but not in user_info:
select  inna.foreign_id as inna_f_id, uuu.id, uuu.foreign_id, uuu.*   
from          (select  uu.foreign_id 
              from user_info as ui
              inner join user_user as uu on uu.foreign_ID=ui.id
              where Uu.foreign_type = 'resy_app') as inna
left outer join USER_info AS uii on inna.foreign_id=uii.id
right outer join user_user as uuu on uii.ID=uuu.foreign_id
where Uuu.foreign_type = 'resy_app'
and inna.foreign_id is NULL
;






#--------------If join with reservation table--INTERESTING FACTS!!!!!!-----------------------------------------------------------------------------------

--fact #1: not all users made reservations in reservation_bookreservation table:

//display registered users in user_user_table-->who made reservation
SELECT uu.id, uu.foreign_id, count(uu.ID)
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_id
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
where uu.foreign_type='resy_app'
GROUP BY uu.id, uu.foreign_id
ORDER BY uu.id asc;
--for 2018-12-20 the results is 4,191,497

--fact #2: number of registered users who kept the reservations is even lower
//display registered users in user_user_table-->who made reservation excluding cancellations
SELECT uu.id, uu.foreign_id, count(uu.ID)
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_id
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
where uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id, uu.foreign_id;
--for 2018-12-20 the results is  3,571,028 ---> this is the number of records in user_locations table

#-----------------------------------------------getting reservations--------------------------------------------

# select only reservations from registered users from reservation_bookreservation, excluding cancellations
SELECT uu.id as "uu.user_id",uu.foreign_id as "uu.foreign_id",u.date_created, rr.date_created, rr.service_date as DAY,rr.TIME_SLOT, v.ID as venue_ID, v.neighborhood,v.location_id, rr.NUM_Seats,rr.SOURCE_ID
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_ID
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
INNER JOIN venue_info v on v.id = rr.venue_id
and uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id,DAY,uu.foreign_id,u.date_created, rr.date_created, rr.TIME_SLOT, v.ID, v.location_id, v.neighborhood,rr.NUM_Seats, rr.SOURCE_ID
ORDER BY uu.id desc, day desc;

 
===============================================================================================================================
 
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


--"Reservations per month and per city. Uses pivot to create a separate column for each city"
-- According to a Snowflake engineer, "The pivot command requires a constant value. 
-- You could try to get away with a stored procedure function that generates the columns, 
-- but thats uncharted territory."
-- A solution is to print the desired list of cities, then copy&paste into the query as an actual string.

-- Reservations per app city per month
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


--"Print list of in-app cities"

select listagg(distinct '''' || li.name || '''' ,', ') 
from location_info li
where li.show_in_app = TRUE
;


--"Reservations per month and per source. Uses case when to create a different column for each source"
-- Notice the difference with MySQL: SnowSQL requres "end" before closing parenthesis.

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

-- Using listagg to combine cells
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


--"New registered User counts per month per city using the user_locations_max table"

-- What is the number of new registered users, broken out by month, in 2018 by App city?

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
-- Locations attendance for each user from user_user and their counts
Create TABLE experimental.public.user_locations (User_ID Number(20,0), Location Number(20,0), resycount NUMBER(20,0)) 
AS
select u.id as "user ID", v.location_id as "Location", count(ri.id) as "resyCount"
 from user_info as u
  JOIN resy_info ri on ri.user_id = u.id
  left outer JOIN venue_info v on v.id = ri.venue_id

GROUP BY u.id, v.location_id
ORDER BY u.id, "resyCount" desc
;



-- Selecting only a location with max number of reservations for each user= simple algorythm. 
-- In order to display all content a trick is to join a table with itself"
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



-- Creating a table with only active users from user_info (<90 days)"
Create TABLE experimental.public.active_users (User_ID NUMBER(20,0), resycount NUMBER(20,0)) 
AS
select u.id as "active_user_ID", count(r.id) as "num of res for 90 days"
FROM USER_info AS u
JOIN resy_info r on r.user_id = u.id
where R.DATE_CREATED > '2018-07-01' and R.DATE_CREATED < '2018-09-31'
GROUP BY u.id
order by u.id
;

-- Displaying users by market"
select ul.location,li.code, count(ul.user_id) 
from EXPERIMENTAL.PUBLIC.USER_LOCATIONS_BY_MAX as ul
inner join PC_FIVETRAN_DB.AURORA_CORE.LOCATION_INFO as li on li.id=ul.location
group by ul.location, li.code//, count (ul.user_id)
order by ul.location asc

"-- Displaying ACTIVE users by market"
select ul.location ,li.code, count(ul.user_id) as "num of active users"
from EXPERIMENTAL.PUBLIC.USER_LOCATIONS_BY_MAX as ul
join EXPERIMENTAL.PUBLIC.active_users au on au.user_id=ul.user_id
inner join PC_FIVETRAN_DB.AURORA_CORE.LOCATION_INFO as li on li.id=ul.location
group by ul.location, li.code
order by ul.location asc


--  Active users with all their completed reservation info

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

-- Setting and using a variable"
// The set function also only takes a constant, not the multiple results from a subquery.
set (min, max)=(40, 70);
select $min;
select avg(salary) from emp where age between $min and $max;

                                                                                      
-- Cumulative sum or count using "over" and row specification
-- Note that order by is required in the window_frame statement
                                                                                      
// Users to date, one year per column                                                                                     
select td.month
, sum(case when td.year='2014' then td.users end) "2014"
, sum(case when td.year='2015' then td.users end) "2015"
, sum(case when td.year='2016' then td.users end) "2016"
, sum(case when td.year='2017' then td.users end) "2017"
, sum(case when td.year='2018' then td.users end) "2018"
, sum(case when td.year='2019' then td.users end) "2019"
from  
( 
select year(ui.date_created) year, month(ui.date_created) month
, count(ui.id) "month-to-month users"
, sum(count(ui.id)) over (order by year, month RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) users
from "PC_FIVETRAN_DB"."AURORA_CORE"."USER_INFO" ui
where year(ui.date_created) > '2013'
group by year(ui.date_created), month(ui.date_created)
order by year(ui.date_created), month(ui.date_created)
) td
group by td.month
order by td.month
;

      
      
===========================================Select members====================================================================================
      
      
//locating select members in user_user                                                                                                       
select sm.first_name,sm.last_name, uu.ID
from user_user as uu
inner join PC_FIVETRAN_DB.Public.select_clean_phone as sm on sm.email = uu.em_address                                                                                                    
;


//select members' reservations- all times, including cancellations                                                                                                       
select sm.first_name,sm.last_name, rr.user_ID, rr.date_booked, rr.venue_ID, rr.price, v.average_bill_size, v.cuisine_detail_id 
from user_user as uu
inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address
inner join reservation_bookreservation as rr on rr.user_ID=uu.ID                                                                                                      
inner join venue_info as v on v.ID=rr.venue_ID;


//select members' reservations in in 2018 year, excluding cancellations- will be using this query  as foundation to do further queries
select sm.first_name,sm.last_name,sm.email,rr.user_ID, count(rr.user_ID) 
from user_user as uu
inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address
inner join reservation_bookreservation as rr on rr.user_ID=uu.ID                                                                                                      
inner join venue_info as v on v.ID=rr.venue_ID
where rr.date_booked <'2019-01-01'
and rr.date_booked >='2018-01-01' 
and rr.cancellation_ID is Null
group by sm.first_name,sm.last_name,sm.email,rr.user_ID
order by sm.last_name
;


//venues  booked by select members by city
select li.name,v.name, count(v.name)
from reservation_bookreservation as rr
join (select sm.first_name,sm.last_name,sm.email,uu.id
        from user_user as uu
        inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address) as sm on rr.user_ID=sm.ID                                                                                                  
inner join venue_info as v on v.ID=rr.venue_ID 
inner join location_info as li on li.id=v.location_id
where rr.date_booked <'2019-01-01'
and rr.date_booked >='2018-01-01'
and rr.cancellation_ID is Null 
group by li.name, v.name
order by li.name, count(v.name) desc
;

#----------select members queries
//select members's total resies and total_spendings
select sm.*, res.total_resies, res.total_spent
from PC_FIVETRAN_DB.Public.select_members as sm 
join (select sm.first_name,sm.last_name,sm.email,rr.user_ID,count(rr.user_ID) as total_resies, sum(v.average_bill_size) as total_spent//, sum(rr.price)//,rr.date_booked,//rr.venue_ID 
from user_user as uu
inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address
inner join reservation_bookreservation as rr on rr.user_ID=uu.ID                                                                                                      
inner join venue_info as v on v.ID=rr.venue_ID
where rr.date_booked <'2019-01-01'
and rr.date_booked >='2018-01-01'
and rr.cancellation_ID is Null  
group by sm.first_name,sm.last_name,sm.email,rr.user_ID) as res on res.email=sm.email;
  
     

//select members's notifies
select sm.first_name, sm.last_name, count(n.id)
from "PC_FIVETRAN_DB"."AURORA_CORE"."NOTIFY_AVAIL_CONFIG" as n
join (select sm.first_name,sm.last_name,sm.email,uu.id
        from user_user as uu
        inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address) as sm on n.Global_user_id=sm.ID                                                                                                  
inner join venue_info as v on v.ID=n.venue_ID 
group by sm.first_name, sm.last_name
order by sm.first_name
;


//combined-showing only name, ID+ total resies, total_spendings and notifies
select s.first_name, s.last_name, res.user_id, res.total_resies, res.total_spent, count(n.id) as notifies
from (select sm.first_name,sm.last_name,sm.email,rr.user_ID,count(rr.user_ID) as total_resies, sum(v.average_bill_size) as total_spent//, sum(rr.price)//,rr.date_booked,//rr.venue_ID 
        from user_user as uu
        inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address
        inner join reservation_bookreservation as rr on rr.user_ID=uu.ID                                                                                                      
        inner join venue_info as v on v.ID=rr.venue_ID
        where rr.date_booked <'2019-01-01'
        and rr.date_booked >='2018-01-01'
        and rr.cancellation_ID is Null  
        group by sm.first_name,sm.last_name,sm.email,rr.user_ID) as res
join PC_FIVETRAN_DB.Public.select_members as s on s.email = res.email
left outer join "PC_FIVETRAN_DB"."AURORA_CORE"."NOTIFY_AVAIL_CONFIG"as n on n.Global_user_id=res.user_ID
group by s.first_name, s.last_name,res.user_ID,res.total_resies, res.total_spent
order by s.last_name
;               


//combined-displaying all info+total resies, total_spendings and notifies
select smm.*, a.total_resies, a.total_spent, a.notifies
from  (select s.first_name, s.last_name, res.user_id, s.email, res.total_resies, res.total_spent, count(n.id) as notifies
      from (select sm.first_name,sm.last_name,sm.email,rr.user_ID,count(rr.user_ID) as total_resies, sum(v.average_bill_size) as total_spent//, sum(rr.price)//,rr.date_booked,//rr.venue_ID 
              from user_user as uu
              inner join PC_FIVETRAN_DB.Public.select_members as sm on sm.email = uu.em_address
              inner join reservation_bookreservation as rr on rr.user_ID=uu.ID                                                                                                      
              inner join venue_info as v on v.ID=rr.venue_ID
              where rr.date_booked <'2019-01-01'
              and rr.date_booked >='2018-01-01'
              and rr.cancellation_ID is Null  
              group by sm.first_name,sm.last_name,sm.email,rr.user_ID) as res
      join PC_FIVETRAN_DB.Public.select_members as s on s.email = res.email
      left outer join "PC_FIVETRAN_DB"."AURORA_CORE"."NOTIFY_AVAIL_CONFIG"as n on n.Global_user_id=res.user_ID
      group by s.first_name, s.last_name,res.user_ID,s.email,res.total_resies, res.total_spent)  as a
join PC_FIVETRAN_DB.Public.select_members as smm on smm.email=a.email
order by smm.last_name
;                                                                                                               
      

      
// Reservations
// all users with one row for each reservation
// since some loc_2=null, li must be via left join

      
      
select u.id as "real user id"
, r.id as "reservation id"
, r.num_seats as "party size"
, r.date_booked as "date booked"
, r.service_date as "date of visit"
, r.from_app as "booked via app"
, (case when r.is_walkin = 0 then 'False' else 'True' end) as "Walkin"
, (case when r.cancellation_id is null then 'False' else 'True' end) as "Cancelled"
, (case when s.status_id = 2 then 'True' else 'False' end) as "No show"
, r.date_created
//
from user_user u
//join user_locations ul on u.id = ul.user_id
join reservation_bookreservation r on u.id = r.user_id
join reservation_bookreservationstatus s on s.reservation_id=r.id 
join venue_info v on v.id = r.venue_id
join location_info li on li.id = v.location_id
left outer join wait_list_waitlist w on w.reservation_id = r.id
join (
//  
-- ushg diners
-- all u.id for registered users who have gone to a ushg restaurant
-- 102,942 rows registered users vs 132,800 rows all diners
 
        select u.id user_id
                ,vi.name venue_name
                ,r.service_date service_date
                ,r.id res_id 
        from reservation_bookreservation r
        join user_user u on u.id = r.user_id and u.foreign_type='resy_app'
        join venue_info vi on vi.id = r.venue_id
        join venue_group vg on vi.venue_group_id = vg.id
      
        where vg.name = 'USHG'
        order by r.service_date asc
    ) ushg on ushg.user_id = u.id
and r.is_imported = 0 //exclude imported
where r.date_created between '2018-06-31' and '2018-12-31'
and u.date_created > '2014-01-01'
//group by u.id
order by r.date_created desc
;      

-- Query for historical month over month active users      
-- Using date as a variable to get active users in the last 1, 2, and 3 months. 
-- The same query can be repeated for each month.
      
Create or replace TABLE "TESTDB"."PUBLIC".active_users ( month VARCHAR(16777216), m NUMBER(20,0), active_30 NUMBER(20,0), active_60 NUMBER(20,0), active_90 NUMBER(20,0));

--
INSERT INTO "TESTDB"."PUBLIC".active_users (month, m, active_30, active_60, active_90)
select 'Jan' month, 1 m
,g.user30 user30
,g.user60 user60
,g.user90 user90
from
(
select '2014-01-01' d0
, dateadd(month, -1, to_date(d0)) d1
, dateadd(month, -2, to_date(d0)) d2
, dateadd(month, -3, to_date(d0)) d3
, count((case when lad.last_activity_date between d1 and d0 then lad.user_id end)) user30
, count((case when lad.last_activity_date between d2 and d0 then lad.user_id end)) user60
, count((case when lad.last_activity_date between d3 and d0 then lad.user_id end)) user90
FROM "TESTDB"."PUBLIC"."LAST_ACTIVITY_DATE" lad
where lad.reg_date < d0
  and lad.reg_date <= lad.last_activity_date
) g
;

INSERT INTO "TESTDB"."PUBLIC".active_users (month, m, active_30, active_60, active_90)
select 'Feb' month, 2 m
,g.user30 user30
,g.user60 user60
,g.user90 user90
from
(
select '2014-02-01' d0
, dateadd(month, -1, to_date(d0)) d1
, dateadd(month, -2, to_date(d0)) d2
, dateadd(month, -3, to_date(d0)) d3
, count((case when lad.last_activity_date between d1 and d0 then lad.user_id end)) user30
, count((case when lad.last_activity_date between d2 and d0 then lad.user_id end)) user60
, count((case when lad.last_activity_date between d3 and d0 then lad.user_id end)) user90
FROM "TESTDB"."PUBLIC"."LAST_ACTIVITY_DATE" lad
where lad.reg_date < d0
  and lad.reg_date <= lad.last_activity_date
) g
;
 
-- Generate pairs of real user ids and fake user ids
-- Save to newly crated table
-- pick a seed value
          
// create real and fake id pairs table
Create or replace TABLE "TESTDB"."PUBLIC".fake_user_ids ( fake_id NUMBER(20,0), real_id NUMBER(20,0))
;
--
// random numbers have to be first column
// random(seed)
INSERT INTO "TESTDB"."PUBLIC".fake_user_ids (fake_id, real_id)
select distinct(abs(random(1))) fake_id
,ua.id real_id
from "PC_FIVETRAN_DB"."ANALYTICS"."USERS" ua
where ua.id is not NULL
//and ua.id<100
;
    
// Percent of total using group by and sum over ()
// Get percent of max by using 
// max(count_per_venue) over () max_all_venues
                           
select r.venue_id venueid
, sum(count(distinct r.id)) over () total_all_venues
, count(distinct r.id) count_per_venue
, count_per_venue / total_all_venues*100 percent_of_total 
from "PC_FIVETRAN_DB"."ANALYTICS"."RESERVATIONS" r
where r.venue_id in (3239, 1686, 3026)
and r.status_category not in ('Cancellation', 'No-Show')
and r.date_booked > dateadd(week, -1, current_date())
group by r.venue_id
;

 // count per venue using partition over                
 select r.venue_id
, count(distinct r.id) over (partition by r.venue_id order by r.venue_id) count_per_venue
from "PC_FIVETRAN_DB"."ANALYTICS"."RESERVATIONS" r
where r.venue_id is not NULL//in (3239, 1686, 3026)
and r.status_category not in ('Cancellation', 'No-Show')
and r.date_booked > dateadd(week, -1, current_date())
limit 4
;                           
                            
                            
                            
                            
