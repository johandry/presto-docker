#===============================================================================
# Author: Johandry Amador <ja186051@teradata.com>
# Title:  Presto Container
#
# Usage: make [<rule>]
#
# Basic rules:
# 		<none>		If no rule is specified will do the 'default' rule which is 'build'
#			build     Build the Presto Container.
#			login     Login into a running container or a new one.
# 		clean 		Remove all the running containers.
#     help			Display all the existing rules and description of what they do
#     version   Shows the Presto-Docker version.
# 		all 			Will do 'build' and 'clean'
#
# Description: This Makefile is to create a Presto container and use it with
# Docker-compose or Kubernetes.
# Use 'make help' to view all the options or go to
# https://github.td.teradata.com/ja186051/presto-docker
#
# Report Issues or create Pull Requests in https://github.td.teradata.com/ja186051/presto-docker
#===============================================================================

## Variables (Modify their values if needed):
## -----------------------------------------------------------------------------

# SHELL need to be defined at the top of the Makefile. Do not change its value.
SHELL				 := /bin/bash

## Variables optionally assigned from Environment Variables:
## -----------------------------------------------------------------------------

PRESTO_VERSION ?= 0.167-t.0.3
DOCKER_USER			= johandry

CLI_PORT 			 ?= $(P)
ifeq ($(CLI_PORT),)
CLI_PORT 			 := 8080
endif

# Constants (You would not want to modify them):
## -----------------------------------------------------------------------------

VERSION 					= $(shell grep Version Dockerfile | cut -f2 -d= | tr -d '"')

# Docker:
DOCKER_IMG   		:= presto
DOCKER_NAME  		:= presto
DOCKER_CLI_IMG 	:= presto-cli
DOCKER_CLI_NAME := presto-cli
DOCKER_BASE  		:= $(shell grep 'FROM ' $(PRESTO_VERSION)/Dockerfile | cut -f2 -d' ' | tr -d ' ')

DOCKER_ENV    	:= --env-file compose/env/common.env --env-file compose/env/coordinator.env
DOCKER_VOL			:= -v $$(pwd)/compose/data/coordinator:/root/shared
DOCKER_RUN 	  	:= docker run $(DOCKER_VOL) $(DOCKER_ENV) --name $(DOCKER_NAME) --rm -it $(DOCKER_IMG):$(PRESTO_VERSION)
DOCKER_RUN_CLI 	:= docker run --name $(DOCKER_CLI_NAME) --rm -it $(DOCKER_CLI_IMG):$(PRESTO_VERSION) --server

NO_COLOR 		 ?= false

# Output:
ECHO 				 := echo -e

ifeq ($(NO_COLOR),false)
C_STD 				= $(shell $(ECHO) -e "\033[0m")
C_RED		 			= $(shell $(ECHO) -e "\033[91m")
C_GREEN 			= $(shell $(ECHO) -e "\033[92m")
C_YELLOW 			= $(shell $(ECHO) -e "\033[93m")
C_BLUE	 			= $(shell $(ECHO) -e "\033[94m")

I_CROSS 			= $(shell $(ECHO) -e "\xe2\x95\xb3")
I_CHECK 			= $(shell $(ECHO) -e "\xe2\x9c\x94")
I_BULLET 			= $(shell $(ECHO) -e "\xe2\x80\xa2")
else
C_STD 				=
C_RED		 			=
C_GREEN 			=
C_YELLOW 			=
C_BLUE	 			=

I_CROSS 			= x
I_CHECK 			= .
I_BULLET 			= *
endif

## To find rules not in .PHONY:
# diff <(grep '^.PHONY:' Makefile | sed 's/.PHONY: //' | tr ' ' '\n' | sort) <(grep '^[^# ]*:' Makefile | grep -v '.PHONY:' | sed 's/:.*//' | sort) | grep '[>|<]'

.PHONY: default help all version
.PHONY: build test clean clean-all
.PHONY: login ls

## Default Rules:
## -----------------------------------------------------------------------------

# default is the rule that is executed when no rule is specified in make. By
# default make will do the rule 'build'
default: build

# all is to execute the entire process to create a Presto AMI and a Presto
# Cluster.
all: build release clean

