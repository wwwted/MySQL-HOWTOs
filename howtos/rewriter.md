**[Back to Agenda](./../README.md)**

# MySQL Query Rewrite Plugin

In this howto we are going to look at how to get started with the MySQL Query Rewrite Plugin and also show a small demo on how it works. Remember to setup your demo environment using the guide [here](/howtos/install.md).

Further reading:
* https://dev.mysql.com/doc/refman/5.7/en/rewriter-query-rewrite-plugin.html
* http://mysqlserverteam.com/write-yourself-a-query-rewrite-plugin-part-1/
* http://mysqlserverteam.com/write-yourself-a-query-rewrite-plugin-part-2/
* http://mysqlserverteam.com/the-query-rewrite-plugins/
* http://dasini.net/blog/2016/02/25/30-mins-with-mysql-query-rewriter/

### Installing Query Rewrite Plugin
The MySQL Query Rewrite Plugin is delivered as a plugin and can be loaded as any [plugin](https://dev.mysql.com/doc/refman/5.7/en/server-plugin-loading.html) to MySQL.
The easy way to install the audit plugin and all needed stuff around it (schemas/tables/procedures) is to use the install_rewriter.sql script in share folder.

```
mysql -uroot -proot mysql <  mysqlsrc/share/install_rewriter.sql
```
Look at configuration of rewrite plugin:
```
mysql> SHOW GLOBAL VARIABLES LIKE 'rewriter%';
```
Look at status of rewrite plugin:
```
mysql> SHOW GLOBAL STATUS LIKE 'rewriter%';
```
After running the installation you will see and new schema called query_rewrite and table rewrite_rules.
All rewrite rules are stored here.
```
mysql> show create table query_rewrite.rewrite_rules\G
```
Important columns are:
* id
  - The rule ID. This column is the table primary key. You can use the ID to uniquely identify any rule.
* pattern
  - The template that indicates the pattern for statements that the rule matches. Use ? to represent parameter markers that match data values.
* replacement
  - The template that indicates how to rewrite statements matching the pattern column value. Use ? to represent parameter markers that match data values. In rewritten statements, the plugin replaces ? parameter markers in replacement using data values matched by the corresponding markers in pattern.
* pattern_database
  - The database used to match unqualified table names in statements.
* enabled
  - Whether the rule is enabled
  
 A complete list or coulmns and commands can be found in our manuals [here](https://dev.mysql.com/doc/refman/5.7/en/rewriter-query-rewrite-plugin-reference.html)

### Demo

First, if you have not already done this, lets install the rewrite plugin
```
mysql -uroot -proot mysql <  mysqlsrc/share/install_rewriter.sql
```

Second, lets create some test data to play around with
```
create database labb;
use labb;

create table testing (
   id int primary key auto_increment,
   name varchar(32),
   address varchar(32),
   age int,
   index (name)
);

DELIMITER $$
CREATE PROCEDURE prepare_data()
BEGIN
  DECLARE i INT DEFAULT 100;
  WHILE i < 10000 DO
    INSERT INTO labb.testing (id,name,address,age) VALUES (i,CONCAT("ted",i),CONCAT("address",i),i);
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

CALL prepare_data();
```
#### "Restrict access to some columns", statements with SELECT * will be replaced by specified list of columns.
```
INSERT INTO query_rewrite.rewrite_rules ( pattern, pattern_database, replacement )
VALUES
(
  # Pattern
  'SELECT * FROM testing WHERE id = ?',
  # Database
  'labb',
  # Replacement
  'SELECT name, address, age FROM testing WHERE id = ?'
);
CALL query_rewrite.flush_rewrite_rules();
  ```
Verify that rule works
```
mysql> select * from testing where id=100;
+--------+------------+------+
| name   | address    | age  |
+--------+------------+------+
| ted100 | address100 |  100 |
+--------+------------+------+
1 row in set, 1 warning (0,00 sec)
```
Works as expected, id column is not returned, but hey what about that warning above
```
mysql> show warnings\G
*************************** 1. row ***************************
  Level: Note
   Code: 1105
Message: Query 'select * from testing where id=100' rewritten to 'SELECT name, address, age FROM testing WHERE id = 100' by a query rewrite plugin
```
Nice, MySQL will return a warning when rewrite plugin is triggerd and show information regarting the rule that was triggerd.

#### Limit size of resultset to max 10 rows
```
INSERT INTO query_rewrite.rewrite_rules ( pattern, pattern_database, replacement )
VALUES
(
  # Pattern
  'SELECT * FROM testing WHERE name like ?',
  # Database
  'labb',
  # Replacement
  'SELECT * FROM testing WHERE name like ? limit 10'
);
CALL query_rewrite.flush_rewrite_rules();
  ```
Verify that rule works
```
mysql> select * from testing where name like 'ted%';
+-----+--------+------------+------+
| id  | name   | address    | age  |
+-----+--------+------------+------+
| 100 | ted100 | address100 |  100 |
| 101 | ted101 | address101 |  101 |
| 102 | ted102 | address102 |  102 |
| 103 | ted103 | address103 |  103 |
| 104 | ted104 | address104 |  104 |
| 105 | ted105 | address105 |  105 |
| 106 | ted106 | address106 |  106 |
| 107 | ted107 | address107 |  107 |
| 108 | ted108 | address108 |  108 |
| 109 | ted109 | address109 |  109 |
+-----+--------+------------+------+
10 rows in set, 1 warning (0,00 sec)
```
Works as expected, only 10 rows are returned instead of full table scan.

#### Limit execution time of queries to max 10ms (Optimizer Hints)
```
INSERT INTO query_rewrite.rewrite_rules ( pattern, pattern_database, replacement )
VALUES
(
  # Pattern
  'SELECT * FROM testing WHERE name like ?',
  # Database
  'labb',
  # Replacement
  'SELECT /*+ MAX_EXECUTION_TIME(10)*/ * FROM testing WHERE name like ?'
);
CALL query_rewrite.flush_rewrite_rules();
  ```
Verify that rule works
```
mysql> select * from testing where name like 'ted%';
ERROR 3024 (HY000): Query execution was interrupted, maximum statement execution time exceeded
```
Works as expected, query was interupted after 10ms.

**[Back to Top](./rewriter.md)**

**[Back to Agenda](./../README.md)**
