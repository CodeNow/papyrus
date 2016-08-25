## Github Utility Functions

# Get a github organization/user by its ID
function github-get-by-id
{
	curl -s https://api.github.com/user/$1 | python -m json.tool
}

# Get a github user by its login/username
function github-get-by-username
{
	curl -s https://api.github.com/users/$1 | python -m json.tool
}

# Get a github organization by its login/username
function github-get-by-orgname
{
	curl -s https://api.github.com/orgs/$1 | python -m json.tool
}

# get github username from id
function un # id
{
  curl https://api.github.com/user/$1 | grep login
}
# get id from username
function uid # name
{
  curl https://api.github.com/users/$1 | grep id
}
