Uploading the data from the local computer
In Terminal type: 
Innas-MacBook-Pro:Documents innakorzhouska$ alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql
--not needed in Windows
Innas-MacBook-Pro:Documents innakorzhouska$ snowsql
Innas-MacBook-Pro:Documents innakorzhouska$ snowsql -a yk58234.us-east-1 -u INNA
INNA#(no warehouse)@(no database).(no schema)>use database experimental;   (important to put “;”)
INNA#(no warehouse)@EXPERIMENTAL.PUBLIC>put file:///Users/innakorzhouska/Documents/user_locations.csv @"PC_FIVETRAN_DB”.”PUBLIC”."EXP_STAGE";
---------then in the Snowflake create a table and stage the file into new table
create table PC_FIVETRAN_DB.AURORA_CORE.user_location (User_ID NUMBER(20,0), Loc_primary NUMBER(20,0), Count_primary NUMBER(20,0), weekends NUMBER(20,0), weekdays NUMBER(20,0), score_primary NUMBER(20,0), loc_secondary NUMBER(20,0), Count_secondary NUMBER(20,0), score_secondary NUMBER(20,0));
COPY INTO PC_FIVETRAN_DB.AURORA_CORE.user_location from '@PC_FIVETRAN_DB.PUBLIC.EXP_STAGE/user_locations.csv.gz' file_format = (compression ='gzip');



COPY INTO PC_FIVETRAN_DB.AURORA_CORE.user_location from '@PC_FIVETRAN_DB.PUBLIC.EXP_STAGE/user_locations_final.csv.gz' file_format = (compression ='gzip');

create table PC_FIVETRAN_DB.AURORA_CORE.user_location (User_ID NUMBER(20,0), Loc_primary NUMBER(20,0), Count_primary NUMBER(20,0), weekends NUMBER(20,0), weekdays NUMBER(20,0), score_primary NUMBER(20,0), loc_secondary NUMBER(20,0), Count_secondary NUMBER(20,0), score_secondary NUMBER(20,0));

alter table user_locations alter user_ID set data type NUMBER(20,0);
