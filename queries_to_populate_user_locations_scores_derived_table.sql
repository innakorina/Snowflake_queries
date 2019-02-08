Please review fields definitions here:
https://docs.google.com/spreadsheets/d/15xZstPOQ6v2s7VQ1FxpMQKyIDi4hXuatrWDnKxshmSY/edit#gid=158892803

Choose fields you prefer to work on and put your name next to it's name in the file above and update the status of the query.
Paste your completed query below
#=============================================================================================================================


//creating derived table and populating activity
CREATE TABLE "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES_DERIVED" CLONE "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES";
grant all privileges on table "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES_DERIVED"  to role LOOKER_ROLE;



//UU_FID



//DATE_REGISTERED
update user_locations_scores_derived ulsd
    set  ulsd.date_registered= uu.date_created
    from user_user uu
    where uu.id=ulsd.user_id;



//TOTAL_RESY_COUNT
update USER_LOCATIONS_SCORES_DERIVED ulsd
set ulsd.TOTAL_RESY_COUNT=rrr.total_resys
from (select rr.user_id, count(rr.user_id) total_resys
      from reservation_bookreservation rr 
      group by rr.user_id) rrr
where rrr.user_id=ulsd.user_id;


//COMPLETED_RESYS_COUNT---goes into I1_score



//TOTAL_NO_SHOWS



//TOTAL_CANCELLATIONS



//TOTAL_LATE_CANCELLATIONS



//TOTAL_LATE_CANCELLATION_PENALTY_VS_COMPLETED_RESYS---goes into I3_score



//LATE_CANCEL_VS_COMPLETED_RESYS



//NO_SHOWS_VS_COMPLETED_RESYS---goes into I4_score



//LOC_1
alter table user_locations_scores_derived ADD COLUMN loc_1_name VARCHAR(16777216);

update user_locations_scores_derived ulsd
    set  ulsd.loc_1_name= li.name
    from location_info li
    where li.id=ulsd.loc_1;

alter table user_locations_scores_derived drop column loc_1;
alter table user_locations_scores_derived RENAME COLUMN loc_1_name to loc_1;


//RESY_1_COUNT



//WEEKENDS_1



//WEEKDAYS_1



//LUNCH_COUNT_1



//LUNCH_AVERAGE_BILL_SIZE_1



//DINNER_COUNT_1



//DINNER_AVERAGE_BILL_SIZE_1



//AVERAGE_BILL_SIZE_1---goes into I7_score



//SCORE_1
//not possible in snowflake


//FREQ_NEIGHBORHOOD



//FREQ_CUISINE



//FREQ_VENUE
alter table user_locations_scores_derived ADD COLUMN freq_venue_name VARCHAR(16777216);

update user_locations_scores_derived ulsd
    set  ulsd.freq_venue_name= vi.name
    from venue_info vi
    where vi.id=ulsd.freq_venue;

alter table user_locations_scores_derived drop column freq_venue;
alter table user_locations_scores_derived RENAME COLUMN freq_venue_name to freq_venue;




//MEAN_VENUE_SUCCESS_SCORE---goes into I9_score







//MEAN_PARTY_SIZE----goes into I6_score
//MEAN_TURN_TIME----goes into I10_score
update user_locations_scores_derived ulsd
set ulsd.MEAN_PARTY_SIZE= ar.mean_covers, ulsd.mean_turn_time= ar.mean_turn_time_cleaned 
from ( select AVG(a.covers) as mean_covers, a.user_id, CEIL(AVG(case when a.turn_time is NULL then 107
                                                                when a.turn_time>300 then 107
                                                                else a.turn_time end)) as mean_turn_time_cleaned
       from "PC_FIVETRAN_DB"."ANALYTICS"."RESERVATIONS" as a
       inner join user_locations_scores_derived d on d.user_id=a.user_id
       where a.status in ('Dined','Custom Venue Status')
      group by a.user_id
      ) as ar
where ar.user_id=ulsd.user_id;




//FREQ_SOURCE



//LOC_2
alter table user_locations_scores_derived ADD COLUMN loc_2_name VARCHAR(16777216);

update user_locations_scores_derived ulsd
    set  ulsd.loc_2_name= li.name
    from location_info li
    where li.id=ulsd.loc_2;

alter table user_locations_scores_derived drop column loc_2;
alter table user_locations_scores_derived RENAME COLUMN loc_2_name to loc_2;


//RESY_2_COUNT



//SCORE_2
//not possible in snowflake



//TRAVEL_CAT
//not possible in snowflake



//ACTIVITY---goes into I8_score
//LAST_ACTIVITY
ALTER TABLE "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES_DERIVED" ADD COLUMN last_activity TIMESTAMP_TZ(9);
update USER_LOCATIONS_SCORES_DERIVED ulsd
set ulsd.last_activity=rrr.last,  activity= case when last_activity >= DATEADD(day,-30,CURRENT_DATE()) then 'active30'
                                                          when last_activity between DATEADD(day,-60,CURRENT_DATE()) and DATEADD(day,-30,CURRENT_DATE()) then 'active60' 
                                                          when last_activity between DATEADD(day,-90,CURRENT_DATE()) and DATEADD(day,-60,CURRENT_DATE()) then 'active90'
                                                          when last_activity between DATEADD(day,-360,CURRENT_DATE()) and DATEADD(day,-90,CURRENT_DATE()) then 'lapsed' 
                                                          when last_activity < DATEADD(day,-360,CURRENT_DATE()) then 'abondended' end
from (select rr.user_id, max(rr.date_created) last 
      from reservation_bookreservation rr 
      group by rr.user_id) rrr
where rrr.user_id=ulsd.user_id;



//RESERV_PER_YEAR---goes into I2_score



//LOYALTY_LEVEL



//SWITCHED_PERCENTAGE
//not possible in snowflake


//FREQ_ADV_BOOK_DAYS



//NOTIFIES_COUNT---goes into I5_score



//I1_SCORE



//I2_SCORE



//I3_SCORE



//I4_SCORE



//I5_SCORE



//I6_SCORE



//I7_SCORE



//I8_SCORE



//I9_SCORE



//I10_SCORE



//CONSUMER_SCORE_RAW



//CONSUMER_SCORE

