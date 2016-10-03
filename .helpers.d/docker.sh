#!/bin/bash
#
# DOCKER

export DOCKER_HOST=tcp://localhost:52375
export DOCKER_CERT_PATH=$RUN_ROOT/devops-scripts/ansible/roles/docker_client/files/certs/swarm-manager
export DOCKER_TLS_VERIFY=1

# DOCKER FOR MAC
alias unsetDocker='unset `env | grep DOCKER | cut -d'=' -f 1 | xargs`'
alias startDbs="unsetDocker; docker run -d -p 6379:6379 --name=redis redis:3.0;\
  docker run -d -p 27017:27017 --name=mongo -v /tmp:/data mongo:3.0 mongod --smallfiles;\
  docker run -d -p 5432:5432 --name=postgres postgres:9.5.4;\
  docker run -d -p 15672:15672 -p 5672:5672 --name=rabbit rabbitmq:3-management;"
alias stopDbs='unsetDocker; docker kill redis postgres mongo rabbit; docker rm redis postgres mongo rabbit'
alias dbs='stopDbs || startDbs'

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
