#!/bin/bash
#
## Big Poppa Update Functions

source $PAPYRUS_ROOT/.helpers.d/colors.sh

function update_big_poppa # context organization/user id/githubid/name value
{
  local context entity field value url
  context=$1
  entity=$2
  field=$3
  value=$4
  update_field=$5
  update_value=$6

  # Display Query
  if [[ $field == "all" ]]; then
    echo "Searching for all ${cyan}${entity}s${reset} in ${cyan}${context}${reset}"
  else
    echo "Searching for ${cyan}${entity}${reset} where ${cyan}${field}${reset} is ${cyan}${value}${reset} in ${context}${reset}"
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

  # Set context
  if [[ $context == "delta" ]]; then
    context="kubernetes.runnable.com"
  elif [[ $context == "gamma" ]]; then
    context="kubernetes.runnable-gamma.com"
  fi

  # Build url
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

  current_context=$(kubectl config current-context)
  if [[ $context != $current_context ]]; then
    kubectl config use-context $context
  fi
  pod=$(kubectl get pods | grep big-poppa-http | grep Running | cut -f 1 -d' ' | head -1)
  output=$(kubectl exec -it $pod -- bash -c "curl -sS --request PATCH -H 'Content-Type: application/json' -d '$json' $url")
  if [[ $context != $current_context ]]; then
    kubectl config use-context $current_context
  fi

  # Pop used params from arguments array
  shift 6

  echo $output | papyrus::display_json $@
}

_bp_update_autocompletion()
{
  local cur contexts entity_type query_parameter reply
  cur="${COMP_WORDS[COMP_CWORD]}"

  contexts="$(kubectl config get-contexts -o name) delta gamma"
  entity_type="organization user"
  query_parameter="id"
  update_parameter="isActive firstDockCreated trialEnd activePeriodEnd stripeCustomerId stripeSubscriptionId metadata hasPaymentMethod isPermanentlyBanned"

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
    reply=$contexts
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
