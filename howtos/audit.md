**[Back to Agenda](./../README.md)**

# MySQL Enterprise Audit (5.6)

In this howto we are going to look at how to get started with MySQL Enterprise Audit and also show a small demo on how it works. This feature is part of the MySQL Enterprise Edition, if you do not have access to MySQL Enteprise Binaries you can download them for evaluation purpose following this [guide](/howtos/edelivery-ee.md). Also remember to setup your demo environment using the guide [here](/howtos/install.md).

Further reading:
* https://www.mysql.com/products/enterprise/audit.html
* https://dev.mysql.com/doc/refman/5.6/en/audit-log.html


### Installing Enterprise Audit
MySQL Enterprise Audit is delivered as a plugin and can be loaded as any [plugin](https://dev.mysql.com/doc/refman/5.6/en/server-plugin-loading.html) to MySQL. 

Load the plugin:
```
mysql> INSTALL PLUGIN audit_log SONAME 'audit_log.so';
```
Verify that plugin is loaded:
```
mysql> SHOW PLUGINS;
+----------------------------+----------+--------------------+--------------+-------------+
| Name                       | Status   | Type               | Library      | License     |
+----------------------------+----------+--------------------+--------------+-------------+
| binlog                     | ACTIVE   | STORAGE ENGINE     | NULL         | PROPRIETARY |
| mysql_native_password      | ACTIVE   | AUTHENTICATION     | NULL         | PROPRIETARY |
....
| ngram                      | ACTIVE   | FTPARSER           | NULL         | PROPRIETARY |
| audit_log                  | ACTIVE   | AUDIT              | audit_log.so | PROPRIETARY |
+----------------------------+----------+--------------------+--------------+-------------+
```
If you have problems loading the plugin verify that yoy have the plugin in available in folder `mysqlsrc/lib/plugin/audit_log.so`. If you have a different path to your plugins verify that your configuration parameter *plugin_dir* is correclty set, see bellow for our test environment.
```
mysql> show variables like 'plugin_dir';
+---------------+-----------------------------------------------------+
| Variable_name | Value                                               |
+---------------+-----------------------------------------------------+
| plugin_dir    | /home/ted/gitrepos/MySQL-HOWTOs/mysqlsrc/lib/plugin/ |
+---------------+-----------------------------------------------------+
```

The command for loading the Audit plugin can also be put in the configuraton file like:
```
[mysqld]
plugin-load=audit_log.so
audit-log=FORCE_PLUS_PERMANENT
```
The second option "FORCE_PLUS_PERMANENT" will make it impossible to un-install the plugin without restarting the MySQL instance.

### Configuration
Below are important configuration option for Audit plugin, complete list of all option can be found in the [MySQL manual](https://dev.mysql.com/doc/refman/5.6/en/audit-log-reference.html).   
Default option is with in parentheses.

*audit_log_connection_policy (ALL)*  
```
ALL      Log all connection events
ERRORS   Log only failed connection events
NONE     Do not log connection events
```

*audit_log_exclude_accounts*
```
List of accounts to exclude from audit log
SET GLOBAL audit_log_exclude_accounts = 'user1@localhost,user2@localhost';
```

*audit_log_include_accounts*
```
List of accounts to include in audit log
SET GLOBAL audit_log_include_accounts = 'user1@localhost,user2@localhost';
```

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

*audit_log_policy (ALL)*
```
ALL      Log all events
LOGINS   Log only login events
QUERIES  Log only query events
NONE     Log nothing (disable the audit stream)
```

*audit_log_statement_policy (ALL)*
```
ALL     Log all statement events
ERRORS  Log only failed statement events
NONE    Do not log statement events
```

*audit_log_strategy (ASYNCHRONOUS)*  
```
ASYNCHRONOUS     Log asynchronously, wait for space in output buffer
PERFORMANCE      Log asynchronously, drop request if insufficient space in output buffer
SEMISYNCHRONOUS  Log synchronously, permit caching by operating system
SYNCHRONOUS      Log synchronously, call sync() after each request
```


### Demo

Let's look at configuration of the Audit plugin:
```
mysql> show global variables like '%audit%';
+-----------------------------+--------------+
| Variable_name               | Value        |
+-----------------------------+--------------+
| audit_log_buffer_size       | 1048576      |
| audit_log_compression       | NONE         |
| audit_log_connection_policy | ALL          |
| audit_log_current_session   | OFF          |
| audit_log_encryption        | NONE         |
| audit_log_exclude_accounts  |              |
| audit_log_file              | audit.log    |
| audit_log_filter_id         | 0            |
| audit_log_flush             | OFF          |
| audit_log_format            | NEW          |
| audit_log_include_accounts  |              |
| audit_log_policy            | ALL          |
| audit_log_read_buffer_size  | 1048576      |
| audit_log_rotate_on_size    | 0            |
| audit_log_statement_policy  | ALL          |
| audit_log_strategy          | ASYNCHRONOUS |
+-----------------------------+--------------+
```

Let's look at status variables for the Audit plugin:
```
mysql>  show global status like '%audit%';
+-------------------------------+-------+
| Variable_name                 | Value |
+-------------------------------+-------+
| audit_log_current_size        | 3987  |
| audit_log_event_max_drop_size | 0     |
| audit_log_events              | 9     |
| audit_log_events_buffered     | 0     |
| audit_log_events_filtered     | 0     |
| audit_log_events_lost         | 0     |
| audit_log_events_written      | 9     |
| audit_log_total_size          | 3987  |
| audit_log_write_waits         | 0     |
+-------------------------------+-------+
```

We can look at content in the audit log also
```
less mysqldata/audit.log
```

Let's test some user filters, first we need to create two users and then use exclude_accounts to remove Audit filtering for user app.
```
mysql> CREATE USER 'app'@'localhost' IDENTIFIED BY 'app';
mysql> CREATE USER 'joe'@'localhost' IDENTIFIED BY 'joe';
mysql> GRANT SELECT ON *.* TO 'app'@'localhost';
mysql> GRANT SELECT ON *.* TO 'joe'@'localhost';
mysql> SET GLOBAL audit_log_exclude_accounts = 'app@localhost';
```
Look at configuration:
```
mysql> show global variables like 'audit_log_exclude_accounts';
+----------------------------+---------------+
| Variable_name              | Value         |
+----------------------------+---------------+
| audit_log_exclude_accounts | app@localhost |
+----------------------------+---------------+
```
Let's use one terminal to trace activities in audit log like:
```
bash$ tail -f mysqldata/audit.log
```
And in another terminal try to login using app account:
```
mysql -uapp -papp -S/tmp/mysql.sock
```
Lets run some statement:
```
mysql> show databases;
```
You should not see any activity in the audit log from connect nor show databases statement. 
Now lets try to connect with user joe.
```
mysql -ujoe -pjoe -S/tmp/mysql.sock
```
and run show databases:
```
mysql> show databases;
```
Not we are seeing some data in the Audit log:
```
<AUDIT_RECORD>
  <TIMESTAMP>2018-03-03T08:36:48 UTC</TIMESTAMP>
  <RECORD_ID>61_2018-03-03T06:40:14</RECORD_ID>
  <NAME>Connect</NAME>
  <CONNECTION_ID>8</CONNECTION_ID>
  <STATUS>0</STATUS>
  <STATUS_CODE>0</STATUS_CODE>
  <USER>joe</USER>
  <OS_LOGIN/>
  <HOST>localhost</HOST>
  <IP/>
  <COMMAND_CLASS>connect</COMMAND_CLASS>
  <CONNECTION_TYPE>Socket</CONNECTION_TYPE>
  <PRIV_USER>joe</PRIV_USER>
  <PROXY_USER/>
  <DB/>
 </AUDIT_RECORD>
 <AUDIT_RECORD>
  <TIMESTAMP>2018-03-03T08:36:48 UTC</TIMESTAMP>
  <RECORD_ID>62_2018-03-03T06:40:14</RECORD_ID>
  <NAME>Query</NAME>
  <CONNECTION_ID>8</CONNECTION_ID>
  <STATUS>0</STATUS>
  <STATUS_CODE>0</STATUS_CODE>
  <USER>joe[joe] @ localhost []</USER>
  <OS_LOGIN/>
  <HOST>localhost</HOST>
  <IP/>
  <COMMAND_CLASS>select</COMMAND_CLASS>
  <SQLTEXT>select @@version_comment limit 1</SQLTEXT>
 </AUDIT_RECORD>
 <AUDIT_RECORD>
  <TIMESTAMP>2018-03-03T08:36:52 UTC</TIMESTAMP>
  <RECORD_ID>63_2018-03-03T06:40:14</RECORD_ID>
  <NAME>Query</NAME>
  <CONNECTION_ID>8</CONNECTION_ID>
  <STATUS>0</STATUS>
  <STATUS_CODE>0</STATUS_CODE>
  <USER>joe[joe] @ localhost []</USER>
  <OS_LOGIN/>
  <HOST>localhost</HOST>
  <IP/>
  <COMMAND_CLASS>show_databases</COMMAND_CLASS>
  <SQLTEXT>show databases</SQLTEXT>
 </AUDIT_RECORD>
```
We see the connect entry and also the show databsases statement recorded in the audit log.

In MySQL 5.6 we can filter on basic things like; users, type of event (connect, query or all) and also filter if event was successfull or failed. In later versions of MySQL we have much more advanced filter options, this is explained in more detais in audit filtering for [MySQL 5.7](/howtos/audit57.md) in the agenda.

In the MySQL Enterprise Editition we also have commercial edition of MySQL workbench where you can install/remove and search in audit logs via a graphical interface, more information [here](https://dev.mysql.com/doc/workbench/en/wb-audit-inspector.html).

**[Back to Agenda](./../README.md)**
