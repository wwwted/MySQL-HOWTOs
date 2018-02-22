**[Back to Agenda](./../README.md)**

Setup test environment
-------

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
Setup environment variables, this is needed to get correct paths for scrips, setenv will also create initial configuration file for MySQL, this is only done if no configuration file exists.
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

**Remember:**
> **You must manually run the** `bash$ . ./setenv` **command in all *terminals* before executing any commands/scripts otherwice they will fail!**

If you want to read the markdown slides offline you have to install a plugin to your web browser.
I use this [one](https://chrome.google.com/webstore/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk) for Chrome and it worked well.

Running the scripts
-----

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
