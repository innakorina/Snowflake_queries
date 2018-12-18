Snowflake Tutorial


SQL try_me tutorial:
http://www.mysqltutorial.org/tryit/


Create table 
Ex:
create or replace table count_example(i int, j int);

Remove table:
drop table count_example

Rename table:
alter table active_users_info RENAME TO active_users

Clone table
CREATE TABLE PC_FIVETRAN_DB.AURORA_CORE.user_locations CLONE PC_FIVETRAN_DB.PUBLIC.user_locations;


https://docs.snowflake.net/manuals/sql-reference/sql/create-table.html




Insert values:
Ex1:

insert into count_example values
(11,101), (11,102), (11,null), (12,101), (null,101), (null,102);

 Ex2:

insert into my_table (x2, x5, x7, x10) select x2, x5, x7, x10 from t

3. Altering a table and columns:
https://docs.snowflake.net/manuals/sql-reference/sql/alter-table-column.html

 ALTER TABLE <name> { ALTER | MODIFY } [ ( ]
                                          [ COLUMN ] <col1_name> DROP DEFAULT,
                                          [ COLUMN ] <col1_name> { [ SET ] NOT NULL | DROP NOT NULL },
                                          [ COLUMN ] <col1_name> [ [ SET DATA ] TYPE ] <type>,
                                          [ COLUMN ] <col1_name> COMMENT '<string>',
                                          [ [ COLUMN ] <col2_name> ... ]
                                      [ ) ]

alter table user_locations alter user_ID set data type NUMBER(20,0);

 
4. Copy from the file
copy t (x1, ... , x10) from '/path/to/my_file' with (format csv)


5. Save query as a new table

CREATE TABLE experimental.public.active_users2 (User_ID NUMBER(20,0), resycount NUMBER(20,0)) 
AS

select u.id as "active_user_ID", count(r.id) as "num of res for 90 days"
FROM USER_info AS u
JOIN resy_info r on r.user_id = u.id
where R.DATE_CREATED > '2018-07-20' and R.DATE_CREATED < '2018-11-01'
GROUP BY u.id
order by u.id
;


6. Select
https://docs.snowflake.net/manuals/sql-reference/sql/select.html
Ex:

select * from count_example;
+------+------+
|    I |    J |
|------+------|
|   11 |  101 |
|   11 |  102 |
|   11 | NULL |
|   12 |  101 |
| NULL |  101 |
| NULL |  102 |
+------+------+

7. Subqueries

https://docs.snowflake.net/manuals/sql-reference/operators-subquery.html
This query shows an uncorrelated subquery in a WHERE clause. The subquery gets the per capita GDP of Brazil, and the outer query selects all the jobs (in any country) that pay less than the per-capita GDP of Brazil. The subquery is uncorrelated because the value that it returns does not depend upon any column of the outer query. The subquery only needs to be called once during the entire execution of the outer query.
select p.name, p.annual_wage, p.country
  from pay as p
  where p.annual_wage < (select per_capita_gdp
                           from international_gdp
                           where name = 'Brazil');
This shows a correlated subquery in a WHERE clause. This query lists jobs where the annual pay of the job is less than the per-capita GDP in that country. This subquery is correlated because it is called once for each row in the outer query and is passed a value (p.country (country name)) from that row.
select p.name, p.annual_wage, p.country
  from pay as p
  where p.annual_wage < (select max(per_capita_gdp)
                           from international_gdp i
                           where p.country = i.name);




8. Count
https://docs.snowflake.net/manuals/sql-reference/functions/count.html

Ex:
select count(*), count(i), count(distinct i), count(j), count(distinct j) from count_example;

+----------+----------+-------------------+----------+-------------------+
| COUNT(*) | COUNT(I) | COUNT(DISTINCT I) | COUNT(J) | COUNT(DISTINCT J) |
|----------+----------+-------------------+----------+-------------------|
|        6 |        4 |                 2 |        5 |                 2 |
+----------+----------+-------------------+----------+-------------------+

select i, count(*), count(j) from count_example group by i;

+------+----------+----------+
|    I | COUNT(*) | COUNT(J) |
|------+----------+----------|
|   11 |        3 |        2 |
|   12 |        1 |        1 |
| NULL |        2 |        2 |
+------+----------+----------+

8.Dense_Rank ranking the values from certain field

select state, bushels_produced, dense_rank()
  over (order by bushels_produced desc)
  from corn_production;

+--------+------------------+------------+
|  state | bushels_produced | DENSE_RANK |
+--------+------------------+------------+
| Kansas |              130 |          1 |
| Kansas |              120 |          2 |
| Iowa   |              110 |          3 |
| Iowa   |              100 |          4 |
+--------+------------------+------------+
select state, bushels_produced, dense_rank()
  over (partition by state order by bushels_produced)
  from corn_production;

+--------+------------------+------------+
|  state | bushels_produced | DENSE_RANK |
+--------+------------------+------------+
| Iowa   |              110 |          1 |
| Iowa   |              100 |          2 |
| Kansas |              130 |          1 |
| Kansas |              120 |          2 |
+--------+------------------+------------+


https://docs.snowflake.net/manuals/sql-reference/functions/dense_rank.html

9. Case
https://docs.snowflake.net/manuals/sql-reference/functions/case.html

select
    column1,
    case
        when column1=1 then 'one'
        when column1=2 then 'two'
        else 'other'
    end as result
from (values(1),(2),(3)) v;

---------+--------+
 column1 | result |
---------+--------+
 1       | one    |
 2       | two    |
 3       | other  |
---------+--------+



10. Join
https://docs.snowflake.net/manuals/sql-reference/constructs/join.html

Ex:
select * from t1 order by c1;

----+
 C1 |
----+
 2  |
 3  |
 4  |
----+

