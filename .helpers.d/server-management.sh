#!/bin/bash
#
# Server Management

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
