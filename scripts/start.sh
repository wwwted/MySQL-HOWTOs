#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi  

if [ -S $WS_HOME/mysql.sock ]; then
    echo "MySQL already runninng, socket file (/tmp/mysql.sock) exits"
    exit 1
fi


echo "starting MySQL ..."
$WS_HOME/mysqlsrc/bin/mysqld_safe --defaults-file=$WS_HOME/my.cnf --ledir=$WS_HOME/mysqlsrc/bin &
sleep 5
