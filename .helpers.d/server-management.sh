#!/bin/bash
#
# Server Management

source $PAPYRUS_ROOT/.helpers.d/kubernetes.sh

function setup # <func> <func_args>
{
  local NAME=$1
  kill $(cat $RUN_TMP/$NAME.pid) || echo "no prev session"
  echo "running: $*"
  $*
  PID="$!"
  echo $PID > $RUN_TMP/$NAME.pid
}

function tunnel # <local_port> <remote_host> <remote_port>
{
  local localPort="$1"
  local remoteHost="$2"
  local remotePort="$3"
  local remoteHostName=$(ssh $remoteHost hostname -i)
  echo ssh -NL $localPort:$remoteHostName:$remotePort $remoteHost
  ssh -NL $localPort:$remoteHostName:$remotePort $remoteHost &
}

function portForwardSwarm # <env>
{
  export DOCKER_HOST=tcp://localhost:52375
  export DOCKER_CERT_PATH=$RUN_ROOT/devops-scripts/ansible/roles/docker_client/files/certs/swarm-manager
  export DOCKER_TLS_VERIFY=1
  k8::port_forward $1 swarm-manager 52375:2375
}

alias setupSwarmGamma='setup portForwardSwarm gamma'
alias setupSwarmDelta='setup portForwardSwarm delta'

function setupRabbit # <host>
{
  tunnel 8080 "$1" 54320
}

function portForwardRabbit # <env>
{
  k8::port_forward $1 rabbitmq 8080:15672
}

alias setupRabbitGamma='setup portForwardRabbit gamma'
alias setupRabbitDelta='setup setupRabbit delta-rabbit'

function setupConsul # <host>
{
  tunnel 58500 "$1" 8500
}

alias setupConsulGamma='setup setupConsul gamma-consul-a'
alias setupConsulDelta='setup setupConsul delta-consul-a'
alias setupConsulStaging='setup setupConsul delta-staging-data'

function setupPrometheus # <env>
{
  k8::port_forward $1 prometheus 9090:9090
}

function setupPrometheusAlert # <env>
{
  k8::port_forward $1 prometheus-alerts 9093:9093
}

function setupGrafana # <env>
{
  k8::port_forward $1 prometheus-alerts 9089:9089
}

alias setupPromGamma='setup setupPrometheus gamma && setup setupPrometheusAlert gamma && setup setupGrafana gamma'
alias setupPromDelta='setup setupPrometheus delta && setup setupPrometheusAlert delta && setup setupGrafana delta'

alias setupMetabase='setup tunnel 8989 delta-metabase 4444'

function dockCommand # <host> <command>
{
  ANSIBLE_HOST_PATH="$1-hosts"
  ANSIBLE_DOCK_COMMAND=$2
  shift 2
  echo ansible -i "$ANSIBLE_ROOT/$ANSIBLE_HOST_PATH" docks -m shell -a "$ANSIBLE_DOCK_COMMAND" "$@"
  ansible -i "$ANSIBLE_ROOT/$ANSIBLE_HOST_PATH" docks -m shell -a "$ANSIBLE_DOCK_COMMAND" "$@"
}

for tenv in $ENVS; do
  alias ${tenv}DockCommand="dockCommand $tenv"
done

alias rmssh='rm $PAPYRUS_ROOT/.ssh/known_hosts'
function ss #server
{
  echo ssh ubuntu@$1
  ssh ubuntu@$1
}

# AUTO COMPLETE
_ssh()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config | awk '{print $2}')

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh

alias listOpenPorts='sudo lsof -i -P | grep -i "listen"'

function cleanGhosts
{
  setupSwarmDelta
  cd $ANSIBLE_ROOT
  local password=`gg api_mongo_auth | grep delta | sed s/.*api://`
  echo MONGO_AUTH=api:${password} docks ghost -e delta | grep Created  | awk '{ print $2 }' | xargs docker rm
  MONGO_AUTH=api:${password} docks ghost -e delta | grep Created | awk '{ print $2 }' | xargs docker rm
}
