#!/bin/bash -x

[ -z "$DIR" ] && export DIR="$HOME"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
if [ -d "${MMCI_DIR}" ]; then
	. "${MMCI_DIR}/common.sh" || exit 255
fi

TERM_FILE="${DIR}/mmci_term"
PAUSE_FILE="${DIR}/mmci_pause"

echo "Starting a new MMTests-CI step ($(realpath $0))"
echo " For pausing (at next step): touch  $PAUSE_FILE"
echo " (And for unpausing: rm $PAUSE_FILE"
echo " For stopping (at next step): touch $TERM_FILE"

if [ -f "$TERM_FILE" ]; then
	echo "MMCI Termination file found: quitting"
	exit 1
fi

while [ -f "$PAUSE_FILE" ]; do
	echo "MMCI Pause file found: waiting $MMCI_PAUSE_TIME secs"
	sleep $MMCI_PAUSE_TIME
done

if [ ! -d "$MMCI_DIR" ]; then
	# This is the very first time we run here!
	# We need to clone the repo, xxx
	git clone https://github.com/dfaggioli/mmtests-ci.git $MMCI_DIR
fi

if [ ! -f /root/mmci_next_step.sh ]; then
	# Either it's the first time, or we lost
	# track of where we were. Go back to first step.
	cp -a "${MMCI_DIR}/update_all_step.sh" "${DIR}/mmci_next_step.sh"
	reboot
	exit 0
fi

cp -a "${DIR}/mmci_next_step.sh" "${DIR}/mmci_curr_step.sh"
${DIR}/mmci_curr_step.sh
exit $?
