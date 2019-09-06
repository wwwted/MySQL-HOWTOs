#!/bin/sh
#
# This script will start 3 MySQL instances on localhost using ports (63306,63307,63308)
# Scenarion:
# - mysql1 (63306) and mysql2 (63307) are your existing master databases
# - mysql3 (63308) is the new MySQL multi-source slave
#
# MySQL binaries can be downloaded using:
# - wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.27-linux-glibc2.12-x86_64.tar.gz
#

demohome=/home/ted/demos/MySQL-MS # Folder to install MySQL Servers
mysqlhome=/home/ted/src/5.7.19    # Path to MySQL 5.7 binaries

# Do not edit below

mysqld=${mysqlhome}/bin/mysqld
mysql=${mysqlhome}/bin/mysql
mysqladmin=${mysqlhome}/bin/mysqladmin

[ ! -d $demohome ] && echo "Can not find $demohome, exiting" && exit 1
[ ! -x $mysqld ] && echo "Can not find $mysqld, exiting" && exit 1
[ ! -x $mysqladmin ] && echo "Can not find $mysqladmin, exiting" && exit 1

cd $mysqlhome

echo -n "Setting up 3 fresh mysql servers ..."

mkdir ${demohome}/mysql1;
mkdir ${demohome}/mysql2;
mkdir ${demohome}/mysql3;

$mysqld --initialize-insecure --datadir=${demohome}/mysql1 --user=ted --basedir=$mysqlhome
$mysqld --initialize-insecure --datadir=${demohome}/mysql2 --user=ted --basedir=$mysqlhome
$mysqld --initialize-insecure --datadir=${demohome}/mysql3 --user=ted --basedir=$mysqlhome

cd ${demohome}

echo " done."

echo -n "Starting 3 new mysqld instances..."
$mysqld --no-defaults --socket=${demohome}/mysql1/my.sock --port=63306 --datadir=${demohome}/mysql1 --server-id=1 \
        --log-error=${demohome}/mysql1/mysql.err --gtid-mode=on --enforce-gtid-consistency \
        --log-slave-updates=ON --master-info-repository=TABLE --relay_log_info_repository=TABLE \
        --basedir=$mysqlhome --innodb-flush-log-at-trx-commit=2 --log-bin --binlog-format=ROW > ${demohome}/mysql1/mysql.out & 2>&1
$mysqld --no-defaults --socket=${demohome}/mysql2/my.sock --port=63307 --datadir=${demohome}/mysql2 --server-id=2 \
        --log-error=${demohome}/mysql2/mysql.err --gtid-mode=on --enforce-gtid-consistency \
        --log-slave-updates=ON --master-info-repository=TABLE --relay_log_info_repository=TABLE \
        --basedir=$mysqlhome --innodb-flush-log-at-trx-commit=2 --log-bin --binlog-format=ROW > ${demohome}/mysql2/mysql.out & 2>&1
$mysqld --no-defaults --socket=${demohome}/mysql3/my.sock --port=63308 --datadir=${demohome}/mysql3 --server-id=3 \
        --log-error=${demohome}/mysql3/mysql.err --gtid-mode=on --enforce-gtid-consistency \
        --log-slave-updates=ON --master-info-repository=TABLE --relay_log_info_repository=TABLE \
        --basedir=$mysqlhome --innodb-flush-log-at-trx-commit=2 --log-bin --binlog-format=ROW > ${demohome}/mysql3/mysql.out & 2>&1

echo " done."
sleep 2
[ ! -f ${demohome}/mysql3/my.sock ] && echo "all servers not started wait some more ..." && sleep 5

echo 
echo "### Setting up password for user root: `date`"
echo
$mysqladmin -uroot -h127.0.0.1 -P63306 -S${demohome}/mysql1/my.sock password "root"
$mysqladmin -uroot -h127.0.0.1 -P63307 -S${demohome}/mysql2/my.sock password "root"
$mysqladmin -uroot -h127.0.0.1 -P63308 -S${demohome}/mysql3/my.sock password "root"


echo 
echo "### Create repl user on masters: `date`"
echo
$mysql -uroot -proot -h127.0.0.1 -P63306 -se "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'127.0.0.1' IDENTIFIED BY 'repl';"
$mysql -uroot -proot -h127.0.0.1 -P63307 -se "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'127.0.0.1' IDENTIFIED BY 'repl';"

echo 
echo "### MySQL installation done: `date`"
echo

echo 
echo "### Create databases and some test data on Masters `date`"
echo
$mysql -uroot -proot -h127.0.0.1 -P63306 -se "CREATE DATABASE master1"
$mysql -uroot -proot -h127.0.0.1 -P63307 -se "CREATE DATABASE master2"

$mysql -uroot -proot -h127.0.0.1 -P63306 -se "CREATE TABLE m1(id INT AUTO_INCREMENT PRIMARY KEY, i INT)" master1
$mysql -uroot -proot -h127.0.0.1 -P63306 -se "INSERT INTO m1(i) VALUES (10),(20)" master1
$mysql -uroot -proot -h127.0.0.1 -P63307 -se "CREATE TABLE m2(id INT AUTO_INCREMENT PRIMARY KEY, i INT)" master2
$mysql -uroot -proot -h127.0.0.1 -P63307 -se "INSERT INTO m2(i) VALUES (30),(40)" master2
