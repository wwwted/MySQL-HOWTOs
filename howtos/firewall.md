**[Back to Agenda](./../README.md)**

# MySQL Enterprise Firewall

In this howto we are going to look at how to get started with MySQL Enterprise Firewall and also show a small demo on how it works. This feature is part of the MySQL Enterprise Edition, if you do not have access to MySQL Enteprise Binaries you can download them for evaluation purpose following this [guide](/howtos/edelivery-ee.md). Also remember to setup your demo environment using the guide [here](/howtos/install.md).

In the MySQL Enterprise Editition we also have commercial edition of MySQL Workbench where you can install/remove and configure the firewall via a graphical interface, more information [here](https://dev.mysql.com/doc/workbench/en/wb-mysql-firewall.html).

Further reading:
* https://www.mysql.com/products/enterprise/firewall.html
* https://dev.mysql.com/doc/refman/5.7/en/firewall-reference.html

### Installing Enterprise Firewall
MySQL Enterprise Firewall is delivered as a plugin and can be loaded as any [plugin](https://dev.mysql.com/doc/refman/5.7/en/server-plugin-loading.html) to MySQL. The easy way to install the firewall plugin is to use the linux_install_firewall.sql script in share folder. (Or use the respective Windows installation file in the same directory.)

```
mysql -u root -proot mysql <  mysqlsrc/share/linux_install_firewall.sql
```
Look at configuration of firewall plugin:
```
mysql> SHOW GLOBAL VARIABLES LIKE '%firewall%';
```
Look at status of firewall plugin:
```
mysql> SHOW GLOBAL STATUS LIKE '%firewall%';
```
After running the installation you will see 2 new table in the mysql database, firewall_users and firewall_whitelist.
All firewall rules (approved statements) are stored in table firewall_whitelist.
```
mysql> show create table mysql.firewall_whitelist\G
```
Information on current mode (enabled, disabled, recording etc) for different users are easiers accesed via table MYSQL_FIREWALL_USERS in information_schema.
```
SELECT MODE FROM INFORMATION_SCHEMA.MYSQL_FIREWALL_USERS WHERE USERHOST = 'ted@localhost';
```
List of current statemets in whitelist are available via table MYSQL_FIREWALL_WHITELIST in information_schema.
```
SELECT RULE FROM INFORMATION_SCHEMA.MYSQL_FIREWALL_WHITELIST WHERE USERHOST = 'ted@localhost';
```

### Demo
In this demo we will create a user called "ted" and later set firewall in recording mode to record some statements in the whitelist.

Update 2023-01: Due to changes in MySQL 8.0.27 a user who has privileges like "GRANT ALL on \*.\*" will not be blocked, more details [here](https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html#priv_firewall-exempt)

You will use the MySQL root/admin user for installing and managing the firewall, you will need at least the FIREWALL_ADMIN privilege, more details [here](https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html#priv_firewall-admin).

First step, if you have not already done this, is to install the plugin:
```
mysql -u root -proot mysql <  mysqlsrc/share/linux_install_firewall.sql
```

Log into mysql and run below commands as user 'root' (or other admin user) to create our demo user:
```
CREATE USER 'ted'@'localhost' IDENTIFIED BY 'ted';
GRANT ALL ON ted.* TO 'ted'@'localhost';
```

Grants for user "ted@localhost" should look like (run as admin user):
```
SHOW GRANTS for ted@localhost;
+-------------------------------------------------------+
| Grants for ted2@localhost                             |
+-------------------------------------------------------+
| GRANT USAGE ON *.* TO `ted`@`localhost`              |
| GRANT ALL PRIVILEGES ON `ted`.* TO `ted`@`localhost` |
+-------------------------------------------------------+
``` 
(If you have created your own user and have "system level" privileges, make sure thoose do not include FIREWALL_EXEMPT)

Enable recording for user 'ted' (run as admin user):
```
CALL mysql.sp_set_firewall_mode('ted@localhost', 'RECORDING');
```
Look at status in information_schema tables (run as admin user):
```
SELECT MODE FROM INFORMATION_SCHEMA.MYSQL_FIREWALL_USERS WHERE USERHOST = 'ted@localhost';
SELECT RULE FROM INFORMATION_SCHEMA.MYSQL_FIREWALL_WHITELIST WHERE USERHOST = 'ted@localhost';
```
You should see that firewall is in recording mode and that whitelist is empty.

Lets run some statements as user 'ted', before we can begin copy command below and create a file named fw1.sql
```
DROP DATABASE IF EXISTS ted;
CREATE DATABASE ted;
use ted;
CREATE TABLE t1 (i int PRIMARY KEY, c varchar(12));
INSERT INTO t1 VALUES (1,'ted1');
INSERT INTO t1 VALUES (2,'ted2');
INSERT INTO t1 VALUES (3,'ted3');
INSERT INTO t1 VALUES (4,'ted4');
INSERT INTO t1 VALUES (5,'ted5');
SELECT c FROM t1 where i=3;
SELECT c FROM t1 where c like "ted%";
```
And run command:
```
mysql -uted -pted < fw1.sql
```
Now look whitelist for user ted (run as admin user)
```
SELECT RULE FROM INFORMATION_SCHEMA.MYSQL_FIREWALL_WHITELIST WHERE USERHOST = 'ted@localhost';
```
Lets put firewall in protecting mode for user 'ted' (run as admin user)
```
CALL mysql.sp_set_firewall_mode('ted@localhost', 'PROTECTING');
SELECT MODE FROM INFORMATION_SCHEMA.MYSQL_FIREWALL_USERS WHERE USERHOST = 'ted@localhost';
```
Create a new file called fw2.sql using commands below:
```
use ted;
INSERT INTO t1 VALUES (6,'ted7');
INSERT INTO t1 VALUES (7,'ted7');
SELECT c FROM t1 where i=3;
SELECT c FROM t1 where c like "ted%";
SELECT * FROM t1 where i=3;
SELECT i FROM t1 where i=3;
```
Now lets try to run these statements (user ted):
```
mysql -uted -pted --force -v -v -v  < fw2.sql
```
Last two statement where blocked as expected, these are new and have not been recored.

If you want, set firewall in RECORDING mode again and re-read file fw2.sql (remove the two insert statemtents to avaoid errors) and you will see that whitelist is update and then you can successfully execute the last two SELECT statments.

If you want to clear firewall whitelist use command (run as admin user):
```
CALL mysql.sp_set_firewall_mode('ted@localhost', 'RESET');
```
**[Back to Top](./firewall.md)**

**[Back to Agenda](./../README.md)**
