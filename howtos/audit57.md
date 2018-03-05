**[Back to Agenda](./../README.md)**

# MySQL Enterprise Audit (5.7)

In this howto we are going to look at how to get started with MySQL Enterprise Audit and also show a small demo on how it works. This feature is part of the MySQL Enterprise Edition, if you do not have access to MySQL Enteprise Binaries you can download them for evaluation purpose following this [guide](/howtos/edelivery-ee.md). Also remember to setup your demo environment using the guide [here](/howtos/install.md).

In the MySQL Enterprise Editition we also have commercial edition of MySQL workbench where you can install/remove and search in audit logs via a graphical interface, more information [here](https://dev.mysql.com/doc/workbench/en/wb-audit-inspector.html).

Below guide is done using audit plugin for MySQL 5.7.21, several enhancements where added in version 5.7.21 of MySQL and I highly recomend to use this version or later ones to fully benefit from all new featues like compression, encryption, new JSON format and SQL interface to read audit data.

Further reading:
* https://www.mysql.com/products/enterprise/audit.html
* https://dev.mysql.com/doc/refman/5.7/en/audit-log.html


### Installing Enterprise Audit
MySQL Enterprise Audit is delivered as a plugin and can be loaded as any [plugin](https://dev.mysql.com/doc/refman/5.7/en/server-plugin-loading.html) to MySQL.  
The prefered way to install the audit plugin as of MySQL 5.7 is to use the audit_log_filter_linux_install.sql script in share folder, this will not only load the plugin but also create additional logic for handeling our advanced filtering.

```
bash$ mysql -uroot -proot mysql <  mysql57/share/audit_log_filter_linux_install.sql
```

Verify that plugin is active:
```
mysql> SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE 'audit%';
+-------------+---------------+
| PLUGIN_NAME | PLUGIN_STATUS |
+-------------+---------------+
| audit_log   | ACTIVE        |
+-------------+---------------+
```
If you have problems loading the plugin verify that you have the plugin is located in folder `mysql57/lib/plugin/audit_log.so`. If you have a different path to your plugin's verify that your configuration parameter *plugin_dir* is correclty set, see bellow for our test environment.
```
mysql> show variables like 'plugin_dir';
+---------------+-----------------------------------------------------+
| Variable_name | Value                                               |
+---------------+-----------------------------------------------------+
| plugin_dir    | /home/ted/gitrepos/MySQL-HOWTOs/mysql57/lib/plugin/ |
+---------------+-----------------------------------------------------+
```

After audit log is installed, you can use the --audit-log option to prevent the plugin from being removed at runtime:
```
[mysqld]
audit-log=FORCE_PLUS_PERMANENT
```

### Configuration
Below are important configuration option for Audit plugin, complete list of all option can be found in the [MySQL manual](https://dev.mysql.com/doc/refman/5.6/en/audit-log-reference.html).   
Default option is with in parentheses.

*audit_log_file (audit.log)*
```
Name of audit log
```

*audit_log_flush (OFF)*
```
For manual rotation of audit.log file:
mv audit.log audit.log.1
SET GLOBAL audit_log_flush = ON;
```

*audit_log_rotate_on_size (0)*
```
Automatic log rotation on size
```

*audit_log_format (NEW)*
```
OLD     Old XML format
NEW     New enhanaced XML format introduced in MySQL 5.6
JSON    JSON format, mantatory for using SELECT stmts to read audut log
```

*audit_log_strategy (ASYNCHRONOUS)*  
```
ASYNCHRONOUS     Log asynchronously, wait for space in output buffer
PERFORMANCE      Log asynchronously, drop request if insufficient space in output buffer
SEMISYNCHRONOUS  Log synchronously, permit caching by operating system
SYNCHRONOUS      Log synchronously, call sync() after each request
```
All basic filtering options are described in howto for MySQL 5.6 [here](audit.md). In this howto we will focus on using our new enhanced JSON filters.

### Filtering functions

*audit_log_filter_flush()*  
If we modify the audit tables directly we need to call filter flush() for this to take effekt.

*audit_log_filter_remove_filter(\<filter\>)*  
Remove a filter.
 
*audit_log_filter_remove_user(\<user\>)*  
Remove a user account from all filters.

*audit_log_filter_set_filter(\<filter-name\>,\<JSON filter\>)*  
Create a audit filter.

*audit_log_filter_set_user(\<user-name\>,\<filter-name\>)*  
Start filtering a user account.

*audit_log_read()*  
Read audit log records. More samples in demo below.

*audit_log_read_bookmark()*  
Set bookmark for read() function above, the function will return current position in audit log file.

### Demo
The new audit plugin uses JSON format describing filtering rules. These filters are then handled using a set of stored procedures. The filters can then be assigned to users.

Two interal in mysql schema, tables audit_log_filter and audit_log_user store all data needed by the audit plugin.

Before we create some filter lets look at configuration parameters
```
mysql> SELECT *  FROM performance_schema.global_variables WHERE VARIABLE_NAME LIKE 'audit%';
+-----------------------------+----------------+
| VARIABLE_NAME               | VARIABLE_VALUE |
+-----------------------------+----------------+
| audit_log_buffer_size       | 1048576        |
| audit_log_compression       | NONE           |
| audit_log_connection_policy | ALL            |
| audit_log_current_session   | OFF            |
| audit_log_encryption        | NONE           |
| audit_log_exclude_accounts  | app@localhost  |
| audit_log_file              | audit.log      |
| audit_log_filter_id         | 0              |
| audit_log_flush             | OFF            |
| audit_log_format            | NEW            |
| audit_log_include_accounts  |                |
| audit_log_policy            | ALL            |
| audit_log_read_buffer_size  | 1048576        |
| audit_log_rotate_on_size    | 0              |
| audit_log_statement_policy  | ALL            |
| audit_log_strategy          | ASYNCHRONOUS   |
+-----------------------------+----------------+
```
Lets change audit log format to JSON.  
The `audit_log_format`variable can not be changed dynamically, we need to add `audit_log_format="JSON"` to our my.cnf file and restart the MySQL daemon. It's also good practice to change name of audit file when changing format, let's call the new one audit.json.
Add two lines below to your configuration file (under \[mysqld\] section):
```
audit_log_format="JSON"
audit_log_file="audit.json"
```
Restart MySQL:
```
bash$ ./scripts/restart.sh 
```
Lets look at new configuration after restart
```
mysql> SELECT *  FROM performance_schema.global_variables WHERE VARIABLE_NAME IN ('audit_log_format','audit_log_file');
+------------------+----------------+
| VARIABLE_NAME    | VARIABLE_VALUE |
+------------------+----------------+
| audit_log_file   | audit.json     |
| audit_log_format | JSON           |
+------------------+----------------+
```
Now it's time to create some rules, we will start by creating a simple filter that will log everything for everyone
```
mysql> SELECT audit_log_filter_set_filter('log_all', '{ "filter": { "log": true } }');
mysql> SELECT audit_log_filter_set_user('%', 'log_all');
```
Let me break down what we just executed, in first call we created a filter and named this filter 'log_all', the filter itself only specifies the mandatory top tag "filter" and the value of the sub tag "log:true".  

The auditing is now working for all new sessions connecting, re-connect and run some statements and look inside the audit file `mysqldata/audit.json`.

If we want to disable auditing we can do this by setting `"log":false` like:
```
mysql> SELECT audit_log_filter_set_filter('log_all', '{ "filter": { "log": false } }');
```
You should now see that logging stopped.  

All filters are created using JSON format, I will not go into details explaining JSON here but if you are new to JSON there some information available [here](https://dev.mysql.com/doc/refman/5.7/en/json.html).  
Our JSON documents for filters have the syntax: `{ "filter": actions }`  
Where actions will describe how filtering is done, our [manual](https://dev.mysql.com/doc/refman/5.7/en/audit-log-filtering.html) describes how to define different actions and have many samples of how to create different filters.  

There are 3 different main classes (with subclasses) we can use to create filters;
| Event        | Class	Event Subclass |	Description                                                        |
|--------------| -------------------  | -------------------------------------------------------------------| 
| connection   |	connect	             | Connection initiation (successful or unsuccessful)                 |
|              | change_user          |	User re-authentication with different user/password during session |
|              | disconnect	          | Connection termination                                             |
| general	     | status	              | General operation information                                      |
| table_access |	read	                | Table read statements, such as SELECT or INSERT INTO ... SELECT    |
|              | delete	              | Table delete statements, such as DELETE or TRUNCATE TABLE          |
|              | insert	              | Table insert statements, such as INSERT or REPLACE                 |
|              | update	              | Table update statements, such as UPDATE                            |

Let's create some more filters and things will be a bit clearer hopefully, we will now create a filter that only filters out connection events and assign this filter to a user named 'joe'@'localhost'.  
Firts we need to create the acocunt 'joe'@localhost
```

```
