# MariaDB initialization
Starts a MariaDB instance and initializes databases and default users (sa and lbsa)

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