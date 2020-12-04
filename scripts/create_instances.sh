#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi

mysql_datadir=$WS_HOME/mysqldata

if [ -S $WS_HOME/mysql.sock ]; then
    echo "Stopping mysql..."
    $WS_HOME/mysqlsrc/bin/mysqladmin -S$WS_HOME/mysql.sock -uroot -proot shutdown
fi

echo ""
echo "About to remove datadir ($mysql_datadir)"
echo "Press <ENTER> to continue"
read

echo "Removing datadir ($mysql_datadir)"
rm -fr $mysql_datadir

echo "Creating datadir ($mysql_datadir)"
mkdir $mysql_datadir

echo "Running mysqld --initialize to populate $mysql_datadir"
$WS_HOME/mysqlsrc/bin/mysqld --initialize-insecure --basedir=$WS_HOME/mysqlsrc --datadir=$mysql_datadir
#$WS_HOME/mysqlsrc/bin/mysqld --initialize-insecure --basedir=$WS_HOME/mysqlsrc --datadir=$mysql_datadir --lower-case-table-names=1

echo "Starting mysql with configuratiuon file $WS_HOME/my.cnf"
$WS_HOME/mysqlsrc/bin/mysqld_safe --defaults-file=$WS_HOME/my.cnf --ledir=$WS_HOME/mysqlsrc/bin &

while [ ! -S $WS_HOME/mysql.sock ]
do
  echo "Waiting for MySQL to start..."
  sleep 2 
done

echo "Setting password for root ..."
$WS_HOME/mysqlsrc/bin/mysql -uroot -S$WS_HOME/mysql.sock -se "SET sql_log_bin=0;set password='root'"
echo "Use old native password for root ..."
$WS_HOME/mysqlsrc/bin/mysql -uroot -proot -S$WS_HOME/mysql.sock -se "SET sql_log_bin=0;ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'"

echo "Create user ted/ted"
$WS_HOME/mysqlsrc/bin/mysql -uroot -proot -S$WS_HOME/mysql.sock -se"SET SQL_LOG_BIN=0; CREATE USER 'ted'@'%' IDENTIFIED BY 'ted'; GRANT ALL ON *.* TO 'ted'@'%' WITH GRANT OPTION";
