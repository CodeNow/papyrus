#!/bin/bash
#
# Papyrus

if [ -z ${RUN_ROOT+x} ]; then
  export RUN_ROOT=$HOME/run
fi

if [ -z ${PAPYRUS_ROOT+x} ]; then
  export PAPYRUS_ROOT=$RUN_ROOT/papyrus
fi

# extra autocomplete
. $PAPYRUS_ROOT/.bash_completion.d/*

# private ENV's like AWS keys
if [ -f $PAPYRUS_ROOT/.envs ]; then
  source $PAPYRUS_ROOT/.envs
fi

# add personal shortcuts
if [ -f $PAPYRUS_ROOT/.shortkeys ]; then
  source $PAPYRUS_ROOT/.shortkeys
fi

# Papyrus constants
# Variables used throughout Papyrus to setup functionality
export DEVOPS_SCRIPTS_PATH=$RUN_ROOT/devops-scripts
export ANSIBLE_ROOT=$DEVOPS_SCRIPTS_PATH/ansible
export RETRY_FILES_SAVE_PATH=$ANSIBLE_ROOT
export RUN_TMP=$RUN_ROOT/.tmp

export PATH="$PATH:./node_modules/.bin:/usr/local/sbin"
export ENVS='delta gamma epsilon stage'

# Imports
source $PAPYRUS_ROOT/.helpers.d/github.sh
source $PAPYRUS_ROOT/.helpers.d/big-poppa.sh
source $PAPYRUS_ROOT/.helpers.d/ansible.sh
source $PAPYRUS_ROOT/.helpers.d/server-management.sh
source $PAPYRUS_ROOT/.helpers.d/docker.sh

# Runnable Vars
# Variables that should be used by every Runnable developer
export NODE_ENV=development
export NODE_PATH=./lib
export ANSIBLE_HOST_KEY_CHECKING=False

# Global Convenience Variables
# Variables that are not required, but useful to have declared
export AWS_DEFAULT_REGION='us-west-2' # AWS
export CN=2335750 # CodeNow Github ID