select * from t2 order by c2;

----+
 C2 |
----+
 1  |
 2  |
 2  |
 3  |
----+


Inner join:
select c1, c2 from t1 inner join t2 on c1 = c2 order by 1,2;

----+----+
 c1 | c2 |
----+----+
 2  | 2  |
 2  | 2  |
 3  | 3  |
----+----+
Left outer join:
select c1, c2 from t1 left outer join t2 on c1 = c2 order by 1,2;

----+--------+
 c1 |   c2   |
----+--------+
 2  | 2      |
 2  | 2      |
 3  | 3      |
 4  | [NULL] |
----+--------+


Right outer join:
select c1, c2 from t1 right outer join t2 on c1 = c2 order by 1,2;

--------+----+
   c1   | c2 |
--------+----+
 2      | 2  |
 2      | 2  |
 3      | 3  |
 [NULL] | 1  |
--------+----+
Here is an example of a cross join, which will produce the cartesian product:
create or replace table d1 (
  id number,
  name string
  );
insert into d1 (id, name) values
  (1,'a'),
  (2,'b'),
  (4,'c');

create or replace table d2 (
  id number,
  value string
  );
insert into d2 (id, value) values
  (1,'xx'),
  (2,'yy'),
  (5,'zz');

select d1.*, d2.*
from d1 cross join d2;

+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  1 | a    |  2 | yy    |
|  1 | a    |  5 | zz    |
|  2 | b    |  1 | xx    |
|  2 | b    |  2 | yy    |
|  2 | b    |  5 | zz    |
|  4 | c    |  1 | xx    |
|  4 | c    |  2 | yy    |
|  4 | c    |  5 | zz    |
+----+------+----+-------+
A cross join can be filtered by a WHERE clause, as shown in the example below:
select d1.*, d2.*
from d1 cross join d2
where d1.id = d2.id;

+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  2 | b    |  2 | yy    |
+----+------+----+-------+


This is an example of a natural join:
select d1.*, d2.*
from d1 natural inner join d2;
The output is:
+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  2 | b    |  2 | yy    |
+----+------+----+-------+
The natural join is equivalent to a join that explicitly joins on each column that the two tables have in common:
select d1.*, d2.*
from d1 inner join d2
  on d2.id=d1.id;


The output of this explicit join is the same as the output of the equivalent natural join, i.e.:
+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  2 | b    |  2 | yy    |
+----+------+----+-------+






Other Examples:

 select last_name from employee_table where employee_id = 101;

select department_name, last_name, first_name
  from employee_table inner join department_table
    on employee_table.department_id = department_table.department_id
  order by department_name, last_name, first_name;

select 2.0 * pi() * pi() as area_of_circle;
select department_name, last_name, first_name
  from employee_table inner join department_table
    on employee_table.department_id = department_table.department_id
  order by department_name, last_name, first_name;
Full outer join:
create or replace table employees (
employeeid number
, lastname string
, firstname string
, email string
, workphone string
, cellphone string
, homeaddress string
, locationid number
);

insert into employees (employeeid,lastname,firstname,email,workphone,cellphone,homeaddress,locationid)
values
(1, 'Reed', 'Riley', 'RRiley@mycompany.com', '1-650-766-3283', '1-650-247-9094', '5274 Tempus St Sacramento CA 95838', 1)
,(2, 'Harlan', 'Harrison', 'HHarrison@mycompany.com', '1-650-443-4754', '1-650-998-4302', '1562 Sed St Rio Linda CA 95673', 1)
,(3, 'Caldwell', 'Wise', 'CWise@mycompany.com', '1-650-380-9433', '1-650-952-8492', '270-3798 Suspendisse St Elk Grove CA 95624', 4)
,(4, 'Barry', 'Thompson', 'BThompson@mmycompany.com', '1-617-681-5370', '1-617-164-6624', '933 Semper Rd Belmont MA 81900', 2)
,(5, 'Octavia', 'Jackson', 'OJackson@mycompany.com', '1-617-867-8027', '1-617-110-9862', '114 Lerwick Rd Lexington MA 59222', 2);

create or replace table locations (
locationid number
, locationname string
, locationphone string
, locationaddress string
);

insert into locations (locationid, locationname, locationphone, locationaddress)
values
(1, 'San Diego', '1-619-265-4050', '6986 Morbi Ave San Diego CA 92093')
,(2, 'Boston', '1-617-448-3992', '628 Aliquet Rd Boston MA 02108')
,(3, 'New York', '1-201-448-3992', '628 Aliquet Bvd New York NY 10001');

select e.lastname, e.firstname, l.locationname
from employees e
full outer join locations l
on e.locationid=l.locationid
order by e.lastname;

+----------+-----------+--------------+
| LASTNAME | FIRSTNAME | LOCATIONNAME |
|----------+-----------+--------------|
| Barry    | Thompson  | Boston       |
| Caldwell | Wise      | NULL         |
| Harlan   | Harrison  | San Diego    |
| Octavia  | Jackson   | Boston       |
| Reed     | Riley     | San Diego    |
| NULL     | NULL      | New York     |
+----------+-----------+--------------+
Common command used in SQL and Snowflake:
https://docs.snowflake.net/manuals/sql-reference/intro-summary-sql.html





Tricky differences between Snowflake and Querious:

Snowflake sometimes won't display a quantity unless it's added in the groupby list. 
Actual example that runs on Querious but not on Snowflake: 
select li.id "location_info.id", li.name "location_info.name", count(distinct v.id) "venue_info.id", count(r.id) "res..bookres..id"
from reservation_bookreservation r
join venue_info v on v.id=r.venue_id and v.is_active=1
inner join location_info li on li.id=v.location_id
group by li.id
order by li.id
;
To make it work, change group by li.id to group by li.id, li.name.




