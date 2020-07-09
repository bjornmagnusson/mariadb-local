# MariaDB initialization
Starts a MariaDB instance and initializes databases
Default user created
* sa, for regular use
* lbsa, for liquibase use

## Preparation
Create a ``database.yaml`` with database names to be created
```
databases:
    database1
    database2
    database3
```

## Initialize databases
Starts MariaDB server and initializes databases

```
./startAndInit.sh
```