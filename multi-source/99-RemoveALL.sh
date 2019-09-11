#!/bin/sh
#

demohome=/home/ted/demos/MySQL-MS # Folder to install MySQL Servers
mysqlhome=/home/ted/src/5.7.19    # Path to MySQL 5.7 binaries
#mysqlhome=/home/ted/src/8.0.17    # Path to MySQL 5.7 binaries

# Do not edit below

mysqld=${mysqlhome}/bin/mysqld
mysqladmin=${mysqlhome}/bin/mysqladmin
export MYSQL_PWD="root"

[ ! -d $demohome ] && echo "Can not find $demohome, exiting" && exit 1
[ ! -x $mysqld ] && echo "Can not find $mysqld, exiting" && exit 1
[ ! -x $mysqladmin ] && echo "Can not find $mysqladmin, exiting" && exit 1

echo -n "Stopping and removing mysql instances ..."

$mysqladmin -uroot -h127.0.0.1 -P63306 shutdown
$mysqladmin -uroot -h127.0.0.1 -P63307 shutdown
$mysqladmin -uroot -h127.0.0.1 -P63308 shutdown
sleep 5

rm -rf ${demohome}/mysql1
rm -rf ${demohome}/mysql2
rm -rf ${demohome}/mysql3

rm -f ${demohome}/dump*.sql

echo " done."
