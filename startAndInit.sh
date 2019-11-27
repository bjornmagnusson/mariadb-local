#!/bin/bash

docker stack deploy --compose-file docker-compose.yml mariadb
docker stack ls
docker stack ps mariadb
docker stack services mariadb

./init.sh