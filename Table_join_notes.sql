(this is a markdown (.md) file. Use double space to go to a new line.   
Use "Preview" to check format is displaying as you want it before committing changes.)


## user_user uu
user_user.id matches up to reservation_bookreservation.user_id  
user_user.id do not match with resy_info.user_id (They did match before 2017)
user_user.foreign_id matches up to resy_info_user_id  

## user_info u  (sometimes ui) 
user_info.id matches up to resy_info.user_id  


# query to select only register users in user_user
select  uu.ID as uu_id, uu.foreign_id as uu_foreign_ID, u.ID as u_id,uu.mobile_number, u.date_created
FROM USER_info AS u
inner join user_user as uu on u.ID=uu.foreign_id
where Uu.foreign_type = 'resy_app'
order by u.date_created asc;

// do registered users share duplicate uu.ids with non-registered ones? No (none in analytics.users)
// how many non-registered users have the same uu.id as a registered user? 0 in analytics.users. User_user might have some.
// This is why AJ simply joins via user_id in the Reservations Looker explore.
select count(aup.id)
from "PC_FIVETRAN_DB"."ANALYTICS"."USERS" aup
where foreign_id is NULL
and foreign_type != 'resy_app'
and aup.id in 
(
select au.id 
  from "PC_FIVETRAN_DB"."ANALYTICS"."USERS" au
  where au.foreign_id is not NULL
  and foreign_type = 'resy_app'// 26MM distinct au.id have NULL foreign_id
)
;

-- This is how analytics.users and analytics.reservations can be joined (from LookML code)
  ${venue_group.id} = ${venue.venue_group_id} ;
  ${reservations.user_id} = ${users.id} ;


## venue_info v  
r.venue_id = v.id  
v.enable_for_app: identifies venues displayed in app


## reservation_bookreservation r  
r.venue_id = 1278 is a test venue. Should be excluded 
r.cancellation_id is null excludes cancelled reservations



# query to select only reservations from registered users from reservation_bookreservation, excluding cancellations
SELECT uu.id as "uu.user_id",rr.service_date as DAY, v.location_id
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_ID
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
INNER JOIN venue_info v on v.id = rr.venue_id
and uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id,DAY, v.location_id, 
ORDER BY uu.id asc, day desc;


## location_info li
li.show_in_app: identifies cities that are in-app
li.show_on_web: identifies cities listed in website


