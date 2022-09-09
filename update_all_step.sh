#!/bin/bash
#
# TODO: Add some words for explaining what this script is for and does.

log "STARTING update_all_step.sh"

# Make sure the mmtests-ci repo is always updated
log "Updating the mmtests-ci repository"
cd $MMCI_DIR || fail "Cannot enter mmtests-ci main dir ($MMCI_DIR)"
git remote update && git checkout "$MMCI_GIT_BRANCH" && git pull
if [[ $? -ne 0 ]]; then
	log "******************************* W A R N I N G ******************************"
	log "CANNOT UPDATE mmtests-ci FROM GIT. RUNNING WITH POTENTIALLY OUTDATED RECIPES"
fi

# Fetch or update MMTests
if [ ! -d "$MMCI_MMTESTS_DIR" ]; then
	log "Fetching MMTests for the first time:"
	log " repository/branch: ${MMCI_MMTESTS_REPO}/${MMCI_MMTESTS_BRANCH}"
	log " local directory: $MMCI_MMTESTS_DIR"
	git clone --single-branch --branch "$MMCI_MMTESTS_BRANCH" "$MMCI_MMTESTS_REPO" "$MMCI_MMTESTS_DIR" &> /dev/null
	[[ $? -eq 0 ]] || fail "Cannot fetch MMTESTS. Will not continue"
else
	pushd "$MMCI_MMTESTS_DIR"
	log "Updating MMTests:"
	log " local branch: $(git branch | grep '^\*'|cut -f2 -d' ')"
	log " local directory: $(pwd)"
	git remote update && git pull
	if [[ $? -ne 0 ]]; then
		log "******************************* W A R N I N G ******************************"
		log "CANNOT UPDATE mmtests FROM GIT. RUNNING WITH POTENTIALLY OUTDATED TEST SUITE"
	fi
	popd
fi

# Pull/Update any defined additional repository. We check for a list of them
# in a "list of strings" variable called $MMCI_ADDITIONAL_GITREPOS_LIST. Format
# for each entry of such list is:
#  repodir@repo-url
#
# An idea could be to put such a list in the ci-config file of an host, and put
# there all the additional repositories that should be checked out for running
# mmtests-ci on that host. Such as, for instance, test-host directories for
# local servers and stuff like that.
for R in $MMCI_ADDITIONAL_GITREPOS_LIST ; do
	# TODO: We might want to support multiple branches too
	RURL=$(echo $R | awk -F '@' '{print $2}')
	RDIR="${DIR}/$(echo $R | awk -F '@' '{print $1}')"
	# Check if we can actually reach the repo. If not, just skipt it
	if ! git -c http.sslVerify=false ls-remote "$RURL" &> /dev/null ; then
		log "WARNING: additional git repo $RDIR defined but unreachable. Skipping it."
		continue
	fi
	if [[ ! -d $RDIR ]]; then
		log "Cloning $RURL in $RDIR"
		git clone "$RURL" "$RDIR"
		[[ $? -eq 0 ]] || log "WARNING: cannot clone git repo $RDIR. Trying to continue..."
	else
		pushd $RDIR
		log "Updating $RURL in $(pwd)"
		git remote update && git pull
		if [[ $? -ne 0 ]]; then
			log "**************************** W A R N I N G ****************************"
			log "CANNOT UPDATE $RDIR FROM GIT. RUNNING WITH POTENTIALLY OUTDATED \"STUFF\""
		fi
		popd
	fi
done

# TODO: Shall we update the OS here? Or just leave it to the testplan?
#       Point is, there might be tests for which we _do_not_ want the OS to
#       be always updated. So, yeah, for now we live that to the testplan.

# Now we can start the tests, according to the testplan for this host. That
# is available in the test-host directory.
#
# If there is no test-host directory for this host, or there is not testplan
# there, we just jump directly to the last step, i.e., rebooting the host,
# possibly into another OS/partition.
if [ ! -d "$MMCI_HOSTDIR" ] || [ ! -f "${MMCI_HOSTDIR}/testplan" ]; then
	log "WARNING: No tests for this host? Moving forward..."
	${MMCI_DIR}/reboot_to_next_os_step.sh
	exit $?
fi

# testplan.step, in the test-host directory, is the file we use to keep track
# of what step in the testplan we are in, across reboots. It really should not
# be there, because any previous execution of the testplan should have cleaned
# it up, when it was not needed any longer. But, I mean, just in case... :-)
rm -f ${MMCI_HOSTDIR}/testplan.step

log "DONE update_all_step.sh"

cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
reboot
exit 0
