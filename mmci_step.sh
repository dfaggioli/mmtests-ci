#!/bin/bash -x

DIR="/root"

echo "MMCI Step: $(date)"

if [ -f "$DIR/mmci_term" ]; then
	echo "MMCI Termination file found: quitting"
	exit 1
fi

while [ -f "$DIR/mmci_pause" ]; do
	echo "MMCI Pause file found: waiting 60 secs"
	sleep 60
done

CWD="/$DIR/mmtests-ci"
if [ ! -d "$CWD" ]; then
	# This is the very first time we run here!
	# We need to clone the repo, xxx
	git clone https://github.com/dfaggioli/mmtests-ci.git $CWD
fi

if [ ! -f "$DIR/mmci_next_step.sh" ]; then
	# Either it's the first time, or we lost
	# track of where we were. Go back to first step.
	cp "${CWD}/step1.sh" /root/mmci_next_step.sh
	reboot
	exit 0
fi

cp ${DIR}/mmci_next_step.sh ${DIR}/mmci_curr_step.sh
exec ${DIR}/mmci_curr_step.sh
