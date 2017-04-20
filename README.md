# Presto Docker

Docker image with Presto Server ready to create a Presto Cluster.

## Quick Start

Build the image to create a container and use it with `docker`, `docker-compose` or even Kubernetes.

    make

Or, you may use Docker-Compose to build the image and create a cluster.

    docker-compose up -d
  	docker-compose scale worker=3

To view the Presto UI execute `docker port coordinator 8080/tcp | cut -f2 -d:` to know the port, then open the URL `http://localhost:PORT` using the previous port. Or, if you are in Mac OSX, use:

    open "http://localhost:"`docker port coordinator 8080/tcp | cut -f2 -d:`
    # Or:
    make presto-dashboard

To create a single node (a coordinator) and login into it:

    make
    make login

But if you create a cluster, use:

    docker-compose exec coordinator sh
    # Or to worker #1:
    docker-compose exec --index=1 worker sh

To destroy the cluster use Docker-Compose:

    docker-compose down

Using make you can remove the container (`make clean`) or all the images (`make clean-all`). The build rule will not build the image if there is a presto container, to build the image and



## TODO

- [X] Create an image based on Java 8 OpenJDK with Alpine 3.5 (Java is a dependency for Presto Server)
- [X] Make the image packed with Python 2.7 (Python >2.4 is required by Presto Server)
- [X] Install Presto Server using the tar.gz file (The rpm require Java 8 Oracle)
- [X] Setup Presto Server as a single node in the container
- [X] Add the following catalogs/connectors to the image: BlackHole, JMX & TPCH
- [X] The entrypoint script configure the container as a coordinator or worker, based on environment variables
- [X] Create a Makefile to automate all the tasks
- [X] Create a docker-compose file to create a cluster for testing.
- [ ] Define if create a new image to be the base of presto image. This image will have Java and Python.
- [ ] Integrate with Kubernetes
- [ ] Use a S3 Metastore instead of Hive
