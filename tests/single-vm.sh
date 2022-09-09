#!/bin/bash
#
# XXX
#
# Usage is:

log "STARTING tests/single-vms.sh (args: $@)"

# TODO: For now, just name one that we're fairly sure it will be among
#       the ones that are auto-generated. In reallity, we want to pick
#       a meaningful subset, maybe depending on the host characteristics,
#       and/or maybe even using special/handcrafted ones (after having
#       copied them in place)
export HOST_CONFIGS="
1vm1vcpus4ram@config-1vm-1vcpu-4ram
1vm8vcpus10ram/config-1vm-8vcpu-10ram
"

# TODO: See above (HOST_CONFIGS)
export TESTS="
stream-default@config
"

${MMCI_DIR}/mmtests.sh $@

log "DONE single-vms.sh"
exit 0
