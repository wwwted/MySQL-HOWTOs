**[Back to Agenda](./../README.md)**

# MySQL Multi-Source replication (5.7)

In this howto we are going to look at how to get started with MySQL Enterprise Audit and also show a small demo on how it works. This feature is part of the MySQL Enterprise Edition, if you do not have access to MySQL Enteprise Binaries you can download them for evaluation purpose following this [guide](/howtos/edelivery-ee.md). Also remember to setup your demo environment using the guide [here](/howtos/install.md).

Further reading:
* https://www.mysql.com/products/enterprise/audit.html
* https://dev.mysql.com/doc/refman/5.6/en/audit-log.html

If you have problems loading the plugin verify that yoy have the plugin in available in folder `mysqlsrc/lib/plugin/audit_log.so`. If you have a different path to your plugins verify that your configuration parameter *plugin_dir* is correclty set, see bellow for our test environment.
```
Kalle
```

**[Back to Agenda](./../README.md)**
