#!/bin/bash
#
## Github Utility Functions

# Get a github organization/user by its ID
function github::get_by_id
{
	local id=$1
	shift 1
	curl -sS "https://api.github.com/user/$id" | jq $@
}

# Get a github user by its login/username
function github::get_by_username
{
	local username=$1
	shift 1
	curl -sS "https://api.github.com/users/$username" | papyrus::display_json $@
}

# Get a github organization by its login/username
function github::get_by_orgname
{
	local orgname=$1
	shift 1
	curl -sS "https://api.github.com/orgs/$orgname" | papyrus::display_json $@
}
