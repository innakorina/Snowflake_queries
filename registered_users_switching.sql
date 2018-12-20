# how to get user_info from user_user

select  uu.ID as uu_id, uu.foreign_id as uu_foreign_ID, u.ID as u_id,uu.mobile_number, u.date_created
FROM USER_info AS u
inner join user_user as uu on u.ID=uu.foreign_id
where Uu.foreign_type = 'resy_app'
order by u.date_created asc;
