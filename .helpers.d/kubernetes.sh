#!/bin/bash
#
# Kubernetes Management

function setKubectlForEnv # <env>
{
  if [[ $1 == "delta" ]]; then
    deltaKubectl
  elif [[ $1 == "gamma" ]]; then
    gammaKubectl
  else
    echo env:$1 is not valid exist!
    return
  fi
}

function gammaKubectl
{
  export KOPS_STATE_STORE=s3://runnable-gamma-kubernetes-config
  export CLUSTER_NAME=kubernetes.runnable-gamma.com
  export VPC_ID=vpc-c53464a0
  kubectl config use-context kubernetes.runnable-gamma.com
}

function deltaKubectl
{
  export KOPS_STATE_STORE=s3://runnable-delta-kubernetes-config
  export CLUSTER_NAME=kubernetes.runnable.com
  export VPC_ID=vpc-864c6be3
  kubectl config use-context kubernetes.runnable.com
}

function listAllPods # <service_name>
{
  kubectl get pods | grep -v NAME | grep "$1-[0-9]"
}

function getAllPods # <service_name>
{
  listAllPods $1 | cut -f 1 -d' '
}

function getRunningPod # <service_name>
{
  listAllPods $1 | grep Running | cut -f 1 -d' '
}

function getFirstPod # <service_name>
{
  listAllPods $1 | head -n1 | cut -f 1 -d' '
}

function getFirstRunningPod # <service_name>
{
  listAllPods $1 | grep Running | head -n1 | cut -f 1 -d' '
}

function deletePod
{
  PODS=`getAllPods $1`
  echo kubectl delete pod $PODS
  kubectl delete pod $PODS
}

function logsPod # <service_name> [tail]
{
  TAIL=${2:-10}
  echo getAllPods $1 \| xargs -n1 -P 100 kubectl logs -f --tail=$TAIL
  getAllPods $1 | xargs -n1 -P 100 kubectl logs -f --tail=$TAIL
}

function execPod # <service_name>
{
  POD=`getFirstPod $1`
  echo kubectl exec -it $POD bash
  kubectl exec -it $POD bash
}

function portForwardPod # <service_name> <local_port:remote_port>
{
  POD=`getFirstPod $1`
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
complete -F _services listAllPods
complete -F _services getAllPods
complete -F _services getRunningPod
complete -F _services getFirstRunningPod
complete -F _services getFirstPod
complete -F _services deletePod
complete -F _services logsPod
complete -F _services execPod
complete -F _services portForwardPod
