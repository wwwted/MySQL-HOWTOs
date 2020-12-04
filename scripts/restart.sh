#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi  

echo "stopping mysqld ..."
$WS_HOME/mysqlsrc/bin/mysqladmin -S$WS_HOME/mysql.sock -uroot -proot shutdown
sleep 5
echo "starting MySQL ..."
$WS_HOME/mysqlsrc/bin/mysqld_safe --defaults-file=$WS_HOME/my.cnf --ledir=$WS_HOME/mysqlsrc/bin &

