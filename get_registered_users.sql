#---------------Basic queries we will be using a lot for pulling registered users and their reservations-------------------
# select only register users in user_user
select  uu.ID as uu_id, uu.foreign_id as uu_foreign_ID, u.ID as u_id,uu.mobile_number, u.date_created
FROM USER_info AS u
inner join user_user as uu on u.ID=uu.foreign_id
where Uu.foreign_type = 'resy_app'
order by u.date_created asc;

#for 2018-12-20 the results is 4,716,560

#--------------If join with reservation table--INTERESTING FACTS!!!!!!-----------------------------------------------------------------------------------

#1)not all users made reservations in reservation_bookreservation table:

//display registered users in user_user_table-->who made reservation
SELECT uu.id, uu.foreign_id, count(uu.ID)
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_id
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
where uu.foreign_type='resy_app'
GROUP BY uu.id, uu.foreign_id
ORDER BY uu.id asc;

#for 2018-12-20 the results is 4,191,497

#2)number of registered users who kept the reservations is even lower

//display registered users in user_user_table-->who made reservation excluding cancellations
SELECT uu.id, uu.foreign_id, count(uu.ID)
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_id
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
where uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id, uu.foreign_id;

#for 2018-12-20 the results is  3,571,028 ---> sie of the user locations table

#-----------------------------------------------getting reservations--------------------------------------------

# select only reservations from registered users from reservation_bookreservation, excluding cancellations
SELECT uu.id as "uu.user_id",uu.foreign_id as "uu.foreign_id",u.date_created, rr.date_created, rr.service_date as DAY,rr.TIME_SLOT, v.ID as venue_ID, v.neighborhood,v.location_id, rr.NUM_Seats,rr.SOURCE_ID
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_ID
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
INNER JOIN venue_info v on v.id = rr.venue_id
//where rr.service_date > '2016-01-01'
and uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id,DAY,uu.foreign_id,u.date_created, rr.date_created, rr.TIME_SLOT, v.ID, v.location_id, v.neighborhood,rr.NUM_Seats, rr.SOURCE_ID
ORDER BY uu.id desc, day desc;
