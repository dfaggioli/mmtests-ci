#!/bin/bash
#
# Setup the repositories and (optionally) updates the OS.
#
# The '--update' parameter is optional. If present, we try to update/upgrade
# the OS, after having configured the repositories. If it's there, it must
# come before the list of repo aliases, URLs, etc.
#
# In fact, as last parameters, one or more repositories can be specified.
# They can be just repo-aliases, as they're defined in the per-distro
# repo "array", at the beginning of common.sh.
#
# Or they could be URLs of the "repo specification", i.e., something like
# repo-alias@http://repo.url/, or even just URLs (in this case, the alias will
# be chosen randombly.#
#
# Usage is: setup-repos.sh [--test TESTNAME] [--update] [repo1] [repo2] ...

log "STARTING setup-repos.sh (args: $@)"

# Parse arguments. It's not very sophisticated; we know that we'll get only
# '--test TESTNAME' or '--update', so we look for them. As soon as we find
# and argument that does not start with '--', we assume that that's the
# start of the list of repo names.
while [[ "$1" =~ --.* ]]; do
	if [[ "$1" == "--test" ]]; then
		TESTNAME=$2
		shift 2
	elif [[ "$1" == "--update" ]]; then
		UPDATE_OS="yes"
		shift
	fi
done

add_repos $@
[[ "$UPDATE_OS" ]] && update_OS

log "DONE setup-repos.sh"
exit 0
