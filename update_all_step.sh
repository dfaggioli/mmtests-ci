#!/bin/bash -x

log "STARTING update_all_step.sh"

# Make sure the mmtests-ci repo is always updated
log " Updating the mmtests-ci repository"
cd $MMCI_DIR || exit 255
git checkout main || exit 255 # FIXME: Handle failure better
git pull origin main # FIXME: Handle failure (at all!)

# Pull/Update MMTests
log " Pulling or updating MMTests itself"
if [ ! -d "$MMCI_MMTESTS_DIR" ]; then
	git clone --branch $MMCI_MMTESTS_BRANCH --single-branch $MMCI_MMTESTS_REPO "$MMCI_MMTESTS_DIR"
	if [ $? -ne 0 ]; then
		echo "ERROR: cannot clone MMTests locally"
		exit 255
	fi
else
	pushd "$MMCI_MMTESTS_DIR"
	git pull
	./bin/generate-generic-configs
	./bin/generate-nas.sh
	./bin/generate-fs-configs
	popd
fi

# Update the OS, hopefully in the proper way
log " Updating the OS"
# If PackageKit is there (which hopefully isn't the case) get rid of it
# TODO: Find a better way to do this!
systemctl disable --now packagekit
killall -9 packagekitd
$MMCI_PACKAGES_REFRESH || exit 255
$MMCI_PACKAGES_UPDATE || exit 255

log "DONE update_all_step.sh"

# Start host-specific tests, if any
if [ ! -d "$MMCI_HOSTDIR" ] || [ ! -f "${MMCI_HOSTDIR}/testplan" ]; then
	log "WARNING: No tests for this host? Moving forward..."
	${MMCI_DIR}/reboot_to_next_os_step.sh
	exit $?
fi

rm -f ${MMCI_HOSTDIR}/testplan.step # Just in case...
cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
reboot
exit 0
