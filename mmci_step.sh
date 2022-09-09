#!/bin/bash

[[ ! "$DIR" ]] && export DIR="$HOME"
[[ ! "$MMCI_DIR" ]] && export MMCI_DIR="${DIR}/mmtests-ci"
[[ ! "$MMCI_GIT_REPO" ]] && export MMCI_GIT_REPO="https://github.com/dfaggioli/mmtests-ci.git"
[[ ! "$MMCI_GIT_BRANCH" ]] && export MMCI_GIT_BRANCH="main"

if [[ ! -d "$MMCI_DIR" ]]; then
	# Apparently, this is the very first time we run here! Let's try to
	# clone the repo and everything. We need git for that, but we don't
	# know what distro we're in, etc, yet, so we can't install it!
	if ! command -v git &> /dev/null ; then
		echo "ERROR: First run on this host, we need git to clone the repo. Cannot continue!"
		exit 1
	fi
	git clone --single-branch --branch "$MMCI_GIT_BRANCH" "$MMCI_GIT_REPO" "$MMCI_DIR" &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo "ERROR: cloning ${MMCI_GIT_REPO}/${MMCI_GIT_BRANCH} failed. Cannot continue!"
		exit 1
	fi
fi

if [[ ! -d "${MMCI_DIR}" ]] || [[ ! -f "${MMCI_DIR}/common.sh" ]]; then
	echo "ERROR: $MMCI_DIR and/or ${MMCI_DIR}/common.sh not there. Cannot continue!"
	exit 1
fi
. "${MMCI_DIR}/common.sh"
if [[ $? -ne 0 ]]; then
	echo "ERROR: something wrong in ${MMCI_DIR}/common.sh. Cannot continue!"
	exit 1
fi

# We can now create the log directory, and start using log() and fail()
mkdir -p "$MMCI_LOGDIR"

log "Starting a new MMTests-CI step (DIR=$DIR, MMCI_DIR=$MMCI_DIR)"
log " - For pausing (at next step):"
log "    touch  $MMCI_PAUSE_FILE"
log " - And for unpausing (will restart right away):"
log "    rm $MMCI_PAUSE_FILE"
log " - For stopping (at next step):"
log "    touch $MMCI_TERM_FILE"

if [[ -f "$MMCI_TERM_FILE" ]]; then
	log "MMCI Termination file found: just quitting"
	rm -f "$MMCI_TERM_FILE"
	exit 0
fi

while [[ -f "$MMCI_PAUSE_FILE" ]]; do
	log "MMCI Pause file found: waiting $MMCI_PAUSE_TIME secs"
	sleep $MMCI_PAUSE_TIME
done

if [[ ! -f /root/mmci_next_step.sh ]]; then
	# Either it's the first time we run on this host, or we lost
	# track of where we were. Go back to first step.
	cp -a "${MMCI_DIR}/update_all_step.sh" "${DIR}/mmci_next_step.sh"
	reboot
	exit 0
fi

# This can look tricky: the previous step (during previous boot) did put in
# mmci_next_step.sh what we should do now. So, let's put that in mmci_curr_step
# and run it. It'll be it's own task to copy the appropriate script in
# mmci_next_step, depending on what step should run next, before rebooting.
cp -a "${DIR}/mmci_next_step.sh" "${DIR}/mmci_curr_step.sh"
${DIR}/mmci_curr_step.sh
exit $?
