#!/bin/bash

DOCKER_STACK_IS_USED=${1:-true}
MARIADB_VERSION=${2:-10.1}
MARIADB_PORT=${3:-3306}

MARIADB_VERSION_NAME="mariadb-${MARIADB_VERSION//./-}"
MARIADB_DEPLOYMENT_NAME="$MARIADB_VERSION_NAME-$MARIADB_PORT"
echo "Deploying MariaDB $MARIADB_VERSION as $MARIADB_DEPLOYMENT_NAME exposed at port $MARIADB_PORT"

if [ $DOCKER_STACK_IS_USED = true ]; then
    DOCKER_STACK_NAMESPACE=""
    if [ $(docker version | grep Kubernetes) ]; then
        DOCKER_STACK_NAMESPACE="--namespace $MARIADB_VERSION_NAME"
        kubectl get ns $MARIADB_VERSION_NAME
        if [ $? != 0 ]; then
            echo "Namespace $MARIADB_VERSION_NAME does not exist, creating it now"
            kubectl create ns $MARIADB_VERSION_NAME
        fi
    fi
    MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker stack deploy $DOCKER_STACK_NAMESPACE --compose-file docker-compose.yml $MARIADB_DEPLOYMENT_NAME    
    if [ $? != 0 ]; then
        echo "Failed to deploy stack $MARIADB_DEPLOYMENT_NAME, exiting"
        exit 1
    fi
    docker stack ps $DOCKER_STACK_NAMESPACE $MARIADB_DEPLOYMENT_NAME
    docker stack services $DOCKER_STACK_NAMESPACE $MARIADB_DEPLOYMENT_NAME
else 
    MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker-compose --project-name $MARIADB_DEPLOYMENT_NAME up -d
    if [ $? != 0 ]; then
        echo "Failed to deploy stack $MARIADB_DEPLOYMENT_NAME, exiting"
        exit 1
    fi
    docker-compose --project-name $MARIADB_DEPLOYMENT_NAME ps
fi
./init.sh $MARIADB_PORT