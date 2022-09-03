#!/bin/bash -x
#
# XXX
#
# Usage is:

log "STARTING tests/multi-vms.sh (args: $@)"

#XXX
# XXX for baremetal run, e.g. "baremetal@-"
export HOST_CONFIGS="
2vm4vcpu4ram@/config-2vm-4vcpu-4ram
"

# XXX
export TESTS="
stream-default@config
"

${MMCI_DIR}/tests/mmtests.sh $@

log "DONE multi-vms.sh"
exit 0
