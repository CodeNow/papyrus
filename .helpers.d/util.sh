#!/bin/bash
#
# Utilities

function c # folder in runnable
{
  cd $RUN_ROOT/$1
}

_c () {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$(ls $RUN_ROOT)" -- $cur) )
}
complete -o default -F _c c


function util::for_each_repo # [action_to_preform]
{
  for I in `ls -d $RUN_ROOT/*/`; do
    if [ ! -d "$I/.git" ]; then
      continue
    fi
    pushd $I > /dev/null
    echo "--- running $1 in $I ---"
    $1
    popd > /dev/null
  done

}

function util::grep_all_repos
{
  util::for_each_repo "git grep -n --color=auto ${@}"
}

function util::pull_all_repos
{
  util::for_each_repo "git pull"
}

function util::get_git_stats_for_repo # [Date 2016-08-26] [year-month-day]
{
  git log origin/master --numstat --since=$1 | awk '
  function printStats(author) {
     printf "results: %s: del: %d add: %d\n", author, less[author], more[author]
  }

  /^Author:/ {
     author           = $2
     commits[author] += 1
     commits["total"]  += 1
  }

  /^[0-9]/ {
     more[author] += $1
     less[author] += $2
     file[author] += 1

     more["total"]  += $1
     less["total"]  += $2
     file["total"]  += 1
  }

  END {
     for (author in commits) {
        if (author != "total") {
           printStats(author)
        }
     }
     printStats("total")
  }'
}
# format: [Name]:[alias1,alias2] [Name]:[alias1,alias2]
# Name is what shows up in output
# alias are names that show up in git history
# each group must be seperated by atleast one space for parsing to work
export RUNAWORKERS="
  Anand:anand,Anand
  Anton:anton,podviaznikov,Anton
  Damien:damien,Damien,damien,damienrunnable
  Henry:henrymollman,Henry
  Jorge:thejsj,Jorge,jorge
  Kahn:Myztiq,Kahn,kahn
  Ken:Ken,kolofsen,ken
  Nathan:Nathan219,Nathan,nate,nathan
  Praful:praful,Praful
  Sohail:tosih,Sohail,sohail
  Sundip:sundip,Sundip
  Taylor:taylor,Taylor
  Tony:runnabro,tony,tli415,Tony
  Yash:ykumar,yash,Yash
  total:total
"

function util::_biggest # <date> <ITEM>
{
  ITEM="$2"
  util::for_each_repo "util::get_git_stats_for_repo $1" > /tmp/loserCache

  echo "" > /tmp/loserResults
  for worker in $RUNAWORKERS; do
    NAME="${worker%%:*}"
    ALIAS_CSV="${worker##*:}"
    ALIAS_PIPED="${ALIAS_CSV//,/\\|}"
    echo "${NAME}" `cat /tmp/loserCache | grep del | grep "$ALIAS_PIPED" | cut -d' ' -f "$ITEM" | paste -sd+ - | bc` >> /tmp/loserResults
  done

  # sort list and print
  cat /tmp/loserResults | sort -n -k 2
}

function util::biggest_loser # [Date 2016-08-26]
{
  util::_biggest "$1" 4
}

function util::biggest_gain # [Date 2016-08-26]
{
  util::_biggest "$1" 6
}
