Please review fields definitions here:
https://docs.google.com/spreadsheets/d/15xZstPOQ6v2s7VQ1FxpMQKyIDi4hXuatrWDnKxshmSY/edit#gid=158892803

Choose fields you prefer to work on and put your name next to it's name in the file above and update the status of the query.
Paste your completed query below
#=============================================================================================================================
//creating derived table and populating activity
CREATE TABLE "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES_DERIVED" CLONE "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES";
grant all privileges on table "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES_DERIVED"  to role LOOKER_ROLE;
ALTER TABLE "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS_SCORES_DERIVED" ADD COLUMN last_activity TIMESTAMP_TZ(9);



//UU_FID



//DATE_REGISTERED
update user_locations_scores_derived ulsd
    set  ulsd.date_registered= uu.date_created
    from user_user uu
    where uu.id=ulsd.user_id;



//TOTAL_RESY_COUNT



//COMPLETED_RESYS_COUNT



//TOTAL_NO_SHOWS



//TOTAL_CANCELLATIONS



//TOTAL_LATE_CANCELLATIONS



//TOTAL_LATE_CANCELLATION_PENALTY_VS_COMPLETED_RESYS



//LATE_CANCEL_VS_COMPLETED_RESYS



//NO_SHOWS_VS_COMPLETED_RESYS



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



//AVERAGE_BILL_SIZE_1



//SCORE_1



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




//MEAN_VENUE_SUCCESS_SCORE



//MEAN_PARTY_SIZE
//MEAN_TURN_TIME
update user_locations_scores_derived ulsd
set ulsd.MEAN_PARTY_SIZE= mean_covers, ulsd.mean_turn_time= rrr.mean_tt  
from (select ar.user_id, AVG(ar.covers) as mean_covers, AVG(ar.turn_time) as mean_tt  //yet need to replace NA with 107 (min)
      from "PC_FIVETRAN_DB"."ANALYTICS"."RESERVATIONS" ar
      where ar.status in ('Dined','Custom Venue Status')
      group by ar.user_id) rrr
where rrr.user_id=ulsd.user_id;





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



//TRAVEL_CAT
//not possible in snowflake



//ACTIVITY 
//and LAST_ACTIVITY
;
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



//RESERV_PER_YEAR



//LOYALTY_LEVEL



//SWITCHED_PERCENTAGE



//FREQ_ADV_BOOK_DAYS



//NOTIFIES_COUNT



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