# help to print all the commands and what they are for
help:
	@content=""; grep -v '.PHONY:' Makefile | grep -v '^## ' | grep '^[^# ]*:' -B 5 | grep -E '^#|^[^# ]*:' | \
	while read line; do if [[ $${line:0:1} == "#" ]]; \
		then l=$$($(ECHO) $$line | sed 's/^# /  /'); content="$${content}\n$$l"; \
		else header=$$($(ECHO) $$line | sed 's/^\([^ ]*\):.*/\1/'); [[ $${content} == "" ]] && content="\n  $(C_YELLOW)No help information for $${header}$(C_STD)"; $(ECHO) "$(C_BLUE)$${header}:$(C_STD)$$content\n"; content=""; fi; \
	done

# display the version of this project
version:
	@$(ECHO) "$(C_GREEN)Version:$(C_STD) $(VERSION)"

## Main Rules:
## -----------------------------------------------------------------------------

# build a new Presto Server image
build-presto:
	@$(ECHO) "$(C_GREEN)Building Presto Server image with Presto $(PRESTO_VERSION):$(C_STD)"
	@cd $(PRESTO_VERSION) && docker build -t $(DOCKER_IMG):$(PRESTO_VERSION) -t $(DOCKER_IMG) .

# build a new Presto CLI image
build-cli:
	@$(ECHO) "$(C_GREEN)Building Presto CLI image with Presto CLI $(PRESTO_VERSION):$(C_STD)"
	@cd $(PRESTO_VERSION)/cli && docker build -t $(DOCKER_CLI_IMG):$(PRESTO_VERSION) -t $(DOCKER_CLI_IMG) .

# build a new Presto Server and CLI image
build: build-presto build-cli

# tag and push the new Presto Server images to Docker Registries
release-presto:
	@[[ $$(docker images $(DOCKER_IMG):$(PRESTO_VERSION) | wc -l | tr -d ' ') -gt 1 ]] 			|| $(MAKE) build-presto
	@$(ECHO) "$(C_GREEN)Login to Docker Repository:$(C_STD)"
	@docker login -u $(DOCKER_USER)
	@docker tag $(DOCKER_IMG):$(PRESTO_VERSION) $(DOCKER_USER)/$(DOCKER_IMG):$(PRESTO_VERSION)
	@docker tag $(DOCKER_IMG) $(DOCKER_USER)/$(DOCKER_IMG)
	@$(ECHO) "$(C_GREEN)Pushing the new Presto Server images (${PRESTO_VERSION} and latest):$(C_STD)"
	@docker push $(DOCKER_USER)/$(DOCKER_IMG)
	@docker push $(DOCKER_USER)/$(DOCKER_IMG):$(PRESTO_VERSION)

# tag and push the new Presto CLI images to Docker Registries
release-cli:
	@[[ $$(docker images $(DOCKER_CLI_IMG):$(PRESTO_VERSION) | wc -l | tr -d ' ') -gt 1 ]] 	|| $(MAKE) build-cli
	@$(ECHO) "$(C_GREEN)Login to Docker Repository:$(C_STD)"
	@docker login -u $(DOCKER_USER)
	@docker tag $(DOCKER_CLI_IMG):$(PRESTO_VERSION) $(DOCKER_USER)/$(DOCKER_CLI_IMG):$(PRESTO_VERSION)
	@docker tag $(DOCKER_CLI_IMG) $(DOCKER_USER)/$(DOCKER_CLI_IMG)
	@$(ECHO) "$(C_GREEN)Pushing the new Presto CLI images (${PRESTO_VERSION} and latest):$(C_STD)"
	@docker push $(DOCKER_USER)/$(DOCKER_CLI_IMG)
	@docker push $(DOCKER_USER)/$(DOCKER_CLI_IMG):$(PRESTO_VERSION)

# tag and push the new Presto Server and CLI images to Docker Registries
release: release-presto release-cli

# download the container from the Teradata Internal Docker Hub Registry
pull:
	@$(ECHO) "$(C_GREEN)Pulling the Presto images from Docker Hub Registry:$(C_STD)"
	@docker pull $(DOCKER_USER)/$(DOCKER_IMG)
	@docker pull $(DOCKER_USER)/$(DOCKER_CLI_IMG)

