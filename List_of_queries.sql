
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

