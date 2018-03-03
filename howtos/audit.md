**[Back to Agenda](./../README.md)**

# MySQL Enterprise Audit

In this howto we are going to look at how to get started with MySQL Enterprise Audit and also show a small demo on how it works. This feature is part of the MySQL Enterprise Edition, if you do not have access to MySQL Enteprise Binaries you can dowloaded them for evaluation purpose following this [guide](/howtos/edelivery-ee.md). Also remember to setup your demo environment using the guide [here](/howtos/install.md).

Further reading:
* https://www.mysql.com/products/enterprise/audit.html
* https://dev.mysql.com/doc/refman/5.6/en/audit-log.html


### Installing Enterprise Audit
MySQL Enterprise Audit is delivered as a plugin and can be loaded as any [plugin](https://dev.mysql.com/doc/refman/5.6/en/server-plugin-loading.html) to MySQL. 

Load the plugin:
```
mysql> INSTALL PLUGIN audit_log SONAME 'audit_log.so';
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



