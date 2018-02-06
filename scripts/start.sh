#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi  

echo "starting MySQL ..."
$WS_HOME/mysql57/bin/mysqld_safe --defaults-file=$WS_HOME/my.cnf --ledir=$WS_HOME/mysql57/bin &
sleep 5
