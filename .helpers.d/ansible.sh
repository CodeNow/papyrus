#!/bin/bash
#
# Ansible

# converts names like web to runnable-angular
function getRepoFromName # <repo_name>
{
  local repo="$1"
  if [[ "${repo}" = "web" ]]; then
    repo="runnable-angular"
  fi

  if [[ "${repo}" = "shiva" ]]; then
    repo="astral"
  fi

  if [[ "${repo}" = "swarm-cloudwatch-reporter" ]]; then
    repo="furry-cactus"
  fi

  if [[ "${repo}" = "api-core" ]]; then
    repo="api"
  fi

  if [[ "${repo}" = "socket-server" ]]; then
    repo="api"
  fi

  if [[ "${repo}" = "workers" ]]; then
    repo="api"
  fi

  if [[ "${repo}" = "cream-http" ]]; then
    repo="cream"
  fi

  if [[ "${repo}" = "cream-worker" ]]; then
    repo="cream"
  fi

  echo $repo
}

# deploy passed tag
# if no tag passed use latest tag
function deploy # <env> <app> <tag> [...extra]
{
  local env="${1}"
  local target_env="${1}-hosts"
  local repo="${2}"
  local tag="${3}"

  local deploy_file="${ANSIBLE_ROOT}/${repo}.yml"
  local repo_name=`getRepoFromName ${repo}`
  shift 2

  if [[ "${tag}" = "" || "${tag}" = "latest" ]]; then
    if [[ "${tag}" = "latest" ]]; then
      shift 1
    fi
    echo "no tag passed, looking for latest commit"
    tag=`util::get_latest_tag ${repo_name}`
  else
    shift 1
  fi

  echo ansible-playbook -i "${ANSIBLE_ROOT}/${target_env}" --vault-password-file ~/.vaultpass -e git_branch="${tag}" "${deploy_file}" "${@}"

  if [[ "$env" = "delta" ]]; then
    echo ensure we have latest

    devops_branch=`git rev-parse --abbrev-ref HEAD`
    if [[ "$devops_branch" != "master" ]]; then
      echo ERROR: you can only deploy to prod on master NOT $devops_branch
      return
    fi
    git pull
  fi

  ansible-playbook -i "${ANSIBLE_ROOT}/${target_env}" --vault-password-file ~/.vaultpass -e git_branch="${tag}" "${deploy_file}" "${@}"
  k8::set_context $env
  echo -------------------
  echo -------------------
  echo -------------------
  echo apply changes to k8
  echo -------------------
  echo -------------------
  echo -------------------
  echo
  git ls-files -m | xargs -n1 echo kubectl apply -f
  echo ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
  # add weird repos
  repos="$repos shiva web swarm-cloudwatch-reporter"

  if [[ "${repos}" == *"${prev}"* ]]; then
    local repo_name=`getRepoFromName "${prev}"`
    local branches=$(git --git-dir="$RUN_ROOT/$repo_name/.git" for-each-ref --format='%(refname:short)' refs/heads)
    COMPREPLY=( $(compgen -W "${branches}" -- ${cur}) )
    return 0
  fi
}
complete -F _deploy deploy

for target_env in $ENVS; do
  alias ${target_env}Deploy="deploy $target_env"
  complete -F _deploy ${target_env}Deploy
done
