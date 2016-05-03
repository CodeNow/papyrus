# secrets

# extra autocomplete
. $HOME/.bash_completion.d/*

#RUNABLE VARS
export NODE_ENV=development
export NODE_PATH=./lib
export CN=2335750
export PATH="$PATH:./node_modules/.bin:/usr/local/sbin"
# kube
export PATH="$PATH:$HOME/.profile"
export PATH="$PATH:$HOME/run/devops-scripts/kubernetes/platforms/darwin/amd64/"

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
alias startMR="redis-server&mongod&neo4j start&rabbitmq-server&"
alias stopMR='redis-cli shutdown&mongo --eval "db.getSiblingDB(\"admin\").shutdownServer()"&neo4j stop&rabbitmqctl stop_app&'
alias unsetDocker='unset `env | grep DOCKER | cut -d'=' -f 1 | xargs`'
#CD
export RUN_ROOT=$HOME/run
export REPO_BASE=$RUN_ROOT
export RUN_TMP=$RUN_ROOT/.tmp

alias cdr='cd $RUN_ROOT'
alias cdo='cd $RUN_ROOT/other'
alias cddw='cd $RUN_ROOT/dockworker'
alias cddl='cd $RUN_ROOT/docklet'
alias cdfd='cd $RUN_ROOT/frontdoor'
alias cdapi='cd $RUN_ROOT/api'
alias cdapis='cd $RUN_ROOT/api-server'
alias cdweb='cd $RUN_ROOT/runnable-web'
alias cdh='cd $RUN_ROOT/harbourmaster'
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

alias createDock='docker-machine create --driver virtualbox'
function setupDock # dock name
{
  eval "$(docker-machine env $1)"
}
alias setupDocker='VBoxManage discardstate dev && eval "$(docker-machine env dev)"'
alias setupMesos='source ~/dcos/bin/env-setup'
alias dm='docker-machine'

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


#RUNNABLE
function PushB #<Branch> <target>
{
  fab $2 branch:$1 deploy
}

alias CCPushM='PushB master integration'
alias R3PushM='PushB master runnable3'
alias PWPushM='PushB master staging'

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
#XXX TODO expand for all servers
#ALPHA
function prodMavisAddDock # <dock> <org>
{
  echo   curl -X PUT "http://mavis.runnable.io/docks?host=http://$1:4242&tags=$2"
  curl -X PUT "http://mavis.runnable.io/docks?host=http://$1:4242&tags=$2"
}

function prodMavisSetValue # <dock> <key> <value>
{
  curl -X POST "http://mavis.runnable.io/docks?host=$1&key=$2&value=$3"
}

function stageMavisSetValue # <dock> <key> <value>
{
  curl -X POST "http://mavis-staging-codenow.runnableapp.com/docks?host=$1&key=$2&value=$3"
}

function prodSetNumBuilds # <dockIp> <value>
{
  prodMavisSetValue $1 numBuilds $2
}

function prodSetNumContainers # <dockIp> <value>
{
  prodMavisSetValue $1 numContainers $2
}
function prodRmDock # <dock rul>
{
  echo   curl -X DELETE mavis.runnable.io/docks?host="http://$1:4242"
  curl -X DELETE mavis.runnable.io/docks?host="http://$1:4242"
}
function prodGetDocs # <dock rul>
{
  curl mavis.runnable.io/docks | json_pp
}

# DB
function flushall
{
  mongo --quiet --eval 'db.getMongo().getDBNames().forEach(function(i){db.getSiblingDB(i).dropDatabase()})'
  redis-cli flushall
  rabbitmqctl stop; rabbitmqctl force_reset; rabbitmqctl start_app
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
#RANDOM DOCKER COMMANDS
#alias killAllDocker="sudo docker kill `sudo docker ps | awk '{print $1}'`"
#alias stopDockerService="sudo service docker stop"
#alias createDockerBuildEnv=""
#alias compileDocker="sudo docker run -lxc-conf=lxc.aa_profile=unconfined -privileged -v `pwd`:/go/src/github.com/dotcloud/docker docker-0.6.3 hack/make.sh binary"
#alias rmAllContainers="docker rm `docker ps -notrunc -a -q`"
#alias stopRunningContainers="docker stop `docker ps -notrunc -q`"
# alias mountRun3='sshfs ubuntu@runnable3.net:/home/ubuntu ~/run3'
#alias getAttachedDocklets='redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1'
#alias rmAttachedDocklet='ssh ubuntu@redis "redis-cli -h 10.0.1.20 lrem frontend:docklet.runnable.com 1 http://10.0.2.234:4244"'

# sublime
export SUBL_SNIPPIT_PATH='$HOME/Library/Application Support/Sublime Text 3/Packages/User/'

## TEMP
alias start_services='echo "started session" >> /Volumes/track_projectx.file && ssh -N -f -M -S /Volumes/socketprojectx -L 27017:localhost:27017  -L 6379:localhost:6379 -L 5672:localhost:5672 -L 7474:localhost:7474 ubuntu@projectx'
alias kill_services='ssh -S /Volumes/socketprojectx -O exit projectx'
alias restart_services='curl projectx:1337/restartservices'

alias listOpenPorts='sudo lsof -i -P | grep -i "listen"'

function rollDocks # new_ami target_env
{
  local ami="${1}"
  local target_env="${2}"
  echo docks aws list -e $target_env \| grep large \| grep -v $ami \| sort -u -n -k 4 \| awk '{print $6}' \| xargs -I % bash -c "echo y|docks unhealthy % -e $target_env"
  docks aws list -e $target_env | grep large | grep -v $ami | sort -u -n -k 4 | awk '{print $6}' | xargs -I % bash -c "echo y|docks unhealthy % -e $target_env"
}
