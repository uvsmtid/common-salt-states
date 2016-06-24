
-- Flushing privileges is done after each statement
-- to avoid any chance of this wierd isssue.
-- See: http://stackoverflow.com/a/17436813/441652
FLUSH PRIVILEGES;

-- TODO: Is it really needed if there is `DROP USER` below?
-- DELETE FROM mysql.db where USER = 'sonar';

FLUSH PRIVILEGES;

-- Create user to avoid failure of GRANT statement.
CREATE USER IF NOT EXISTS 'sonar'@'localhost' IDENTIFIED BY '';

FLUSH PRIVILEGES;

-- Create user to avoid failure of GRANT statement.
CREATE USER IF NOT EXISTS 'sonar'@'%' IDENTIFIED BY '';

FLUSH PRIVILEGES;

-- Make sure user records exist so that dropping user does not fail.
-- See: http://stackoverflow.com/a/3241918/441652
GRANT USAGE ON *.* TO 'sonar'@'localhost';

FLUSH PRIVILEGES;

-- Make sure user records exist so that dropping user does not fail.
-- See: http://stackoverflow.com/a/3241918/441652
GRANT USAGE ON *.* TO 'sonar'@'%';

FLUSH PRIVILEGES;

DROP USER sonar@localhost;

FLUSH PRIVILEGES;

DROP USER sonar;

FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS sonar;

FLUSH PRIVILEGES;

CREATE DATABASE sonar;

FLUSH PRIVILEGES;

CREATE USER sonar@localhost IDENTIFIED BY '';

FLUSH PRIVILEGES;

CREATE USER 'sonar'@'%' IDENTIFIED BY '';

FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON sonar.* TO sonar@localhost IDENTIFIED BY '' WITH GRANT OPTION;

FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'%' IDENTIFIED BY '' WITH GRANT OPTION;

FLUSH PRIVILEGES;

