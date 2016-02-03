DROP DATABASE IF EXISTS sonar;
CREATE DATABASE sonar; 

USE mysql;

DELETE FROM mysql.db where USER = 'sonar';

GRANT USAGE ON *.* TO sonar@localhost;

GRANT USAGE ON *.* TO 'sonar'@'%';


DROP USER sonar@localhost;

DROP USER sonar;

CREATE USER sonar@localhost IDENTIFIED BY '';
CREATE USER 'sonar'@'%' IDENTIFIED BY ''; 


GRANT ALL PRIVILEGES ON sonar.* TO sonar@localhost IDENTIFIED BY '' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'%' IDENTIFIED BY '' WITH GRANT OPTION;
FLUSH PRIVILEGES;
