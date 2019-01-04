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

# select only reservations from registered users from reservation_bookreservation, excluding cancellations (for my code i filtered after 2016)
SELECT uu.id as "uu.user_id",rr.service_date as DAY, v.location_id
FROM USER_user AS uu
inner join user_info as u on u.ID=uu.foreign_ID
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
INNER JOIN venue_info v on v.id = rr.venue_id
and uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id,DAY, v.location_id, 
ORDER BY uu.id asc, day desc;