#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi

echo "stopping mysql..."
$WS_HOME/mysqlsrc/bin/mysqladmin -S/tmp/mysql.sock -uroot -proot shutdown
$WS_HOME/mysqlsrc/bin/mysqladmin -S/tmp/mysql.sock -uroot shutdown

echo "pgrep mysql...."
pgrep mysql -fla
echo "Press <ENTER> to continue"
read

echo "removing datadir ..."
rm -fr $WS_HOME/mysqldata/*
rm -f $WS_HOME/my.cnf

echo "Done!"
du -sh $WS_HOME/

