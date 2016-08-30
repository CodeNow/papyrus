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
