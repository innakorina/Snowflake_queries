-------------------What is Stage?---------
Stages and file formats are named database objects that can be used to simplify and streamline bulk loading data into and unloading data out of database tables.
#https://docs.snowflake.net/manuals/sql-reference/ddl-stage.html






Tested way to create new table in Snowflake and upload data from the local computer.


1. Upload a staged file to snowflake ("PC_FIVETRAN_DB"."PUBLIC"."EXP_STAGE") through SnowSQL:

In Terminal type: 
Innas-MacBook-Pro:Documents innakorzhouska$ alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql
--not needed in Windows
Innas-MacBook-Pro:Documents innakorzhouska$ snowsql -a yk58234.us-east-1 -u INNA
INNA#(no warehouse)@(no database).(no schema)>use database experimental;   (important to put “;”)
INNA#(no warehouse)@EXPERIMENTAL.PUBLIC>put file:///Users/innakorzhouska/Documents/user_locations.csv @"PC_FIVETRAN_DB"."PUBLIC"."EXP_STAGE";


2. In the Snowflake create a table and insert the data from the previously uploaded stage:


//create new table
create or replace table PC_FIVETRAN_DB.AURORA_CORE.user_locations_scores (User_ID NUMBER(20,0), uu_fid NUMBER(20,0),date_registered TIMESTAMP_TZ(9) ,total_resy_count NUMBER(20,0), completed_resys_count NUMBER(20,0),
                                                               total_no_shows NUMBER(20,0), total_cancellations NUMBER(20,0), total_late_cancellations NUMBER(20,0),
                                                               total_late_cancellation_penalty_vs_completed_resys NUMBER(20,0), late_cancel_vs_completed_resys NUMBER(20,0), 
                                                               no_shows_vs_completed_resys NUMBER(20,0), Loc_1 NUMBER(20,0),resy_1_count NUMBER(20,0), weekends_1 NUMBER(20,0),weekdays_1 NUMBER(20,0),
                                                               lunch_count_1 NUMBER(20,0), lunch_average_bill_size_1 NUMBER(20,0),dinner_count_1 NUMBER(20,0), dinner_average_bill_size_1 NUMBER(20,0), 
                                                               average_bill_size_1 NUMBER(20,0), score_1 NUMBER(20,0), freq_neighborhood VARCHAR(16777216),freq_cuisine NUMBER(20,0), freq_venue NUMBER(20,0), 
                                                               mean_venue_success_score NUMBER(20,0),mean_party_size NUMBER(20,0),mean_turn_time NUMBER(20,0), freq_source VARCHAR(16777216), 
                                                               loc_2 NUMBER(20,0), resy_2_count NUMBER(20,0), score_2 NUMBER(20,0),travel_cat VARCHAR(16777216),
                                                               activity VARCHAR(16777216), reserv_per_year NUMBER(20,0), loyalty_level VARCHAR(16777216), 
                                                               switched_percentage NUMBER(20,0), freq_adv_book_days NUMBER(20,0), notifies_count NUMBER(20,0), 
                                                               I1_score	NUMBER(20,0), I2_score NUMBER(20,0), I3_score NUMBER(20,0), I4_score NUMBER(20,0), I5_score NUMBER(20,0), I6_score NUMBER(20,0),
                                                               I7_score NUMBER(20,0), I8_score NUMBER(20,0), I9_score NUMBER(20,0), I10_score NUMBER(20,0), consumer_score NUMBER(20,0));
             
//create upload file format
create or replace file format my_csv_format_upload
  field_optionally_enclosed_by='"'
 // NULL_IF = ('\\N', 'NULL', 'NUL', '')
  field_delimiter = ','
  RECORD_DELIMITER ='\n';
  
COPY INTO PC_FIVETRAN_DB.AURORA_CORE.user_locations_scores from '@PC_FIVETRAN_DB.PUBLIC.EXP_STAGE/user_locations_scores.csv.gz' file_format = (format_name=my_csv_format_upload compression ='gzip',skip_header = 1,  ERROR_ON_COLUMN_COUNT_MISMATCH = False );

//rename table
alter table user_locations_scores RENAME TO user_locations;

//droptable
drop table user_locations_scores;

//change column type
alter table user_locations alter user_ID set data type NUMBER(20,0);

//add extra column if forgot
alter table user_locations ADD COLUMN some_new_column NUMBER(20,0);

//drop column if not needed
alter table user_locations COLUMN  'date_registered' DROP DEFAULT;
 
//test simple query
select ul.USER_ID 
from user_locations as ul
inner join PC_FIVETRAN_DB.AURORA_CORE.USER_INFO as ui on ui.ID=ul.USER_ID;

                                    
Warnings!: make sure the header is removed, there is no NAs in the data, and the csv format has the same number of the columns (the filewriting function doesn’t create a count column) 


______________________________________________________________________________________________________________________
----------------------------Unloading table from Snowflake to external locations--------------------------------------

Steps:
1. Create stage if doesnt exist. 

