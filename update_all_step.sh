#!/bin/bash -x

log "STARTING update_all_step.sh"

command -v git &> /dev/null || $MMCI_PACKAGES_INSTALL git
command -v git &> /dev/null || fail "git not present (and cannot install it). Giving up"

# Make sure the mmtests-ci repo is always updated
log " Updating the mmtests-ci repository"
cd $MMCI_DIR || exit 255
git checkout main || exit 255 # FIXME: Handle failure better
git pull origin main # FIXME: Handle failure (at all!)

# Pull/Update MMTests
log " Cloning or updating MMTests"
if [ ! -d "$MMCI_MMTESTS_DIR" ]; then
	git clone --branch $MMCI_MMTESTS_BRANCH --single-branch $MMCI_MMTESTS_REPO "$MMCI_MMTESTS_DIR"
	if [ $? -ne 0 ]; then
		echo "ERROR: cannot clone MMTests locally"
		exit 255
	fi
else
	pushd "$MMCI_MMTESTS_DIR"
	git pull
	popd
fi

# Pull/Update any defined additional repository
for R in $MMCI_ADDITIONAL_GITREPOS_LIST ; do
	# TODO: We might want to support multiple branches too
	RURL=$(echo $R | awk -F '@' '{print $2}')
	RDIR=$"{DIR}/$(echo $R | awk -F '@' '{print $1}')"
	log " Cloning updating $RURL (into $RDIR)"
	# Check if we can actually reach it (otherwise, just skipt it)
	git -c http.sslVerify=false ls-remote "$RURL" &> /dev/null || continue
	if [[ -d $RDIR ]]; then
		pushd $RDIR
		git pull
		popd
	else
		git clone "$RURL" "$RDIR"
	fi
done

# TODO: Shall we update the OS here? Or just leave it to the testplan?

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
