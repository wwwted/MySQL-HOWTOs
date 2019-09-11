#!/bin/bash
#
#

demohome=/home/ted/demos/MySQL-MS # Folder to install MySQL Servers
mysqlhome=/home/ted/src/5.7.19    # Path to MySQL 5.7 binaries
#mysqlhome=/home/ted/src/8.0.17    # Path to MySQL 5.7 binaries

# Do not edit below

mysql=${mysqlhome}/bin/mysql
mysqldump=${mysqlhome}/bin/mysqldump
export MYSQL_PWD="root"

[ ! -d $demohome ] && echo "Can not find $demohome, exiting" && exit 1
[ ! -x $mysql ] && echo "Can not find $mysqld, exiting" && exit 1
[ ! -x $mysqldump ] && echo "Can not find $mysqladmin, exiting" && exit 1

echo -n "Provision data to slave"

$mysqldump -uroot -proot -h127.0.0.1 -P63306 --single-transaction --triggers --routines --set-gtid-purged=ON --databases master1 > $demohome/dumpM1.sql
$mysqldump -uroot -proot -h127.0.0.1 -P63307 --single-transaction --triggers --routines --set-gtid-purged=ON --databases master2 > $demohome/dumpM2.sql

# Save GTID Purged values
master1_gtid_purged=`cat dumpM1.sql | grep GTID_PURGED | perl -p0 -e 's#/\*.*?\*/##sg' | cut -f2 -d'=' | cut -f2 -d$'\''`
master2_gtid_purged=`cat dumpM2.sql | grep GTID_PURGED | perl -p0 -e 's#/\*.*?\*/##sg' | cut -f2 -d'=' | cut -f2 -d$'\''`
echo "master1_gtid_purged"
echo "master2_gtid_purged"

# Remove GTID Purged from dumpfiles before import
sed '/GTID_PURGED/d' dumpM1.sql > dumpM1_nopurge.sql
sed '/GTID_PURGED/d' dumpM2.sql > dumpM2_nopurge.sql

# Import dumps into new slave
$mysql -uroot -proot -h127.0.0.1 -P63308 < dumpM1_nopurge.sql
$mysql -uroot -proot -h127.0.0.1 -P63308 < dumpM2_nopurge.sql

# RESET MASTER AND Set GTID_PURGE from masters
$mysql -uroot -proot -h127.0.0.1 -P63308 << EOL
  RESET MASTER;
  SET GLOBAL GTID_PURGED="$master1_gtid_purged,$master2_gtid_purged";
EOL

echo 
echo "Values of gtid_executed and gtid_purged after import"
echo "--------------------------------------------------------------" 
$mysql -uroot -proot -h127.0.0.1 -P63308 -se "SHOW GLOBAL VARIABLES LIKE 'gtid_purged'; SHOW GLOBAL VARIABLES LIKE 'gtid_executed';"
