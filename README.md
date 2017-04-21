# Presto Docker Container

Docker image for Presto Server.

## Supported tags and Dockerfiles

* [latest](./0.167-t.0.3): [Dockerfile](./0.167-t.0.3/Dockerfile)
* [0.167-t.0.3](./0.167-t.0.3): [Dockerfile](./0.167-t.0.3/Dockerfile)

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

To create a Presto cluster you can use [Docker Compose](#create-a-presto-cluster-with-docker-compose) or [Kubernetes](#create-a-presto-cluster-with-kubernetes).

## Build your own image

To build a new image just execute `make`.

If you which to release/push the new image to a Docker Registry, modify in the Makefile the variable `DOCKER_USER` and execute:

    make release

Optionally, you can pass the Presto Server version to build or release.

    make PRESTO_VERSION=0.167-t.0.3
    make release PRESTO_VERSION=0.167-t.0.3

With the `make` you can also:
* Do it all (build, release and clean): `make all`
* Pull the image: `make pull`
* Create a container and login into it: `make sh`
* Remove any container creted with that image: `make clean`
* Remove container(s) and the image: `make clean-all`
* List all the containers and images: `make ls`
* Open the Presto Dashboar (only Mac OSX): `make presto-dashboard`
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

HIVE Metastore Parameters:

    HIVE_METASTORE_HOST=localhost
    HIVE_METASTORE_PORT=9083

## Create a Presto Cluster with Docker Compose

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

And, to destroy the cluster:

    docker-compose down

## Create a Presto Cluster with Kubernetes

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
