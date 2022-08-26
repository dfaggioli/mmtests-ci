#!/bin/bash -x

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"

. "${MMCI_DIR}/common.sh"


log "STARTING $(realpath $0)"

if [ -f "$DIR/mmci_term" ]; then
	log "MMCI Termination file found: quitting"
	exit 1
fi

while [ -f "$DIR/mmci_pause" ]; do
	log "MMCI Pause file found: waiting 60 secs"
	sleep 60
done

if [ ! -d "$MMCI_DIR" ]; then
	# This is the very first time we run here!
	# We need to clone the repo, xxx
	git clone https://github.com/dfaggioli/mmtests-ci.git $MMCI_DIR
fi

if [ ! -f "$DIR/mmci_next_step.sh" ]; then
	# Either it's the first time, or we lost
	# track of where we were. Go back to first step.
	cp -a "${MMCI_DIR}/update_all_step.sh" "${DIR}/mmci_next_step.sh"
	reboot
	exit 0
fi

cp -a "${DIR}/mmci_next_step.sh" "${DIR}/mmci_curr_step.sh"
exec ${DIR}/mmci_curr_step.sh
