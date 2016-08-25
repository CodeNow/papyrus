## Big Poppa Utility Functions

# Get a Big Poppa org by its id
function bp_org_get_by_id
{
	ssh delta-app-services curl 0.0.0.0:7788/organization/$1 | python -m json.tool
}

# Get a Big Poppa user by its id
function bp_user_get_by_id
{
	ssh delta-app-services curl 0.0.0.0:7788/user/$1 | python -m json.tool
}

# Get a Big Poppa organization by its Github id
function bp_org_get_by_github_id
{
	ssh delta-app-services curl 0.0.0.0:7788/organization/?githubId=$1 | python -m json.tool
}

# Get a Big Poppa user by its Github id
function bp_user_get_by_github_id
{
	ssh delta-app-services curl 0.0.0.0:7788/user/?githubId=$1 | python -m json.tool
}

# Get a Big Poppa organization by its Github login
function bp_org_get_by_name
{
	lower_name=$(echo $1 | awk '{print tolower($0)}')
	ssh delta-app-services curl 0.0.0.0:7788/organization/?lowerName=$lower_name | python -m json.tool
}

# Get a Big Poppa user by its Github login
function bp_user_get_by_name
{
	lower_name=$(echo $1 | awk '{print tolower($0)}')
	# BP has no knowledge of Github login, so we have to query this from GH
	github_id=$(github_get_by_username $lower_name | python -c 'import sys, json; print json.load(sys.stdin)["id"]')
	ssh delta-app-services curl 0.0.0.0:7788/user/?githubId=$github_id | python -m json.tool
}
