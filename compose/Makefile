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

PRESTO_VERSION 	?= $(shell grep ^PRESTO_VERSION ../Makefile | cut -f2 -d= | tr -d ' ')
DOCKER_CLI_NAME ?= $(shell grep ^DOCKER_CLI_NAME ../Makefile | cut -f2 -d= | tr -d ' ')

CLI_HOST 			 ?= $(H)
ifeq ($(CLI_HOST),)
CLI_HOST 			 := coordinator
endif

CLI_PORT 			 ?= $(P)
ifeq ($(CLI_PORT),)
CLI_PORT 			 := 8080
endif


DOCKER_RUN_CLI := docker-compose run --name $(DOCKER_CLI_NAME) --rm cli --server $(CLI_HOST):$(CLI_PORT)

# Constants (You would not want to modify them):
## -----------------------------------------------------------------------------

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

# presto-dashboard is to open a browser with the Presto Dashboard page. It will
# only work on Mac OS X
presto-dashboard:
	open "http://localhost:"`docker port coordinator 8080/tcp | cut -f2 -d:`

# open a console to the Presto CLI. Require the hostname or IP address of the
# Presto Coordinator with parameter 'H'. Optionaly can provide the Presto server
# Port with parameter 'P'
cli:
	$(DOCKER_RUN_CLI)

# execute a query with the Presto CLI. Require the query in the parameter 'Q'
# and the hostname or IP address of the Presto Coordinator with parameter 'H'.
# Optionaly can provide the Presto server Port with parameter 'P'.
query:
	@if [[ -z "$(Q)" ]]; then echo "$(C_GREEN)Required a query in 'Q'$(C_STD). Example: make query Q='show catalogs;'" && exit 1; fi
	@$(DOCKER_RUN_CLI) --execute '$(Q)'

# query to Presto CLI the existing catalogs
query-catalogs:
	@$(MAKE) query H=$(CLI_HOST) P=$(CLI_PORT) Q='show catalogs;'

# query to Presto CLI the existing Presto Workers
query-workers:
	@$(MAKE) query H=$(CLI_HOST) P=$(CLI_PORT) Q='select * from system.runtime.nodes;'
