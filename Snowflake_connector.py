Skip to content
 
Search or jump to…

Pull requests
Issues
Marketplace
Explore
 @innakorina Sign out
1
1 0 innakorina/Snowflake_queries
 Code  Issues 0  Pull requests 0  Projects 0  Wiki  Insights  Settings
Snowflake_queries/Python_connector.py
61b1691  10 hours ago
@innakorina innakorina corrected code
     
121 lines (101 sloc)  3.97 KB
Python-Snowflake jobs

Installing snowflake python connector
pip install --upgrade snowflake-connector-python  (for Python 2)
pip3 install --upgrade snowflake-connector-python
Urllib error

  File "/anaconda3/lib/python3.6/site-packages/pip/_internal/download.py", line 480, in path_to_url
    url = urllib_parse.urljoin('file:', urllib_request.pathname2url(path))
  File "/anaconda3/lib/python3.6/urllib/request.py", line 1739, in pathname2url
    return quote(pathname)
NameError: name 'quote' is not defined
Solution: re-install conda and anaconda
(I had a doctored version urrllib)
attempted to install connector within a virtual environment, 
“conda update anaconda” ran but didn’t help
Ran in my home environment:
conda update conda    (updating the package manager, includes new copy of urllib3)
conda update anaconda  (updating update the meta-package)
Tried 
pip3 install --upgrade snowflake-connector-python
yay, snowflake connector installed correctly!


Establish secure snowflake connection
From any text editor, create a file named validate.py with contents: (replace password)
#!/usr/bin/env python
import snowflake.connector

# Gets the version
ctx = snowflake.connector.connect(
   user='resyanalytics',
   password='yourSnowflakePassword',
   account='yk58234.us-east-1'
   )
cs = ctx.cursor()
try:
   cs.execute("SELECT current_version()")
   one_row = cs.fetchone()
   print(one_row[0])
finally:
   cs.close()
ctx.close()

From Terminal, run 
>> python validate.py

#----------Methods and attributes in the connector package--------
https://docs.snowflake.net/manuals/user-guide/python-connector-example.html#connecting-to-snowflake
http://initd.org/psycopg/docs/cursor.html


#--------------------------------------------Beautiful py file:

#!/usr/bin/env python
import snowflake.connector

#creating a connection
ctx = snowflake.connector.connect(
    user='inna',
    password='...',
    account='yk58234.us-east-1'
    )
#creating a cursor of the current connection
cs=ctx.cursor()

# =============================================================================
#fetching the current version of the python
try:
    cs.execute("SELECT current_version()")
    one_row = cs.fetchone()
    print(one_row[0])
finally:
    cs.close()
cs=ctx.cursor()
# =============================================================================
#Use specific WH, DB
ctx.cursor().execute("USE warehouse PC_FIVETRAN_WH")
ctx.cursor().execute("USE PC_FIVETRAN_DB.AURORA_CORE")
# =============================================================================
#create table
ctx.cursor().execute(
    "CREATE OR REPLACE TABLE "
    "testtable(col1 integer, col2 string)")
#insert test data into new table
ctx.cursor().execute(
    "INSERT INTO testtable(col1, col2) "
    "VALUES(123, 'test string1'),(456, 'test string2')") 
# =============================================================================
 # Querying Data

#method #1
query1 = ctx.execute_string("SELECT USER_ID,LOC_PRIMARY FROM USER_LOCATIONS WHERE LOC_primary = '2';")
query2 = ctx.execute_string(
        "select u.ID from user_info as u order by u.ID;")
query3 = ctx.execute_string(
        "SELECT * FROM USER_LOCATIONS WHERE USER_ID = '8';"    
        "SELECT * FROM USER_LOCATIONS WHERE USER_ID = '100';")
query4 = ctx.execute_string ("SELECT uu.id, uu.foreign_id, count(uu.ID) FROM USER_user AS uu inner join user_info as u on u.ID=uu.foreign_id inner JOIN reservation_bookreservation rr on rr.user_id = uu.id where uu.foreign_type='resy_app' and rr.CANCELLATION_ID is null GROUP BY uu.id, uu.foreign_id  ORDER BY uu.id asc;")

#displaying content
for cursor in query4:
    for row in cursor: 
       print(row[0:10])
# =============================================================================
#method #2
cs=ctx.cursor()
try:
    cs.execute("SELECT col1, col2 FROM testtable")
    for (col1, col2) in cs:
        print('{0}, {1}'.format(col1, col2))
finally:
    cs.close()      
# =============================================================================    
ctx.close()





© 2019 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
Press h to open a hovercard with more details.
