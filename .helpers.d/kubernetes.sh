#!/bin/bash
#
# Kubernetes Management

function k8::set_context # <env>
{
  export PREV_ENV=`k8::get_current_env`
  if [[ $1 == "delta" ]]; then
    k8::set_context_delta
  elif [[ $1 == "gamma" ]]; then
    k8::set_context_gamma
  else
    echo env:$1 is not valid exist!
    return
  fi
}

function k8::set_prev_context
{
  k8::set_context $PREV_ENV
}

function k8::get_current_env
{
  current_env=`kubectl config current-context`
  if [[ $current_env == "kubernetes.runnable.com" ]]; then
    echo "delta"
  elif [[ $current_env == "kubernetes.runnable-gamma.com" ]]; then
    echo "gamma"
  else
    echo env:$current_env is not valid exist!
    return
  fi
}

function k8::env_to_context # <env>
{
  if [[ $1 == "delta" ]]; then
    echo "kubernetes.runnable.com"
  elif [[ $1 == "gamma" ]]; then
    echo "kubernetes.runnable-gamma.com"
  else
    echo $1
  fi
}

function  k8 # <env> ...
{
  local context=`k8::env_to_context $1`
  shift
  echo kubectl --context \"${context}\" \"$*\"
  kubectl --context "${context}" $*
}

export -f k8

function k8::set_context_gamma
{
  export KOPS_STATE_STORE=s3://runnable-gamma-kubernetes-config
  export CLUSTER_NAME=kubernetes.runnable-gamma.com
  export VPC_ID=vpc-c53464a0
}

function k8::set_context_delta
{
  export KOPS_STATE_STORE=s3://runnable-delta-kubernetes-config
  export CLUSTER_NAME=kubernetes.runnable.com
  export VPC_ID=vpc-864c6be3
}

function k8::list_all_pods # <env> <service_name>
{
  k8 $1 get pods | grep -v NAME | grep "$2-[0-9]"
}

function k8::get_all_pods # <env> <service_name>
{
  k8::list_all_pods $1 $2 | cut -f 1 -d' '
}

function k8::get_running_pods # <env> <service_name>
{
  k8::list_all_pods $1 $2 | grep Running | cut -f 1 -d' '
}

function k8::get_one_pod # <env> <service_name>
{
  k8::list_all_pods $1 $2 | head -n1 | cut -f 1 -d' '
}

function k8::get_one_running_pod # <env> <service_name>
{
  k8::list_all_pods $1 $2 | grep Running | head -n1 | cut -f 1 -d' '
}

function k8::delete_pods # <env> <service_name>
{
  PODS=`k8::get_all_pods $1 $2`
  echo k8 $1 delete pod $PODS
  k8 $1 delete pod $PODS
}

function k8::logs # <env> <service_name> [tail]
{
  TAIL=${3:-10}
  echo k8::get_all_pods $1 $2 \| xargs -n1 -I % -P 100 bash -login -c \"k8 $1 logs -f --tail=$TAIL %\"
  k8::get_all_pods $1 $2 | xargs -n1 -I % -P 100 bash -login -c "k8 $1 logs -f --tail=$TAIL %"
}

function k8::exec # <env> <service_name>
{
  POD=`k8::get_one_pod $1 $2`
  echo k8 $1 exec -it $POD bash
  k8 $1 exec -it $POD bash
}

function k8::exec_command # <env> <service_name> <command>
{
  POD=`k8::get_one_running_pod $1 $2`
  local context=`k8::env_to_context $1`
  kubectl --context "${context}" exec $POD -- bash -login -c "${3}"
}

function k8::port_forward # <env> <service_name> <local_port:remote_port>
{
  POD=`k8::get_one_pod $1 $2`
  echo k8 $1 port-forward $POD $3 \&\>/dev/null \&disown
  k8 $1 port-forward $POD $3 &>/dev/null &disown
}

_services()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ ${COMP_CWORD} -eq 1 ]] ; then
    COMPREPLY=( $(compgen -W "${ENVS}" -- ${cur}) )
  fi

  if [[ ${COMP_CWORD} -eq 2 ]] ; then
    opts=`ls $ANSIBLE_ROOT/*yml | sed -e "s%$ANSIBLE_ROOT/%%g" -e "s/.yml//g"`
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  fi
}

complete -F _services k8::list_all_pods
complete -F _services k8::get_all_pods
complete -F _services k8::get_running_pods
complete -F _services k8::get_one_running_pod
complete -F _services k8::get_one_pod
complete -F _services k8::delete_pods
complete -F _services k8::logs
complete -F _services k8::exec
complete -F _services k8::port_forward

function k8::apply # <env> <service> [type] [file]
{
  env=$1
  service=$2
  type=${3:-'*'}
  file=${4:-'*'}

  cd $ANSIBLE_ROOT/k8/$env/$service
  ls ./$type/$file | xargs -n1 echo k8 $env apply -f
  ls ./$type/$file | xargs -n1 k8 $env apply -f
}

_apply()
{
  local cur reply
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # env
  if [[ ${COMP_CWORD} -eq 1 ]] ; then
    reply=$ENVS
  fi

  # service
  if [[ ${COMP_CWORD} -eq 2 ]] ; then
    reply=`ls $ANSIBLE_ROOT/*yml | sed -e "s%$ANSIBLE_ROOT/%%g" -e "s/.yml//g"`
  fi

  # type
  if [[ ${COMP_CWORD} -eq 3 ]] ; then
    env="${COMP_WORDS[COMP_CWORD-2]}"
    service="${COMP_WORDS[COMP_CWORD-1]}"

    reply=`ls $ANSIBLE_ROOT/k8/$env/$service`
  fi

  if [[ ${COMP_CWORD} -eq 4 ]] ; then
    env="${COMP_WORDS[COMP_CWORD-3]}"
    service="${COMP_WORDS[COMP_CWORD-2]}"
    type="${COMP_WORDS[COMP_CWORD-1]}"

    reply=`ls $ANSIBLE_ROOT/k8/$env/$service/$type`
  fi

  COMPREPLY=( $(compgen -W "${reply}" -- ${cur}) )
}

complete -F _apply k8::apply
