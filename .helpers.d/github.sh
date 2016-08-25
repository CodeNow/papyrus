## Github Utility Functions

# Get a github organization/user by its ID
function github::get_by_id
{
	curl -s https://api.github.com/user/$1 | python -m json.tool
}

# Get a github user by its login/username
function github::get_by_username
{
	curl -s https://api.github.com/users/$1 | python -m json.tool
}

# Get a github organization by its login/username
function github::get_by_orgname
{
	curl -s https://api.github.com/orgs/$1 | python -m json.tool
}
