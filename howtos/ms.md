**[Back to Agenda](./../README.md)**

# Setting up multi-source replication (5.7 and later) with GTID based replication

Purpose of this guide is to show how to setup a new multi-source slave from two (or more) existing masters.
We will also set up a replication filter to only apply data from some of the databases.

### Scenario:
We have already 2 master up and running and we want filter one database from each.
Lets call them master1 and master2 with databases master1 and master2 to make it easy.

##### Configuration of masters
First step will be to make sure that both the masters have GTID replication enabled.
Configuration (my.cnf) needed on master servers will be:
```
gtid-mode=ON
log-slave-updates=ON
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
log-bin=mysql-bin
binlog-format=ROW
```

Next step is to create a user for replication on both master servers, since MySQL 8 uses a new authentication plugin the creation of replication user will differ from MySQL 5.7.
Create a replication user for MySQL 5.7 using:
```
mysql> CREATE USER 'repl_user'@'slave-host' IDENTIFIED BY 'repl_pass';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'slave-host';
```
For MySQL 8.0 use below commands:
```
mysql> CREATE USER 'repl_user'@'slave-host' IDENTIFIED WITH sha256_password BY 'repl_pass';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'slave-host';
```

##### Provisioning of data to new multi-source slave

1) Now it's time to provision some data to our slave, step one is to run mysqldump on master databases:
   (we only dump database master1 from master1 and master2 from master2)
```
mysqldump -u<user> -p<pass> --single-transaction --triggers --routines --set-gtid-purged=ON --databases master1 > dumpM1.sql
mysqldump -u<user> -p<pass> --single-transaction --triggers --routines --set-gtid-purged=ON --databases master2 > dumpM2.sql
```
2) Get GTID_PURGED information from dump files and remember this (you need this later):
   (the perl command was added to remove new c-style commment in MySQL 8 dumpfile)
```
cat dumpM1.sql | grep GTID_PURGED | perl -p0 -e 's#/\*.*?\*/##sg' | cut -f2 -d'=' | cut -f2 -d$'\''
cat dumpM2.sql | grep GTID_PURGED | perl -p0 -e 's#/\*.*?\*/##sg' | cut -f2 -d'=' | cut -f2 -d$'\''
```
(GTID should look something like: aeaeb1f9-cfab-11e9-bf5d-ec21e522bf21:1-5)

3) Now we need to remove GTID_PURGED information from dump files before import:
```
sed '/GTID_PURGED/d' dumpM1.sql > dumpM1_nopurge.sql
sed '/GTID_PURGED/d' dumpM2.sql > dumpM2_nopurge.sql
```
4) Import data into new multi-source slave:
```
mysql -u<user> -p<pass> < dumpM1_nopurge.sql
mysql -u<user> -p<pass> < dumpM2_nopurge.sql
```
5) Clear GTID state on slave server and set GTID_PURGED to values collected earlier at step 2):
```
mysql> RESET MASTER;
mysql> SET GLOBAL GTID_PURGED="<Master1 GTID_PURGED>,<Master2 GTID_PURGED>";
```

##### Configure and start multi-source replication

Now it's time to configure the replication channels and set the filter rule (filters on slave will be for all channels):
```
mysql> CHANGE MASTER TO MASTER_HOST=<master1-host>, MASTER_USER="repl", MASTER_PASSWORD="repl", MASTER_AUTO_POSITION=1 FOR CHANNEL "master1";
mysql> CHANGE MASTER TO MASTER_HOST=<master2-host>, MASTER_USER="repl", MASTER_PASSWORD="repl", MASTER_AUTO_POSITION=1 FOR CHANNEL "master2";
mysql> CHANGE REPLICATION FILTER REPLICATE_WILD_DO_TABLE=('master1.%','master2.%');
```
After this we start both channels: 
``` 
mysql> START SLAVE FOR CHANNEL "master1";
mysql> START SLAVE FOR CHANNEL "master2";
```
You can now looks at status with:
```
mysql> SHOW SLAVE STATUS FOR CHANNEL "master1"\G
mysql> SHOW SLAVE STATUS FOR CHANNEL "master2"\G
```

##### Setup your own multi-source sandbox environment

If you want to play around with Multi-Source replication and whant to jumpstart a sandbox environment then you might want to look at my scripts in this [folder](/multi-source).
The only requirement is to have MySQL (5.7) installed and add the path to binaries to start of scripts, after this you simply run:
```
./01-CreateServers.sh
./02-setup-slave.sh
mysql -uroot -proot -h127.0.0.1 -P63308 <  03-StartReplication.sql
```

Further reading:
* https://dev.mysql.com/doc/refman/5.7/en/replication-multi-source.html


**[Back to Agenda](./../README.md)**
