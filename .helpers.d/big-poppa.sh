#!/bin/bash
#
## Big Poppa Utility Functions

source $PAPYRUS_ROOT/.helpers.d/colors.sh

function big_poppa # environment organization/user id/githubid/name value
{
  local environment entity field value host url
  local environment=$1
  entity=$2
  field=$3
  value=$4

  # Display Query
  if [[ $field == "all" ]]; then
    echo "Searching for all ${cyan}${entity}s${reset} in ${cyan}${environment}${reset}"
  else
    echo "Searching for ${cyan}${entity}${reset} where ${cyan}${field}${reset} is ${cyan}${value}${reset} in ${environment}${reset}"
  fi

  # If querying by name
  if [[ $field == "name" ]]; then
    value=$(echo $value | awk '{print tolower($0)}')
    field="lowerName"
  fi
  if [[ $field == "lowerName" ]] && [[ $entity == "user" ]]; then
    value=$(github::get_by_username $value | python -c 'import sys, json; print json.load(sys.stdin)["id"]')
    field="githubId"
  fi

  # Build url
  host="${environment}-app-services"
  url="0.0.0.0:7788/${entity}"

  if [[ $field == "all" ]]; then
    url="${url}" # Do nothing
  elif [[ $field == "id" ]]; then
    url="${url}/${value}/"
  else
    url="${url}/?${field}=${value}"
  fi

  ssh $host curl -sS $url | json
}

_bp_autocompletion()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts1="${ENVS}"
  opts2="organization user"
  opts3="id githubId name username all"

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
    COMPREPLY=( $(compgen -W "${opts1}" -- ${cur}) )
    return 0
  fi
  if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
    COMPREPLY=( $(compgen -W "${opts2}" -- ${cur}) )
    return 0
  fi
  if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
    COMPREPLY=( $(compgen -W "${opts3}" -- ${cur}) )
    return 0
  fi
}
complete -F _bp_autocompletion big_poppa

# Get a Big Poppa org by its id
function bp::org_get_by_id
{
  ssh delta-app-services curl -sS "0.0.0.0:7788/organization/$1" | json
}

# Get a Big Poppa user by its id
function bp::user_get_by_id
{
  ssh delta-app-services curl -sS "0.0.0.0:7788/user/$1" | json
}

# Get a Big Poppa organization by its Github id
function bp::org_get_by_github_id
{
  ssh delta-app-services curl -sS "0.0.0.0:7788/organization/?githubId=$1" | json
}

# Get a Big Poppa user by its Github id
function bp::user_get_by_github_id
{
  ssh delta-app-services curl -sS "0.0.0.0:7788/user/?githubId=$1" | json
}

# Get a Big Poppa organization by its Github login
function bp::org_get_by_name
{
  lower_name=$(echo $1 | awk '{print tolower($0)}')
  ssh delta-app-services curl -sS "0.0.0.0:7788/organization/?lowerName=$lower_name" | json
}

# Get a Big Poppa user by its Github login
function bp::user_get_by_name
{
  lower_name=$(echo $1 | awk '{print tolower($0)}')
  # BP has no knowledge of Github login, so we have to query this from GH
  github_id=$(github_get_by_username $lower_name | python -c 'import sys, json; print json.load(sys.stdin)["id"]')
  ssh delta-app-services curl -sS "0.0.0.0:7788/user/?githubId=$github_id" | json
}
