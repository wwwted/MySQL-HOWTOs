**[Back to Agenda](./../README.md)**

# Setup demo environment

Before you can run any MySQL scripts you need to first download the MySQL binaries, there is a guide on landing page.

Download code from github:
```
bash$ git clone https://github.com/wwwted/MySQL-HOWTOs.git
```
or download zipfile manually direct from github and extract content.

Go into folder:
```
bash$ cd MySQL-HOWTOs/
```
Setup environment variables, these are needed to get correct paths for scrips to execute and create configuration file for MySQL.
```
bash$ . ./setenv
```
Make scripts executable:
```
bash$ chmod +x ./scripts/*
```
Create soft link to MySQL binaries:
```
bash$ ln -s /home/ted/src/mysql-advanced-5.7.21-linux-glibc2.12-x86_64 mysql57
```
The structure should now look something like: 
```
/path/to/MySQL-HOWTOs/
                      scripts/
                      howtos/
                      README.md                      
                      setenv
                      my.cnf
                      mysql57 -> /path/to/mysql-bins
```
If you have any problmes starting MySQL verify that configuration in my.cnf is correct.

**Remember, you must manually run the** `<bash$ . ./setenv">` **command in all *terminals* before executing any commands/scripts otherwice they will fail**

Install/start MySQL:
```
bash$ ./scripts/create_instances.sh
```
Re-start MySQL:
```
bash$ ./scripts/restart.sh
```
Start MySQL:
```
bash$ ./scripts/start.sh
```
Stop MySQL:
```
bash$ ./scripts/stop.sh
```
Remove MySQL installation:
```
bash$ ./scripts/clean.sh
```
Login to MySQL client:
```
bash$ mysql -u root -proot mysql -S/tmp/mysql.sock
```


**[Back to Agenda](./../README.md)**
