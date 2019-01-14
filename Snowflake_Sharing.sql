-- Commands to grant access to an ouside organization with a Snowflake Sharing account to a particular table
-- Run from a Resy Snowflake instance (or snowsql client) from an account with accountadmin privileges

-- role won't have access to any table that is re-created
-- we will need to regularly run a bash script after dbt that gives access again to all tables to all thei appropriate roles
 
use role accountadmin;

create share nameOfOutsideOrgShare;

-- doesn't let them do anything aside from vetting that a table exists, etc
-- Shares only give them read-only access to individual tables 
-- There's a log of activity of each share
grant usage on database "PC_FIVETRAN_DB" to share nameOfOutsideOrgShare;

// won't work across regions. We're in region us-east-1.
alter share simondata_share add accounts=outsideOrgSnoflakeSharingAccountName

//show grants of share simondata_share;
grant usage on schema "PC_FIVETRAN_DB"."AURORA_CORE" to share nameOfOutsideOrgShare;
grant select on table "PC_FIVETRAN_DB"."AURORA_CORE"."USER_LOCATIONS" to share nameOfOutsideOrgShare;
