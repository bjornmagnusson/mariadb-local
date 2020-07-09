#!/bin/bash

DOCKER_STACK_IS_USED=false
DOCKER_STACK_ORCHESTRATOR_DISCOVERED=""
MARIADB_VERSION=10.1
MARIADB_PORT=3306

readonly script="startAndInit.sh"
readonly required_software="helm yq"
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$script - Start and initialize MariaDB server and creates databases defined in database.yaml"
      echo " "
      echo "$script [options]"
      echo " "
      echo "options:"
      echo "-h, --help      show brief help"
      echo "--version       specify the version of MariaDB (default: $MARIADB_VERSION)"
      echo "--port          specify the port of MariaDB server (default: $MARIADB_PORT)"
      exit 0
      ;;
    --version)
      shift
      if test $# -gt 0; then
        MARIADB_VERSION=$1
      else
        echo "no MariaDB version specified"
        exit 1
      fi
      shift
      ;;
    --port)
      shift
      if test $# -gt 0; then
        MARIADB_PORT=$1
      else
        echo "no MariaDB port specified"
        exit 1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

for software in $required_software; do
    if [[ ! $(command -v $software) ]]; then
        echo "Required software $software is missing, please install before continuing"
        exit 1
    fi
done

MARIADB_VERSION_NAME="mariadb-${MARIADB_VERSION//./-}"
MARIADB_DEPLOYMENT_NAME="$MARIADB_VERSION_NAME-$MARIADB_PORT"
echo "Deploying MariaDB $MARIADB_VERSION as $MARIADB_DEPLOYMENT_NAME exposed at port $MARIADB_PORT"

#docker version | grep "Kubernetes" >/dev/null 2>&1
# if [ $? = 0 ]; then
#     K8S_CONTEXT=$(kubectl config current-context)
#     echo "Discovered Kubernetes environment (context = $K8S_CONTEXT)"
#     DOCKER_STACK_IS_USED=true
#     DOCKER_STACK_ORCHESTRATOR_DISCOVERED=kubernetes
# elif [ $(docker info --format='{{ .Swarm.LocalNodeState }}') = "active" ]; then
#     echo "Discovered Swarm environment"
#     DOCKER_STACK_IS_USED=true
#     DOCKER_STACK_ORCHESTRATOR_DISCOVERED=swarm
# fi
#DOCKER_STACK_IS_USED=false

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
    MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker stack --orchestrator $DOCKER_STACK_ORCHESTRATOR_DISCOVERED deploy $DOCKER_STACK_NAMESPACE --compose-file docker-compose.yml $MARIADB_DEPLOYMENT_NAME    
    if [ $? != 0 ]; then
        echo "Failed to deploy stack $MARIADB_DEPLOYMENT_NAME, exiting"
        exit 1
    fi
    docker stack --orchestrator $DOCKER_STACK_ORCHESTRATOR_DISCOVERED ps $DOCKER_STACK_NAMESPACE $MARIADB_DEPLOYMENT_NAME
    docker stack --orchestrator $DOCKER_STACK_ORCHESDOCKER_STACK_ORCHESTRATOR_DISCOVEREDTRATOR services $DOCKER_STACK_NAMESPACE $MARIADB_DEPLOYMENT_NAME
else 
    MARIADB_VERSION=$MARIADB_VERSION MARIADB_PORT=$MARIADB_PORT docker-compose --project-name $MARIADB_DEPLOYMENT_NAME up -d
    if [ $? != 0 ]; then
        echo "Failed to deploy stack $MARIADB_DEPLOYMENT_NAME, exiting"
        exit 1
    fi
    docker-compose --project-name $MARIADB_DEPLOYMENT_NAME ps
fi

DATABASES_YAML=$(yq read databases.yaml)
for DATABASE in $(echo $DATABASES_YAML | yq r - 'databases'); do 
    DATABASES="$DATABASES $DATABASE" 
done
./init.sh $MARIADB_PORT "$DATABASES"