#!/bin/bash
#
# DOCKER

export DOCKER_HOST=tcp://localhost:52375
export DOCKER_CERT_PATH=$RUN_ROOT/devops-scripts/ansible/roles/docker_client/files/certs/swarm-manager
export DOCKER_TLS_VERIFY=1

# DOCKER FOR MAC
alias unsetDocker='unset `env | grep DOCKER | cut -d'=' -f 1 | xargs`'
alias startDbs="unsetDocker; docker run -d -p 6379:6379 --name=redis redis:3.0;\
  docker run -d -p 27017:27017 --name=mongo mongo:3.0;\
  docker run -d -p 15672:15672 -p 5672:5672 --name=rabbit rabbitmq:3-management;"
alias stopDbs='unsetDocker; docker kill redis mongo rabbit; docker rm redis mongo rabbit'
alias restartDbs='stopDbs || startDbs'

function setup # <func> <func_args>
{
  local NAME=$1
  kill $(cat $RUN_TMP/$NAME.pid) || echo "no prev session"
  echo "running: $*"
  $*
  PID="$!"
  echo $PID > $RUN_TMP/$NAME.pid
}

function setupSwarm # host
{
  export DOCKER_HOST=tcp://localhost:52375
  ssh -NL 52375:localhost:2375 "$1" &
}

alias setupSwarmGamma='setup setupSwarm gamma-dock-services'
alias setupSwarmDelta='setup setupSwarm delta-swarm-manager'
alias setupSwarmEpsilon='setup setupSwarm epsilon-dock-services'

function setupSwarmStaging # host
{
  export DOCKER_HOST=tcp://swarm-staging-codenow.runnableapp.com:2375
  export DOCKER_TLS_VERIFY=1
}

function swarmListOrg # orgId
{
  echo docker info 2>&1| grep -B5 "org=$1"
  docker info 2>&1| grep -B5 "org=$1"
}

function swarmImageBuilder
{
  echo 'docker ps -a | grep image-build | cut -f 1 -d' ' | xargs docker rm'
  docker ps -a | grep image-build | cut -f 1 -d' ' | xargs docker rm
}
