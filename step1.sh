#!/bin/bash -x

DIR=/root
CWD="$DIR/mmtests-ci"

# Make sure the repo is always updated
cd $CWD
git pull . origin/master # TODO: parametrize branch?
# TODO: What to do on failure?

# Start host-specific test scripts
CWD="${DIR}/$(hostname -s)"
if [ ! -d "$CWD" ]; then
	echo "ERROR: Missing directory $CWD"
	exit 255
fi

cp "${CWD}/step1.sh" "${DIR}/mmci_next_step.sh"
reboot

exit 0
