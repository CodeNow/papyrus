#!/bin/bash
#
## Github Utility Functions

# Get a github organization/user by its ID
function github::get_by_id
{
	curl -sS "https://api.github.com/user/$1" | json
}

# Get a github user by its login/username
function github::get_by_username
{
	curl -sS "https://api.github.com/users/$1" | json
}

# Get a github organization by its login/username
function github::get_by_orgname
{
	curl -sS "https://api.github.com/orgs/$1" | json
}
