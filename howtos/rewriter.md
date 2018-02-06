**[Back to Agenda](./../README.md)**

# MySQL Query Rewrite Plugin

In this howto we are going to look at how to get started with the MySQL Query Rewrite Plugin and also show a small demo on how it works.

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
mysql -uroot -proot mysql <  mysql57/share/install_rewriter.sql
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

