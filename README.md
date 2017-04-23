# Presto Docker Container

Docker image for Presto Server and Presto CLI.

## Supported tags and Dockerfiles

### Presto Server:
* [latest](./0.167-t.0.3): [Dockerfile](./0.167-t.0.3/Dockerfile)
* [0.167-t.0.3](./0.167-t.0.3): [Dockerfile](./0.167-t.0.3/Dockerfile)

### Presto CLI:
* [latest](./0.167-t.0.3/cli): [Dockerfile](./0.167-t.0.3/cli/Dockerfile)
* [0.167-t.0.3](./0.167-t.0.3/cli): [Dockerfile](./0.167-t.0.3/cli/Dockerfile)

## Quick Start

This repository is integrated with Docker Registry at `johandry/presto`, any change in the `master` branch will push a new image to Docker Registry.

To get the image use the Docker pull command:

    docker pull johandry/presto:0.167-t.0.3

With a Dockerfile you can use:

    FROM johandry/presto:0.167-t.0.3

    COPY catalog/Hive.properties /usr/lib/presto/etc/catalog/

    ENV HTTP_SERVER_PORT=8080
    ENV PRESTO_MAX_MEMORY=50
    ENV PRESTO_MAX_MEMORY_PER_NODE=1
    ENV PRESTO_JVM_HEAP_SIZE=8

    CMD /etc/init.d/presto run

Then you can build and run a Presto Coordinator with:

    docker build -t my_presto .
    docker run -it --rm --name presto_coordinator -d my_presto /bin/sh --login

To use Presto CLI, first get the image:

    docker pull johandry/presto-cli:0.167-t.0.3

It's not common but you may use it in your own image with:

    FROM johandry/presto-cli:latest

To use the Presto CLI, run a container with the presto-cli image and send the presto parameters as commands.

    docker run --name presto-cli --rm -it johandry/presto-cli --server ${coordinator_ip}:8080 --execute ${query}

Or, use no command parameter to execute the Presto CLI

    docker run --name presto-cli --rm -it johandry/presto-cli
    presto>  show catalogs;
      Catalog
    -----------
     blackhole
     jmx
     system
     tpch
    (4 rows)

    Query 20170423_051645_00006_ccijx, FINISHED, 1 node
    Splits: 1 total, 1 done (100.00%)
    0:00 [0 rows, 0B] [0 rows/s, 0B/s]

    presto>

To create a Presto cluster you can use [Docker Compose](./compose/README.md) or [Kubernetes](./compose/README.md).

## Build your own image

To build the new images just execute `make`.

If you which to release/push the new images to a Docker Registry, modify in the Makefile the variable `DOCKER_USER` and execute:

    make release

Optionally, you can pass the Presto Server version to build or release.

    make PRESTO_VERSION=0.167-t.0.3
    make release PRESTO_VERSION=0.167-t.0.3

Adding `-presto` or `-cli` to the `build` or `release` make rules, will build or release the Presto Server or Presto CLI images. For example:

    make build-presto
    make release-presto
    make build-cli
    make release-cli

With the `make` you can also:
* Do it all (build, release and clean): `make all`
* Pull the image: `make pull`
* Create a container and login into it: `make sh`
* Remove any container creted with that image: `make clean`
* Remove container(s) and the image: `make clean-all`
* List all the containers and images: `make ls`
* Open the Presto Dashboar (only Mac OSX): `make presto-dashboard`
* Open Presto CLI: `make cli`
* Execute queries: `make query H=coordinator Q='show catalogs;'`, `make query-catalogs H=coordinator`, `make query-workers H=coordinator`
* And, you can list all the options and description with: `make help`

## Environment variables for the container

### Required variables for **every node**

Presto port:

    HTTP_SERVER_PORT=8080

Presto memory settings:

    PRESTO_MAX_MEMORY=50
    PRESTO_MAX_MEMORY_PER_NODE=1
    PRESTO_JVM_HEAP_SIZE=8

### Required variables for **every worker**

Address of the Coordinator (IP address or hostname):

    COORDINATOR=coordinator

### Optional variables:

HIVE metastore parameters, if **all of them** are set a Hive metastore connector will be created:

    HIVE_METASTORE_HOST=hive-hadoop-service
    HIVE_METASTORE_PORT=9083

MySQL parameters, if **all of them** are set a MySQL connector will be created:

    MYSQL_HOST=mysql-service
    MYSQL_PORT=3306
    MYSQL_DATABASE=prestodemo
    MYSQL_USER=test
    MYSQL_PASSWORD=test

## What's in the image?

The image contain:
* Alpine 3.5 (from base image `openjdk:alpine`)
* OpenJDK 8u121 (`openjdk:alpine`)
* Python2
* Presto 0.167-t.0.3

The entrypoint will:
* Configure Presto:
  * Update Node Id in `/etc/presto/node.properties`
  * Setup Presto as coordinator or worker, depending of the `COORDINATOR` environment variable
  * Set JVM Heap Size in `/etc/presto/jvm.config`
* Create a Hive Metastore if the `HIVE_METASTORE_*` environment variables are set

## TODO

- [X] Create an image based on Java 8 OpenJDK with Alpine 3.5 (Java is a dependency for Presto Server)
- [X] Make the image packed with Python 2.7 (Python >2.4 is required by Presto Server)
- [X] Install Presto Server using the tar.gz file (The rpm require Java 8 Oracle)
- [X] Setup Presto Server as a single node in the container
- [X] Add the following catalogs/connectors to the image: BlackHole, JMX & TPCH
- [X] The entrypoint script configure the container as a coordinator or worker, based on environment variables
- [X] Create a Makefile to automate all the tasks
- [X] Create a docker-compose file to create a cluster for testing.
- [X] Fix Connection refused when trying to connect from a worker to coordinator.
- [ ] Define if create a new image to be the base of presto image. This image will have Java and Python.
- [ ] Integrate with Kubernetes
