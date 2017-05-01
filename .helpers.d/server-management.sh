#!/bin/bash
#
# Server Management

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

function portForward # <service_name> <local_port:remote_port>
{
  kubectl port-forward `kubectl get pods | grep $1 | awk '{print $1}'` $2
}

function setupSwarm # <host>
{
  export DOCKER_HOST=tcp://localhost:52375
  tunnel 52375 "$1" 2375
}

function portForwardSwarm
{
  portForward swarm 52375:2375 &>/dev/null &disown
}

alias setupSwarmGamma='setup portForwardSwarm'
alias setupSwarmDelta='setup setupSwarm delta-swarm-manager'

function setupSwarmStaging
{
  export DOCKER_HOST=tcp://swarm-staging-codenow.runnableapp.com:2375
}

function setupRabbit # <host>
{
  tunnel 8080 "$1" 54320
}

function portForwardRabbit
{
  portForward rabbitmq 8080:15672 &>/dev/null &disown
}

alias setupRabbitGamma='setup portForwardRabbit'
alias setupRabbitDelta='setup setupRabbit delta-rabbit'

function setupConsul # <host>
{
  tunnel 58500 "$1" 8500
}

alias setupConsulGamma='setup setupConsul gamma-consul-a'
alias setupConsulDelta='setup setupConsul delta-consul-a'
alias setupConsulStaging='setup setupConsul delta-staging-data'

function setupPrometheus # <host>
{
  tunnel 9090 "$1" 9090
}


function setupPrometheusAlert # <host>
{
  tunnel 9093 "$1" 9093
}

function setupGrafana # <host>
{
  tunnel 9089 "$1" 9089
}

alias setupPromGamma='setup setupPrometheus gamma-dock-services; setup setupPrometheusAlert gamma-dock-services; setup setupGrafana gamma-dock-services'
alias setupPromDelta='setup setupPrometheus delta-prometheus; setup setupPrometheusAlert delta-prometheus; setup setupGrafana delta-prometheus'

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
