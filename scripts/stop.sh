#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi

echo "stopping ..."
$WS_HOME/mysqlsrc/bin/mysqladmin -S$WS_HOME/mysql.sock -uroot -proot shutdown
sleep 5
