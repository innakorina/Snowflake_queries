
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
count of reservations by active users
active users = r.date_created < [90 days]

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