# remove all the containers created with the Presto image/service
clean:
	@$(ECHO) "$(C_GREEN)Remove all the Presto Docker containers:$(C_STD)"
	@docker rm $$(docker ps -qa --filter=ancestor=$(DOCKER_IMG)) 2>/dev/null  || true

# remove all containers and images created
clean-all: clean
	@$(ECHO) "$(C_GREEN)Remove all the Presto Docker containers and image:$(C_STD)"
	@docker rmi $(DOCKER_IMG):$(PRESTO_VERSION) 2>/dev/null || true
	@docker rmi $(DOCKER_IMG) 2>/dev/null || true
	@docker rmi $(DOCKER_USER)/$(DOCKER_IMG):$(PRESTO_VERSION) 2>/dev/null || true
	@docker rmi $(DOCKER_USER)/$(DOCKER_IMG) 2>/dev/null || true

# display all the containers created with the Presto image/service
ls-containers:
	@$(ECHO) "$(C_GREEN)Presto Docker containers:$(C_STD)"
	@docker ps -a --filter=ancestor=$(DOCKER_IMG)

# display all the images created and used by the Presto containers
ls-images:
	@$(ECHO) "$(C_GREEN)Presto Docker images:$(C_STD)"
	@docker images

# show all the images, containers created
ls: ls-containers ls-images

# presto-dashboard is to open a browser with the Presto Dashboard page. It will
# only work on Mac OS X
presto-dashboard:
	open "http://localhost:"`docker port $(DOCKER_NAME) 8080/tcp | cut -f2 -d:`

# login into the built container
sh: build-presto
	@$(ECHO) "$(C_GREEN)Login to the container:$(C_STD)"
	@if [[ $$(docker ps --filter=ancestor=$(DOCKER_IMG) | wc -l | tr -d ' ') -gt 1 ]]; \
		then docker exec -it $$(docker ps -q --filter=ancestor=$(DOCKER_IMG)) /bin/bash --login; \
		else $(DOCKER_RUN) /bin/sh --login; \
		fi

# open a console to the Presto CLI. Require the hostname or IP address of the
# Presto Coordinator with parameter 'H'. Optionaly can provide the Presto server
# Port with parameter 'P'
cli:
	@if [[ -z "$(H)" ]]; then echo "$(C_GREEN)Required the Presto coordinator hostname or IP address in 'H'$(C_STD). Example: make query H=coordinator Q='show catalogs;'" && exit 1; fi
	$(DOCKER_RUN_CLI) --server $(H):$(P)

# execute a query with the Presto CLI. Require the query in the parameter 'Q'
# and the hostname or IP address of the Presto Coordinator with parameter 'H'.
# Optionaly can provide the Presto server Port with parameter 'P'.
query:
	@if [[ -z "$(Q)" ]]; then echo "$(C_GREEN)Required a query in 'Q'$(C_STD). Example: make query Q='show catalogs;'" && exit 1; fi
	@if [[ -z "$(H)" ]]; then echo "$(C_GREEN)Required the Presto coordinator hostname or IP address in 'H'$(C_STD). Example: make query H=coordinator Q='show catalogs;'" && exit 1; fi
	$(DOCKER_RUN_CLI) --server $(H):$(P) --execute '$(Q)'

# query to Presto CLI the existing catalogs
query-catalogs:
	$(MAKE) query H=$(CLI_HOST) P=$(CLI_PORT) Q='show catalogs;'

# query to Presto CLI the existing Presto Workers
query-workers:
	$(MAKE) query H=$(CLI_HOST) P=$(CLI_PORT) Q='select * from system.runtime.nodes;'

GIT_REMOTE=github
# tag the git repository with the Presto version and push the change
git-tag:
	@git push $(GIT_REMOTE) :refs/tags/$(PRESTO_VERSION) && \
		git tag -fa $(PRESTO_VERSION) -m "Presto Version $(PRESTO_VERSION)" && \
		git push --tags $(GIT_REMOTE) master
	@$(ECHO) "$(C_GREEN)Available tags:$(C_STD)"
	@git tag | while read tag; do $(ECHO) "  $(C_GREEN)$(I_BULLET)$(C_STD) $${tag}" ; done
