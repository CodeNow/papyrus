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
  if [[ $environment == "delta" ]]; then
    host="${environment}-app-services-2"
  else
    host="${environment}-app-services"
  fi
  url="0.0.0.0:7788/${entity}"

  if [[ $field == "all" ]]; then
    url="${url}" # Do nothing
  elif [[ $field == "id" ]]; then
    url="${url}/${value}/"
  else
    url="${url}/?${field}=${value}"
  fi

  # Pop used params from arguments array
  shift 4

  ssh $host curl -sS $url | papyrus::display_json $@
}

_bp_autocompletion()
{
  local cur environments entity_type query_parameter reply
  cur="${COMP_WORDS[COMP_CWORD]}"

  environments="${ENVS}"
  entity_type="organization user"
  query_parameter="id githubId name username stripeCustomerId all"

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
    reply=$environments
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
    reply=$entity_type
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
    reply=$query_parameter
  fi
  COMPREPLY=( $(compgen -W "${reply}" -- ${cur}) )
}
complete -F _bp_autocompletion big_poppa

