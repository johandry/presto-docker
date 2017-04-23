# Create a Presto Cluster with Docker Compose

Go to the `compose` directory and run:

    cd compose
    docker-compose up -d
    docker-compose scale worker=3

To customize the Presto parameters (i.e. Java memory and Hive Metastore) modify the environment variables located in the files `compose/env/*.env`.

To view the Presto UI get the Presto Dashboard port with `docker port coordinator 8080/tcp | cut -f2 -d:`, then open the URL `http://localhost:PORT`. Or, if you are in Mac OSX, use:

    make presto-dashboard

To login into the coordinator or any worker, use:

    docker-compose exec coordinator sh
    # Or to login into worker #1:
    docker-compose exec --index=1 worker sh

To view the Presto UI get the Presto Dashboard port with `docker port coordinator 8080/tcp | cut -f2 -d:`, then open the URL `http://localhost:PORT`. Or, if you are in Mac OSX, use:

    make presto-dashboard

To use the Presto CLI, execute:

    make cli

Or, you can execute Presto CLI queries like this:

    make query Q='show catalogs;'
    make query-catalogs
    make query-workers

And, to destroy the cluster:

    docker-compose down
    # Or this, to remove the MySQL database
    docker-compose down --volumes


# Environment variables for the container

All the environment variables are defined in the files `compose/env/*.env`. There is one file for the coordinator environments (`coordinator.env`), for the workers environments (`worker.env`) and for both (`presto.env`).

There may be other environment variables files for other services such as `mysql.env`

Some variables are defined in the file `.env` but those usually do not change.

## Required variables for **every node**

Presto port:

    HTTP_SERVER_PORT=8080

Presto memory settings:

    PRESTO_MAX_MEMORY=50
    PRESTO_MAX_MEMORY_PER_NODE=1
    PRESTO_JVM_HEAP_SIZE=8

## Required variables for **every worker**

Address of the Coordinator (IP address or hostname):

    COORDINATOR=coordinator

## Optional variables:

HIVE Metastore Parameters:

    HIVE_METASTORE_HOST=localhost
    HIVE_METASTORE_PORT=9083
