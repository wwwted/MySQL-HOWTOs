
mysql -uroot -proot mysql < mysqlsrc/share/uninstall_rewriter.sql
mysql -uroot -proot mysql <  mysqlsrc/share/install_rewriter.sql

mysql -uroot -proot mysql << EOC

drop procedure IF EXISTS prepare_data;
drop database IF EXISTS labb;

create database labb;
use labb;

create table testing (
   id int primary key auto_increment,
   name varchar(32),
   address varchar(32),
   age int,
   index (name)
);

DELIMITER $$
CREATE PROCEDURE prepare_data()
BEGIN
  DECLARE i INT DEFAULT 100;
  WHILE i < 10000 DO
    INSERT INTO labb.testing (id,name,address,age) VALUES (i,CONCAT("ted",i),CONCAT("address",i),i);
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

CALL prepare_data();

INSERT INTO query_rewrite.rewrite_rules ( pattern, pattern_database, replacement )
VALUES
(
  'SELECT * FROM testing WHERE id = ?',
  'labb',
  'SELECT name, address, age FROM testing WHERE id = ?'
);
CALL query_rewrite.flush_rewrite_rules();

select * from testing where id=100;
show warnings\G

INSERT INTO query_rewrite.rewrite_rules ( pattern, pattern_database, replacement )
VALUES
(
  # Pattern
  'SELECT * FROM testing WHERE name like ?',
  # Database
  'labb',
  # Replacement
  'SELECT * FROM testing WHERE name like ? limit 10'
);
CALL query_rewrite.flush_rewrite_rules();

select * from testing where name like 'ted%';
show warnings\G

INSERT INTO query_rewrite.rewrite_rules ( pattern, pattern_database, replacement )
VALUES
(
  # Pattern
  'SELECT * FROM testing WHERE name like ?',
  # Database
  'labb',
  # Replacement
  'SELECT /*+ MAX_EXECUTION_TIME(10)*/ * FROM testing WHERE name like ?'
);
CALL query_rewrite.flush_rewrite_rules();

select * from testing where name like 'ted%';
show warnings\G

EOC
