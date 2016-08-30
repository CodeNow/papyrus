#!/bin/bash
#
# Ansible

function setupRabbit # host
{
  ssh -NL 8080:localhost:54320 "$1" &
}

alias setupRabbitGamma='setup setupRabbit gamma-rabbit'
alias setupRabbitDelta='setup setupRabbit delta-rabbit'
alias setupRabbitEpsilon='setup setupRabbit epsilon-rabbit'
alias setupRabbitStaging='setup setupRabbit delta-staging-data'

function setupConsul # <ip> <host>
{
  echo tunneling ssh -NL 58500:"$1":8500 "$2"
  ssh -NL 58500:"$1":8500 "$2" &
}

alias setupConsulGamma='setup setupConsul "$(ssh gamma-consul-a hostname -i)" gamma-consul-a'
alias setupConsulDelta='setup setupConsul "$(ssh delta-consul-a hostname -i)" delta-consul-a'
alias setupConsulEpsilon='setup setupConsul "$(ssh epsilon-consul-a hostname -i)" epsilon-consul-a'
alias setupConsulStaging='setup setupConsul "$(ssh delta-staging-data hostname -i)" delta-staging-data'

function dockCommand # <host> <command>
{
  ANSIBLE_HOST_PATH="$1-hosts"
  ANSIBLE_DOCK_COMMAND=$2
  shift 2
  echo ansible -i "$ANSIBLE_ROOT/$ANSIBLE_HOST_PATH" docks -m shell -a "$ANSIBLE_DOCK_COMMAND" "$@"
  ansible -i "$ANSIBLE_ROOT/$ANSIBLE_HOST_PATH" docks -m shell -a "$ANSIBLE_DOCK_COMMAND" "$@"
}

for tenv in $ENVS; do
  alias ${tenv}DockCommand="dockCommand $tenv"
done

# deploy passed tag
# if no tag passed use latest tag
function deploy # <env> <app> <tag> [...extra]
{
  local tenv="${1}-hosts"
  local repo="${2}"
  local tag="${3}"

  local deployFile="${ANSIBLE_ROOT}/${repo}.yml"
  local repo_folder="${RUN_ROOT}/${repo}"
  shift 2

  if [[ "${repo}" = "web" ]]; then
    repo_folder="${RUN_ROOT}/runnable-angular"
  fi

  if [[ "${tag}" = "" ]]; then
    echo "no tag passed, looking for latest commit"
    tag=`git -C "${repo_folder}" describe --abbrev=0 --tags master`
  else
    shift 1
  fi

  echo ansible-playbook -i "${ANSIBLE_ROOT}/${tenv}" --vault-password-file ~/.vaultpass -e git_branch="${tag}" "${deployFile}" -t deploy "${@}"
  ansible-playbook -i "${ANSIBLE_ROOT}/${tenv}" --vault-password-file ~/.vaultpass -e git_branch="${tag}" "${deployFile}" -t deploy "${@}"
}

_deploy()
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

  local repos=`ls -d ${RUN_ROOT}/*/ | sed -e "s%${RUN_ROOT}/%%g" -e "s%/%%g"`
  if [[ "${repos}" == *"${prev}"* ]]; then
    local branches=$(git --git-dir="$RUN_ROOT/$prev/.git" for-each-ref --format='%(refname:short)' refs/heads)
    COMPREPLY=( $(compgen -W "${branches}" -- ${cur}) )
    return 0
  fi
}
complete -F _deploy deploy

for tenv in $ENVS; do
  alias ${tenv}Deploy="deploy $tenv"
  complete -F _deploy ${tenv}Deploy
done
