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

function k8::set_context_gamma
{
  export KOPS_STATE_STORE=s3://runnable-gamma-kubernetes-config
  export CLUSTER_NAME=kubernetes.runnable-gamma.com
  export VPC_ID=vpc-c53464a0
  kubectl config use-context $CLUSTER_NAME
}

function k8::set_context_delta
{
  export KOPS_STATE_STORE=s3://runnable-delta-kubernetes-config
  export CLUSTER_NAME=kubernetes.runnable.com
  export VPC_ID=vpc-864c6be3
  kubectl config use-context $CLUSTER_NAME
}

function k8::list_all_pods # <service_name>
{
  kubectl get pods | grep -v NAME | grep "$1-[0-9]"
}

function k8::get_all_pods # <service_name>
{
  k8::list_all_pods $1 | cut -f 1 -d' '
}

function k8::get_running_pods # <service_name>
{
  k8::list_all_pods $1 | grep Running | cut -f 1 -d' '
}

function k8::get_one_pod # <service_name>
{
  k8::list_all_pods $1 | head -n1 | cut -f 1 -d' '
}

function k8::get_one_running_pod # <service_name>
{
  k8::list_all_pods $1 | grep Running | head -n1 | cut -f 1 -d' '
}

function k8::delete_pods
{
  PODS=`k8::get_all_pods $1`
  echo kubectl delete pod $PODS
  kubectl delete pod $PODS
}

function k8::pod_logs # <service_name> [tail]
{
  TAIL=${2:-10}
  echo k8::get_all_pods $1 \| xargs -n1 -P 100 kubectl logs -f --tail=$TAIL
  k8::get_all_pods $1 | xargs -n1 -P 100 kubectl logs -f --tail=$TAIL
}

function k8::exec_pod # <service_name>
{
  POD=`k8::get_one_pod $1`
  echo kubectl exec -it $POD bash
  kubectl exec -it $POD bash
}

function k8::port_forward # <service_name> <local_port:remote_port>
{
  POD=`k8::get_one_pod $1`
  echo kubectl port-forward $POD $2 \&\>/dev/null \&disown
  kubectl port-forward $POD $2 &>/dev/null &disown
}

_services()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts=`ls $ANSIBLE_ROOT/*yml | sed -e "s%$ANSIBLE_ROOT/%%g" -e "s/.yml//g"`

  if [[ ${COMP_CWORD} -eq 1 ]] ; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  fi
}
complete -F _services k8::list_all_pods
complete -F _services k8::get_all_pods
complete -F _services k8::get_running_pods
complete -F _services k8::get_one_running_pod
complete -F _services k8::get_one_pod
complete -F _services k8::delete_pods
complete -F _services k8::pod_logs
complete -F _services k8::exec_pod
complete -F _services k8::port_forward

function k8::apply # <env> <service> [type] [file]
{
  env=$1
  service=$2
  type=${3:='*'}
  file=${4:='*'}

  k8::set_context $env
  cd $ANSIBLE_ROOT/k8/$env/$service
  ls ./$type/$file | xargs -n1 echo kubectl apply -f
  ls ./$type/$file | xargs -n1 kubectl apply -f
  k8::set_prev_context
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
