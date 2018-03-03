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
The prefered way to install the audit plugin as of MySQL 5.7 is to use the audit_log_filter_linux_install.sql script in share folder,
this will not only load the plugin but also create additional logic for handeling our advanced filtering.

```
mysql -uroot -proot mysql <  mysql57/share/audit_log_filter_linux_install.sql
```
### Demo
