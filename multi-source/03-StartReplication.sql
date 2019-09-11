--
-- Run as: /home/ted/src/5.7.19/bin/mysql -uroot -proot -S./mysql3/my.sock <  03-StartReplication.sql
-- Run as: /home/ted/src/8.0.17/bin/mysql -uroot -proot -S./mysql3/my.sock <  03-StartReplication.sql
--

CHANGE MASTER TO MASTER_HOST="127.0.0.1", MASTER_PORT=63306, MASTER_USER="repl", MASTER_PASSWORD="repl", MASTER_AUTO_POSITION=1 FOR CHANNEL "master1";
CHANGE MASTER TO MASTER_HOST="127.0.0.1", MASTER_PORT=63307, MASTER_USER="repl", MASTER_PASSWORD="repl", MASTER_AUTO_POSITION=1 FOR CHANNEL "master2";

-- CHANGE REPLICATION FILTER REPLICATE_DO_DB=(master1,master2);
CHANGE REPLICATION FILTER REPLICATE_WILD_DO_TABLE=('master1.%','master2.%');

START SLAVE FOR CHANNEL "master1";
START SLAVE FOR CHANNEL "master2";

SHOW SLAVE STATUS FOR CHANNEL "master1"\G
SHOW SLAVE STATUS FOR CHANNEL "master2"\G
