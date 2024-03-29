# Papyrus

Profiles for terminal sessions for runn-a-devs.

## Setup
source `.bash_profile` file from your `~/.bash_profile`

## Bash utilities

### `big_poppa`

Big-poppa querying straight from the command line.

Examples:

```bash
big_poppa gamma organization id 1 # Find org with BP id 1
big_poppa delta user githubId 1981198 # Find user with github id 1981198
big_poppa gamma user name thejsj
big_poppa gamma user all # Find all users in gamma
```

## Tool Overrides

Only use tool overrides when viewing or manipulating final outputs. Overriding functions that
manipulate data and pass to other functions is forbidden.

#### `display_json`

This script will alias `papyrus::display_json` to use `python -m json.tool` by default.
If you would like to use another tool, you can set it in your .bash_profile before sourcing this repo.

Example:

```bash
# ~/.bash_profile or ~/.zshrc
function papyrus::display_json 
{
  jq $@
}

source $RUN_ROOT/papyrus/.bash_profile
```
