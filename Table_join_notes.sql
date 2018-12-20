(this is a markdown (.md) file. Use double space to go to a new line.   
Use "Preview" to check format is displaying as you want it before committing changes.)


## user_user uu
user_user.id matches up to reservation_bookreservation.user_id  
user_user.id do not match with resy_info.user_id (They did match before 2017)
user_user.foreign_id matches up to resy_info_user_id  

## user_info u  
user_info.id matches up to resy_info.user_id  


# qyery to select only register users in user_user
select  uu.ID as uu_id, uu.foreign_id as uu_foreign_ID, u.ID as u_id,uu.mobile_number, u.date_created
FROM USER_info AS u
inner join user_user as uu on u.ID=uu.foreign_id
where Uu.foreign_type = 'resy_app'
order by u.date_created asc;



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


