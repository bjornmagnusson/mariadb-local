MariaDB initialization
======================

Step-by-step
* docker stack deploy --compose-file docker-compose.yml mariadb
* ./init.sh

All-in-one run (using Docker Stack)
* ./startAndInit.sh

All-in-one run (using Docker Compose)
* ./startAndInit.sh false