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

function setupRabbit # host
{
  ssh -NL 8080:localhost:54320 "$1" &
}

alias setupRabbitGamma='setup setupRabbit gamma-rabbit'
alias setupRabbitDelta='setup setupRabbit delta-rabbit'
alias setupRabbitEpsilon='setup setupRabbit epsilon-rabbit'
alias setupRabbitStaging='setup setupRabbit delta-staging-data'

function setupConsul # <ip> <host>
{
  echo tunneling ssh -NL 58500:"$1":8500 "$2"
  ssh -NL 58500:"$1":8500 "$2" &
}

alias setupConsulGamma='setup setupConsul "$(ssh gamma-consul-a hostname -i)" gamma-consul-a'
alias setupConsulDelta='setup setupConsul "$(ssh delta-consul-a hostname -i)" delta-consul-a'
alias setupConsulEpsilon='setup setupConsul "$(ssh epsilon-consul-a hostname -i)" epsilon-consul-a'
alias setupConsulStaging='setup setupConsul "$(ssh delta-staging-data hostname -i)" delta-staging-data'

function setupMetabase
{
  echo ssh -NL 8989:localhost:4444 delta-app-services
  ssh -NL 8989:localhost:4444 delta-app-services &
}

alias setupMetabaseDelta='setup setupMetabase'

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
# function rollDocks # new_ami target_env
# {
#   local ami="${1}"
#   local target_env="${2}"
#   echo docks aws list -e $target_env \| grep large \| grep -v $ami \| sort -u -n -k 4 \| awk '{print $6}' \| xargs -I % bash -c "echo y|docks unhealthy % -e $target_env"
#   docks aws list -e $target_env | grep large | grep -v $ami | sort -u -n -k 4 | awk '{print $6}' | xargs -I % bash -c "echo y|docks unhealthy % -e $target_env"
# }
