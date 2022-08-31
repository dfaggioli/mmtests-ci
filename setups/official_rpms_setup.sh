#!/bin/bash -x

log "STARTING official_rpms_setup.sh (args: $@)"

set_default_repos
update_OS

sleep 60

log "DONE official_rpms_setup.sh"

exit 0
