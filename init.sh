#!/bin/bash

MARIADB_PORT=${1:-3306}
DATABASES=${2:-""}
USER="sa"
USER_RESTRICTED="sa_restricted"
USER_RESTRICTED_PASSWORD="sa_restricted_password"
USER_LIQUIBASE="lbsa"
ROOT_PASSWORD="root"
MYSQL_CONNECT_STRING="mysql --port=$MARIADB_PORT -uroot -p$ROOT_PASSWORD"
MYSQL_INIT_SLEEP=10
MYSQL_INIT_INFO=30 # must be dividably by MYSQL_INIT_SLEEP

i=1
while [ -n "$($MYSQL_CONNECT_STRING -estatus 2>&1 > /dev/null)" ]; do
  echo "$i) MariaDB server not running, retrying in ${MYSQL_INIT_SLEEP}s"
  if [ $(($i % $(($MYSQL_INIT_INFO / $MYSQL_INIT_SLEEP)))) = 0 ]; then
    eval "$MYSQL_CONNECT_STRING -estatus"
  fi
  ((i=i+1))
  sleep $MYSQL_INIT_SLEEP
done
eval "$MYSQL_CONNECT_STRING -eSTATUS"

echo "Creating user $USER"
eval "$MYSQL_CONNECT_STRING -e\"CREATE USER IF NOT EXISTS $USER\"";
if [ $? != 0 ]; then
    echo "Failed to create user $USER"
    exit 1
fi
echo "Granting privileges to $USER for all databases"
eval "$MYSQL_CONNECT_STRING -e\"GRANT ALL PRIVILEGES on *.* to sa@'%'\"";
if [ $? != 0 ]; then
    echo "Failed to grant privileges to user $USER"
    exit 1
fi

echo "Creating user $USER_RESTRICTED"
eval "$MYSQL_CONNECT_STRING -e\"CREATE USER IF NOT EXISTS $USER_RESTRICTED IDENTIFIED BY '$USER_RESTRICTED_PASSWORD'\"";
if [ $? != 0 ]; then
    echo "Failed to create user $USER_RESTRICTED"
    exit 1
fi
echo "Granting privileges to $USER_RESTRICTED for all databases"
eval "$MYSQL_CONNECT_STRING -e\"GRANT SELECT, EXECUTE, SHOW VIEW, CREATE TEMPORARY TABLES, DELETE, DROP, EVENT, INDEX,
INSERT, REFERENCES, TRIGGER, UPDATE, LOCK TABLES on *.* to sa_restricted@'%' WITH GRANT OPTION\""

echo "Creating user $USER_LIQUIBASE"
eval "$MYSQL_CONNECT_STRING -e\"CREATE USER IF NOT EXISTS $USER_LIQUIBASE\"";
if [ $? != 0 ]; then
    echo "Failed to create user $USER_LIQUIBASE"
    exit 1
fi

echo "Granting privileges to $USER_LIQUIBASE for all databases"
eval "$MYSQL_CONNECT_STRING -e \"GRANT SELECT, EXECUTE, SHOW VIEW, ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, INDEX, INSERT, REFERENCES, TRIGGER, UPDATE, LOCK TABLES on *.* to lbsa@'%' WITH GRANT OPTION\""
if [ $? != 0 ]; then
    echo "Failed to grant privileges to user $USER_LIQUIBASE"
    exit 1
fi
eval "$MYSQL_CONNECT_STRING -e\"SELECT user,host FROM mysql.user;\""

mysql --port=$MARIADB_PORT --user=$USER -e"SHOW DATABASES;"
echo "Creating databases"
for db in $DATABASES; do
    echo "Creating database $db"
    eval "$MYSQL_CONNECT_STRING -e\"CREATE DATABASE IF NOT EXISTS $db\"";
done
echo "Listing databases for $USER"
mysql --port=$MARIADB_PORT --user=$USER -e"SHOW DATABASES;"