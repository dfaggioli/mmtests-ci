#!/bin/bash -x
#
# XXX
#
# Usage is:

log "STARTING tests/multi-vms.sh (args: $@)"

# TODO: For now, just name one that we're fairly sure it will be among
#       the ones that are auto-generated. In reallity, we want to pick
#       a meaningful subset, maybe depending on the host characteristics,
#       and/or maybe even using special/handcrafted ones (after having
#       copied them in place)
export HOST_CONFIGS="
2vms4vcpus4ram@config-2vm-4vcpu-4ram
8vms8vcpus24ram@config-8vm-8vcpu-24ram
"

# TODO: See above (HOST_CONFIGS)
export TESTS="
stream-default@config
"

${MMCI_DIR}/mmtests.sh $@

log "DONE multi-vms.sh"
exit 0
