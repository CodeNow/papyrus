#!/bin/bash
#
# Kubernetes Management

function k8::set_context # <env>
{
  if [[ $1 == "delta" ]]; then
    k8::set_context_delta
  elif [[ $1 == "gamma" ]]; then
    k8::set_context_gamma
  else
    echo env:$1 is not valid exist!
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

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
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
