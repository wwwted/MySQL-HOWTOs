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
Make skript executable:
```
bash$ chmod +x ./scripts/*
```
Create soft link to MySQL binaries:
```
bash$ ln -s /home/ted/src/mysql-advanced-5.7.21-linux-glibc2.12-x86_64 mysql57
```

**[Back to Agenda](./../README.md)**
