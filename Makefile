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


# Constants (You would not want to modify them):
## -----------------------------------------------------------------------------

VERSION 			= $(shell grep Version Dockerfile | cut -f2 -d= | tr -d '"')

# Docker:
DOCKER_IMG   := presto
DOCKER_NAME  := presto
DOCKER_BASE  := $(shell grep 'FROM ' Dockerfile | cut -f2 -d' ' | tr -d ' ')

DOCKER_ENV    =
DOCKER_VOL		=
DOCKER_RUN 	  = docker run $(DOCKER_VOL) $(DOCKER_ENV) --name $(DOCKER_NAME) --rm
DOCKER_RUN_IT = $(DOCKER_RUN) -it $(DOCKER_IMG)

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
all: build clean

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

# build the container
build:
	@if [[ -z "$$(docker images -q $(DOCKER_IMG))" ]]; then docker build -t $(DOCKER_IMG) .; fi

# build the container even if exists an image
re-build:
	docker build -t $(DOCKER_IMG) .

# login into the container
login: build
	@$(ECHO) "$(C_GREEN)Login to the container:$(C_STD)"
	@if [[ $$(docker ps --filter=ancestor=$(DOCKER_IMG) | wc -l | tr -d ' ') -gt 1 ]]; \
		then docker exec -it $$(docker ps -q --filter=ancestor=$(DOCKER_IMG)) /bin/bash --login; \
		else $(DOCKER_RUN_IT) /bin/sh --login; \
		fi

# remove all the containers created with the Presto image/service
clean:
	@$(ECHO) "$(C_GREEN)Remove all the Presto Docker container:$(C_STD)"
	@docker rm $$(docker ps -qa --filter=ancestor=$(DOCKER_IMG)) 2>/dev/null  || true

# remove all containers and images created
clean-all: clean
	@$(ECHO) "$(C_GREEN)Remove all the Presto Docker container:$(C_STD)"
	@docker rmi $(DOCKER_IMG) 2>/dev/null || true
	@docker rmi $(DOCKER_BASE) 2>/dev/null || true

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
	open "http://localhost:"`docker port coordinator 8080/tcp | cut -f2 -d:`
