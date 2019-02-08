Data insights, discored by working with production data:

1. There are 19MM records(02-07-2019) that dont have assigned user_ID: most of them are walkins, but 40,000 are not.

select *
from reservation_bookreservation
where user_id is NULL
and is_walkin =0
order by date_created desc;




2. there are about 20,000(02-07-2019) reservations that are not in status table
