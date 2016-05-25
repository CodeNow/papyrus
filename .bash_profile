# secrets

# extra autocomplete
. $HOME/.bash_completion.d/*
source $HOME/.envs

#RUNABLE VARS
export NODE_ENV=development
export NODE_PATH=./lib
export CN=2335750
export PATH="$PATH:./node_modules/.bin:/usr/local/sbin"

export DOCKER_HOST=tcp://localhost:52375
export DOCKER_CERT_PATH=$HOME/run/devops-scripts/ansible/roles/docker_client/files/certs/swarm-manager
export DOCKER_TLS_VERIFY=1

#MYVARS
MODE_PATH=~/.colorMode
PS1="\W$ "

export EDITOR=subl
alias of='open .'
export ENVS='delta gamma epsilon stage'

# AWS
export AWS_DEFAULT_REGION='us-west-2'

#NODE
alias i="npm install"
alias t="npm test"
alias s="npm start"
alias it="i&&t"
alias its="i&&t&&s"
# DOCKER FOR MAC
alias unsetDocker='unset `env | grep DOCKER | cut -d'=' -f 1 | xargs`'
alias startDbs="unsetDocker; docker run -d -p 6379:6379 --name=redis redis:3.0;\
  docker run -d -p 27017:27017 --name=mongo mongo:3.0;\
  docker run -d -p 7474:7474 -e NEO4J_AUTH=none --name=neo4j neo4j:2.3;\
  docker run -d -p 15672:15672 -p 5672:5672 --name=rabbit rabbitmq:3-management;"
alias stopDbs='unsetDocker; docker kill redis mongo neo4j rabbit; docker rm redis mongo neo4j rabbit'
alias restartDbs='stopDbs || startDbs'

#CD
export RUN_TMP=$RUN_ROOT/.tmp

alias cdr='cd $RUN_ROOT'
alias cdo='cd $RUN_ROOT/other'
alias cdapi='cd $RUN_ROOT/api'
alias sb='source ~/.bash_profile'
alias v='subl'
alias b='v ~/.bash_profile'
alias ossh='v $RUN_ROOT/devops-scripts/ssh/config'
alias cda='cd $RUN_ROOT/devops-scripts/ansible'
alias inpm='sudo npm install -g npm@2.8.3'

function c # folder in runnable
{
  cd $RUN_ROOT/$1
}
_c () {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$(ls $RUN_ROOT)" -- $cur) )
}
complete -o default -F _c c

#ANSIBLE
export ANSIBLE_HOST_KEY_CHECKING=False
export DEVOPS_SCRIPTS_PATH=$HOME/run/devops-scripts
export ANSIBLE_ROOT=$DEVOPS_SCRIPTS_PATH/ansible
export RETRY_FILES_SAVE_PATH=$ANSIBLE_ROOT

#GIT
alias submit='git push '
alias tags='submit && submit --tags'
alias gca='git commit -am '
alias gc='git commit -m '
alias gs='git status'
alias gd='git diff'
alias gp='git pull '
alias gb='git branch'
__git_complete gb _git_branch
alias gmm='git merge master '
alias diffs='git difftool --staged'
alias diffc='git difftool HEAD^ HEAD'
alias gbrm='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

# Docker
alias d='echo y|docks'
function dp # docks args
{
  echo docks $* -e delta
  d $* -e delta
}
function ds # docks args
{
  echo docks $* -e staging
  d $* -e staging
}
function de # docks args
{
  echo docks $* -e epsilon
  d $* -e epsilon
}

function setup # <func> <func_args>
{
  local NAME=$1
  kill $(cat $RUN_TMP/$NAME.pid) || echo "no prev session"
  echo "running: $*"
  $*
  PID="$!"
  echo $PID > $RUN_TMP/$NAME.pid
}

function setupSwarm # host
{
  export DOCKER_HOST=tcp://localhost:52375
  ssh -NL 52375:localhost:2375 "$1" &
}

alias setupSwarmGamma='setup setupSwarm gamma-dock-services'
alias setupSwarmDelta='setup setupSwarm delta-swarm-manager'
alias setupSwarmEpsilon='setup setupSwarm epsilon-dock-services'

function setupSwarmStaging # host
{
  export DOCKER_HOST=tcp://swarm-staging-codenow.runnableapp.com:2375
  export DOCKER_TLS_VERIFY=1
}

function swarmListOrg # orgId
{
  echo docker info 2>&1| grep -B5 "org=$1"
  docker info 2>&1| grep -B5 "org=$1"
}

function swarmImageBuilder
{
  echo 'docker ps -a | grep image-build | cut -f 1 -d' ' | xargs docker rm'
  docker ps -a | grep image-build | cut -f 1 -d' ' | xargs docker rm
}

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

function gbc #[branch]
{
  if [[ $# -ne 1 ]]; then
      echo "need to pick branch"
      gb
  else
    git checkout $1
  fi

}
__git_complete gbc _git_branch

function newb #branch_to_create
{
   gbc master
   gp
   gb $1
   gbc $1
   git push --set-upstream origin $1
}

function gm2m
{
  gbc master
  gp
  git merge $1
}
function gu
{
  gbc master
  gp
  gbc $1
  gm
}
function gbd #delete branch from server and here
{
  gbc master
  git push origin --delete $1
  gb -d $1
}

function gbs #send branch to server
{
  git push origin $1
}
alias gpatch='gbc master && gp && npm version patch'
alias gminor='gbc master && gp && npm version minor'
alias gmajor='gbc master && gp && npm version major'

#SEARCHING
alias search='find . | grep -i --color=auto '
alias sh='search '
alias fs='find . -type f | grep -i --color=auto '

function gh
{
    echo grep -n --color=auto -r "$1" .
    grep -n --color=auto  -r "$1" .
}
function gg
{
    echo git grep -n --color=auto -r "$1" .
    git grep -n --color=auto "$1" .
}

function vv
{
    CNT=`fs $1 | wc -l`
    if [[ $CNT -eq 1 ]]; then
      v `fs $1`
    else
        echo "more/less then 1 file $CNT"
    fi
}

# ANSIBLE

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

function deploy # <env> <app> <tag> [...extra]
{
  local tenv="${1}-hosts"
  local repo="${ANSIBLE_ROOT}/${2}.yml"
  local tag="${3}"
  if [[ "${repo}" = "web" ]]; then
    repo_folder="${RUN_ROOT}/runnable-angular"
  fi
  shift 3
  echo ansible-playbook -i "${ANSIBLE_ROOT}/${tenv}" --vault-password-file ~/.vaultpass -e stop_time=5 -e git_branch="${tag}" "${repo}" -t deploy "$@"
  ansible-playbook -i "${ANSIBLE_ROOT}/${tenv}" --vault-password-file ~/.vaultpass -e stop_time=5 -e git_branch="${tag}" "${repo}" -t deploy "$@"

}

function gdeploy # <env> <repo> [...extra]
{
  local tenv="${1}"
  local repo="${2}"
  local repo_folder="${RUN_ROOT}/${repo}"
  if [[ "$2" = "web" ]]; then
    repo_folder="${RUN_ROOT}/runnable-angular"
  fi
  shift 2
  echo deploy "${tenv}" "${repo}" `git -C "${repo_folder}" describe --abbrev=0 --tags master` "$@"
  deploy "${tenv}" "${repo}" `git -C "${repo_folder}" describe --abbrev=0 --tags master` "$@"
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
  upper="$(tr '[:lower:]' '[:upper:]' <<< ${tenv:0:1})${tenv:1}"
  alias ${upper}Deploy="deploy $tenv"
  alias ${tenv}Deploy="gdeploy $tenv"
  complete -F _deploy ${tenv}Deploy
  complete -F _deploy ${upper}Deploy
done

function fcmd
{
  grep --color=auto $1 ~/.bash_profile
}

#SERVER MANAGMENT
alias rmssh='rm $HOME/.ssh/known_hosts'
function ss #server
{
  echo ssh ubuntu@$1
  ssh ubuntu@$1
}

# AUTO COMPLETE
_ssh()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config | awk '{print $2}')

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh

# sublime
export SUBL_SNIPPIT_PATH='$HOME/Library/Application Support/Sublime Text 3/Packages/User/'


alias listOpenPorts='sudo lsof -i -P | grep -i "listen"'

# function rollDocks # new_ami target_env
# {
#   local ami="${1}"
#   local target_env="${2}"
#   echo docks aws list -e $target_env \| grep large \| grep -v $ami \| sort -u -n -k 4 \| awk '{print $6}' \| xargs -I % bash -c "echo y|docks unhealthy % -e $target_env"
#   docks aws list -e $target_env | grep large | grep -v $ami | sort -u -n -k 4 | awk '{print $6}' | xargs -I % bash -c "echo y|docks unhealthy % -e $target_env"
# }
