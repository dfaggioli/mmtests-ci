#!/bin/bash -x
#
# XXX
#
# Usage is:

log "STARTING tests/baremetal.sh (args: $@)"

#XXX
# XXX for baremetal run, e.g. "baremetal@-"
export HOST_CONFIGS="
baremetal@-
"

# XXX
export TESTS="
stream-default@config
"

${MMCI_DIR}/tests/mmtests.sh $@

log "DONE baremetal.sh"
exit 0