#--General format of creating a stage:
CREATE [ OR REPLACE ] [ TEMPORARY ] STAGE [ IF NOT EXISTS ] <internal_stage_name>
  [ FILE_FORMAT = ( { FORMAT_NAME = '<file_format_name>' | TYPE = { CSV | JSON | AVRO | ORC | PARQUET | XML } [ formatTypeOptions ] ) } ]
  [ COPY_OPTIONS = ( copyOptions ) ]
  [ COMMENT = '<string_literal>' ]
  
# Create an internal stage named my_int_stage with the default file format type (CSV):
create or replace stage my_int_stage
  copy_options = (on_error='skip_file');
  
# Create a temporary internal stage named my_int_stage that references a file format named my_csv_format:
 create or replace temporary stage my_int_stage
  file_format = my_csv_format;
  
in the last example future piping will use the file format listed there  


2. Unload Data (table or query results) to a Table/USER Stage. This is called piping and can be saved as a Pipe and called any time:
#General format of creating a pipe
CREATE [ OR REPLACE ] PIPE [ IF NOT EXISTS ] <name>
  [ COMMENT = '<string_literal>' ]
  AS <copy_statement>
  
#--example with creating a pipe (rare usage)
create pipe if not exists mypipe as copy into mytable from @mystage;
show pipes;

#-General format of the pipe without saving it to a pipe:
COPY INTO { internalStage | externalStage | externalLocation }
     FROM { [<namespace>.]<table_name> | ( <query> ) }
[ FILE_FORMAT = ( { FORMAT_NAME = '[<namespace>.]<file_format_name>' |
                    TYPE = { CSV | JSON | PARQUET } [ formatTypeOptions ] } ) ]
[ copyOptions ]


# where <namespace>=<database_name>.<schema_name>


# Fileformat should be either specified during the copy or created separately:

create or replace file format my_csv_unload_format
  type = 'CSV'
  field_delimiter = '|';




  ----------variations of the stage references
    @[<namespace>.]<int_stage_name>[/<path>]
  | @[<namespace>.]%<table_name>[/<path>]
  | @~[/<path>]
  
-------------examples
copy into '@mystage/path 1/file 1.csv' from mytable;
copy into '@%mytable/path 1/file 1.csv' from mytable;
copy into '@~/path 1/file 1.csv' from mytable;

----------Examples:

copy into @%orderstiny/result/data_
  from orderstiny file_format = (format_name ='vsv' compression='GZIP');

  
#Unload all rows to a single data file using the SINGLE copy option:
copy into @~ from home_sales
single = true;

# validation added= will display results on the go:  
copy into @my_stage
from (select * from orderstiny limit 5)
validation_mode='RETURN_ROWS';  



# Unloading Data to a User Stage. Note that the @~ character combination identifies a user stage
copy into @~/unload/ from mytable file_format = (format_name = 'my_csv_unload_format' compression = none);

#Unloading Data to a Table Stage. Note that the @% character combination identifies a table stage
copy into @%mytable/unload/ from mytable file_format = (format_name = 'my_csv_unload_format' compression = none);  
  
3. Use the SHOW and LIST commands view stages and list of files that have been unloaded to the stage:

SHOW STAGES [ LIKE '<pattern>' ] [ IN { ACCOUNT | [ DATABASE ] <db_name> | [ SCHEMA ] <schema_name> } ]
#Example:
SHOW STAGES  IN  DATABASE  PC_FIVETRAN_DB;
#display all files in a stage
list @%mytable;

# result showing table stage from last example
+-----------------------+------+----------------------------------+-------------------------------+
| name                  | size | md5                              | last_modified                 |
|-----------------------+------+----------------------------------+-------------------------------|
| unload/data_0_0_0.csv |   96 | 29918f18bcb35e7b6b628ca41024236c | Mon, 11 Sep 2017 17:45:20 GMT |
+-----------------------+------+----------------------------------+-------------------------------+





#the staged file is better be removed later:
REMOVE internalStage [ PATTERN = '<regex_pattern>' ]

4. From the terminal (SnowSQL) Use GET command to download the generated file(s) from the table stage to your local machine. 

For example:
get @PC_FIVETRAN_DB.AURORA_CORE.inna_stagetest/data_0_6_0.csv file:////Users/innakorzhouska/Documents;



------------------------Steps that work:
create or replace file format my_csv_format
  TYPE = CSV 
  field_optionally_enclosed_by='"'
  field_delimiter = ','
  TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
;
  
create or replace temporary stage inna_stage
  file_format = my_csv_format;  


copy into @inna_stagetest5 from USER_LOCATIONS_RAW 
    file_format = (format_name = 'my_csv_format' compression = none)
    HEADER = TRUE
         OVERWRITE = TRUE
         //SINGLE = TRUE
         MAX_FILE_SIZE =167772160; 
         

SHOW STAGES  IN  DATABASE  PC_FIVETRAN_DB;
list @inna_stagetest;

INNA#(no warehouse)@PC_FIVETRAN_DB.AURORA_CORE>get @PC_FIVETRAN_DB.AURORA_CORE.inna_stagetest/data_0_6_0.csv file:////Users/innakorzhouska/Documents;



