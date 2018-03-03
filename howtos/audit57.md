**[Back to Agenda](./../README.md)**

# MySQL Enterprise Audit

In this howto we are going to look at how to get started with MySQL Enterprise Audit and also show a small demo on how it works. This feature is part of the MySQL Enterprise Edition, if you do not have access to MySQL Enteprise Binaries you can dowloaded them for evaluation purpose following this [guide](/howtos/edelivery-ee.md). Also remember to setup your demo environment using the guide [here](/howtos/install.md).

Further reading:
* https://www.mysql.com/products/enterprise/audit.html
* https://dev.mysql.com/doc/refman/5.7/en/audit-log.html


### Installing Enterprise Audit
MySQL Enterprise Audit is delivered as a plugin and can be loaded as any [plugin](https://dev.mysql.com/doc/refman/5.7/en/server-plugin-loading.html) to MySQL.  
The prefered way to install the audit plugin as of MySQL 5.7 is to use the audit_log_filter_linux_install.sql script in share folder,
this will not only load the plugin but also create additional logic for handeling our advanced filtering.

```
mysql -uroot -proot mysql <  mysql57/share/audit_log_filter_linux_install.sql
```
### Demo
