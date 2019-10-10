Description: Sample queries to manage objects such as creating tables, etc.

use database "PC_FIVETRAN_DB" ;
use schema "AURORA_CORE";

create table "user_locations_by_max" clone "EXPERIMENTAL"."PUBLIC"."USER_LOCATIONS_BY_MAX";


clone "EXPERIMENTAL"."PUBLIC"."USER_LOCATIONS_BY_MAX" into table ;
--- need to verify and fix

// rerun the following any time a table is added to the schema
grant all privileges on all tables in schema "PC_FIVETRAN_DB"."AURORA_CORE" to role looker_role;

// change ownership of looker_scratch table or schema to pc_fivetran_role
grant ownership on schema looker_scratch to role pc_fivetran_role; //REVOKE CURRENT GRANTS;

-- add a view to a share
GRANT SELECT ON VIEW PC_FIVETRAN_DB.ANALYTICS.NOTIFY TO SHARE SIMONDATA_SHARE;

-- allow a non-owner role to be able to add views to share
-- https://docs.snowflake.net/manuals/user-guide/security-access-privileges-shares.html
grant usage on schema theSchemaName to theNonOwnerRoleName;
grant select on all tables in schema theSchemaName to role theNonOwnerRoleName with grant option;