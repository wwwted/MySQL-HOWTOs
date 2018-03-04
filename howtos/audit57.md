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
mysql -uroot -proot mysql <  mysql57/share/audit_log_filter_linux_install.sql
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
All basic filtering options are described in demo for MySQL 5.6 [here](audit.md). In this demo we will focus on using our new enhanced JSON filters.

### Demo
