#!/bin/bash
#
## Big Poppa Update Functions

source $PAPYRUS_ROOT/.helpers.d/colors.sh

function update_big_poppa # environment organization/user id/githubid/name value
{
  local environment entity field value host url
  environment=$1
  entity=$2
  field=$3
  value=$4
  update_field=$5
  update_value=$6

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
    host="delta-app-services-2"
  else
    host="${environment}-app-services"
  fi
  url="0.0.0.0:7788/${entity}"

  if [[ $field == "id" ]]; then
    url="${url}/${value}/"
  else
    echo "Only parameter supported for updates is 'id'"
    return false
  fi

  if [[ $update_value == "true" ]] || [[ $update_value == "false" ]] || [[ $update_value == "True" ]] || [[ $update_value == "False" ]]; then
    update_value=$update_value
  else
    update_value="'$update_value'"
  fi

  json_string="{ '$update_field': $update_value }"
  json=$(python -c "import json; print json.dumps($json_string)")
  echo "Updates: $json"

  pod=$(kubectl get pods | grep big-poppa-http | grep Running | cut -f 1 -d' ')
  kubectl exec -it $pod -- bash -c "curl -sS --request PATCH -H 'Content-Type: application/json' -d '$json' $url" | jq
}

_bp_update_autocompletion()
{
  local cur environments entity_type query_parameter reply
  cur="${COMP_WORDS[COMP_CWORD]}"

  environments="${ENVS}"
  entity_type="organization user"
  query_parameter="id"
  update_parameter="isActive firstDockCreated trialEnd activePeriodEnd stripeCustomerId stripeSubscriptionId metadata hasPaymentMethod isPermanentlyBanned"

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
    reply=$environments
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
    reply=$entity_type
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
    reply=$query_parameter
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
    reply=$update_parameter
  fi
  COMPREPLY=( $(compgen -W "${reply}" -- ${cur}) )
}
complete -F _bp_update_autocompletion update_big_poppa
