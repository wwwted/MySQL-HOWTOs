#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi

echo "Stopping mysql..."
$WS_HOME/mysqlsrc/bin/mysqladmin -S/tmp/mysql.sock -uroot -proot shutdown
$WS_HOME/mysqlsrc/bin/mysqladmin -S/tmp/mysql.sock -uroot shutdown

echo "pgrep mysql...."
pgrep mysql -fla
echo "Press <ENTER> to continue"
read

echo "removing datadir ..."
rm -fr $WS_HOME/mysqldata

echo "creating datadir ..."
mkdir $WS_HOME/mysqldata

echo "initialize datadir.... "
$WS_HOME/mysqlsrc/bin/mysqld --initialize-insecure --basedir=$WS_HOME/mysqlsrc --datadir=$WS_HOME/mysqldata

echo "starting mysql ..."
$WS_HOME/mysqlsrc/bin/mysqld_safe --defaults-file=$WS_HOME/my.cnf --ledir=$WS_HOME/mysqlsrc/bin &

sleep 5;

echo "MySQL started, pgrep mysql...."
pgrep mysql -fla
echo "Press <ENTER> to continue"
read

echo "setting password for root ..."
$WS_HOME/mysqlsrc/bin/mysql -uroot -S/tmp/mysql.sock -se "SET sql_log_bin=0;set password='root'"
echo "Use old native password for root ..."
$WS_HOME/mysqlsrc/bin/mysql -uroot -proot -S/tmp/mysql.sock -se "SET sql_log_bin=0;ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'"


