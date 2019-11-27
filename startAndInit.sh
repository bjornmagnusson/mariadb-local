#!/bin/bash

MARIADB_VERSION=${1:-10.1}
MARIADB_PORT=${2:-3306}
MARIADB_STACK_NAME="mariadb-${MARIADB_VERSION//./-}-$MARIADB_PORT"
echo "Deploying MariaDB $MARIADB_VERSION as stack $MARIADB_STACK_NAME exposed at port $MARIADB_PORT"

MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker stack deploy --compose-file docker-compose.yml $MARIADB_STACK_NAME
docker stack ls
docker stack ps $MARIADB_STACK_NAME
docker stack services $MARIADB_STACK_NAME

./init.sh $MARIADB_PORT