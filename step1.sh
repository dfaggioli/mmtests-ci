#!/bin/bash -x

DIR=/root
CWD="$DIR/mmtests-ci"

echo STARTING generic-step1 $(date) >> ${DIR}/mmci_steps.log

# Make sure the repo is always updated
cd $CWD || exit 255
git pull . origin/main
# TODO: What to do on failure?

# Start host-specific test scripts
CWD="${CWD}/$(hostname -s)"
if [ ! -d "$CWD" ]; then
	echo "ERROR: Missing directory $CWD"
	exit 255
fi

echo DONE generic-step1 $(date) >> ${DIR}/mmci_steps.log

cp -a "${CWD}/step1.sh" "${DIR}/mmci_next_step.sh"
chmod +x "${DIR}/mmci_next_step.sh"
reboot

exit 0
