
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

