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

function util::get_git_stats_for_repo # [Date 2016-08-26]
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

function util::biggest_loser # [Date 2016-08-26]
{
  util::for_each_repo "util::get_git_stats_for_repo $1" > /tmp/loserCache
  function getDeletesForName # [query]
  {
    cat /tmp/loserCache | grep del | grep -i "$1" | cut -d' ' -f 4 | paste -sd+ - | bc
  }

  echo "" > /tmp/loserResults
  echo Anand `getDeletesForName "anand"` >> /tmp/loserResults
  echo Anton `getDeletesForName "anton\|podviaznikov"` >> /tmp/loserResults
  echo Henry `getDeletesForName "henry"` >> /tmp/loserResults
  echo Ken `getDeletesForName "Ken\|kolofsen"` >> /tmp/loserResults
  echo Kahn `getDeletesForName "Myztiq\|Kahn"` >> /tmp/loserResults
  echo Nathan `getDeletesForName "Nathan219\|Nathan\|nate"` >> /tmp/loserResults
  echo Praful `getDeletesForName "praful"` >> /tmp/loserResults
  echo tony `getDeletesForName "runnabro\|tony"` >> /tmp/loserResults
  echo sundip `getDeletesForName "sundip"` >> /tmp/loserResults
  echo taylor `getDeletesForName "taylor"` >> /tmp/loserResults
  echo Jorge `getDeletesForName "thejsj\|Jorge"` >> /tmp/loserResults
  echo Sohail `getDeletesForName "tosih\|Sohail"` >> /tmp/loserResults
  echo Christopher `getDeletesForName "und1sk0\|Chris"` >> /tmp/loserResults
  echo Yash `getDeletesForName "ykumar\|yash"` >> /tmp/loserResults
  echo total `getDeletesForName "total"` >> /tmp/loserResults

  # cleanup private functions
  unset getDeletesForName

  # sort list and print
  cat /tmp/loserResults | sort -n -k 2
}
