#!/bin/bash
#
## Big Poppa Utility Functions

source $PAPYRUS_ROOT/.helpers.d/colors.sh

function big_poppa # context organization/user id/githubid/name value
{
  local context entity field value url
  local context=$1
  entity=$2
  field=$3
  value=$4

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

  if [[ $field == "all" ]]; then
    url="${url}" # Do nothing
  elif [[ $field == "id" ]]; then
    url="${url}/${value}/"
  else
    url="${url}/?${field}=${value}"
  fi
  echo "$url"

  # Pop used params from arguments array
  shift 4

  current_context=$(kubectl config current-context)
  if [[ $context != $current_context ]]; then
    kubectl config use-context $context
  fi
  pod=$(kubectl get pods | grep big-poppa-http | grep Running | cut -f 1 -d' ' | head -1)
  output=$(kubectl exec -it $pod -- bash -c "curl -sS $url")
  if [[ $context != $current_context ]]; then
    kubectl config use-context $current_context
  fi
  echo $output | papyrus::display_json $@
}

_bp_autocompletion()
{
  local cur contexts entity_type query_parameter reply
  cur="${COMP_WORDS[COMP_CWORD]}"

  contexts="$(kubectl config get-contexts -o name) delta gamma"
  entity_type="organization user"
  query_parameter="id githubId name username stripeCustomerId all"

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
    reply=$contexts
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
    reply=$entity_type
  elif [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
    reply=$query_parameter
  fi
  COMPREPLY=( $(compgen -W "${reply}" -- ${cur}) )
}
complete -F _bp_autocompletion big_poppa

