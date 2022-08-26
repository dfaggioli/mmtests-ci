#!/bin/bash -x

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"

. "${MMCI_DIR}/common.sh"

log "STARTING $(realpath $0)"

# Here we want to tweak GRUB (or whatever) to make sure that we will boot in
# the "next" OS that we want to test on this host (if any, of course)!
#
# E.g., we can use olh-autoinst, to change partition!
#
# The update_all_step.sh script will be run again, on this OS, when
# we will be back here. E.g., after someone of the other partition does
# an olh-autoinst-set-default to us.

sleep 30

log "DONE $(realpath $0)"

cp -a "${MMCI_DIR}/update_all_step.sh" "${DIR}/mmci_next_step.sh"
reboot

exit 0