#!/bin/bash -x

#[ -z "$DIR" ] && export DIR="/root"
#[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
#export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"
#. "${MMCI_DIR}/common.sh"

log "STARTING update_all_step.sh"

# Make sure the repo is always updated
cd $MMCI_DIR || exit 255
git checkout main || exit 255 # FIXME: Handle failure better
git pull origin main # FIXME: Handle failure (at all!)

# TODO: Update the OS?

log "DONE update_all_step.sh"

# Start host-specific tests, if any
if [ ! -d "$MMCI_HOSTDIR" ] || [ ! -f "${MMCI_HOSTDIR}/testplan" ]; then
	log "WARNING: No tests for this host? Moving forward..."
	exec "${MMCI_DIR}/reboot_to_next_os_step.sh"
fi

rm -f ${MMCI_HOSTDIR}/testplan.step # Just in case...
cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
reboot
exit 0
