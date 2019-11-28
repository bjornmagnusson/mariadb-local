#!/bin/bash

DOCKER_STACK_IS_USED=${1:-true}
MARIADB_VERSION=${2:-10.1}
MARIADB_PORT=${3:-3306}

MARIADB_DEPLOYMENT_NAME="mariadb-${MARIADB_VERSION//./-}-$MARIADB_PORT"
echo "Deploying MariaDB $MARIADB_VERSION as $MARIADB_DEPLOYMENT_NAME exposed at port $MARIADB_PORT"

if [ $DOCKER_STACK_IS_USED = true ]; then
    MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker stack deploy --compose-file docker-compose.yml $MARIADB_DEPLOYMENT_NAME    
    docker stack ps $MARIADB_DEPLOYMENT_NAME
    docker stack services $MARIADB_DEPLOYMENT_NAME
else 
    MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker-compose --project-name $MARIADB_DEPLOYMENT_NAME up -d
    docker-compose --project-name $MARIADB_DEPLOYMENT_NAME ps
fi
./init.sh $MARIADB_PORT