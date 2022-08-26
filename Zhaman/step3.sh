#!/bin/bash -x

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"

. "${MMCI_DIR}/common.sh"

log "STARTING $(realpath $0)"
sleep 300
log "DONE $(realpath $0)"

# XXX For now, we know we are the last one
cp ${MMCI_DIR}/reboot_to_next_os_step.sh ${DIR}/mmci_next_step.sh
reboot

exit 0
