#!/bin/bash -x

cwd="/root/mmtests-ci/$(hostname -s)"

echo "MMCI Step: $(date)"

if [ -f /root/mmci_term ]; then
	echo "MMCI Termination file found: quitting"
	exit 1
fi

while [ -f /root/mmci_pause ]; do
	echo "MMCI Pause file found: waiting 60 secs"
	sleep 60
done

if [ ! -d "$cwd" ]; then
	# This is the very first time we run here!
	# We need to clone the repo, xxx
	echo git clone xxx
fi

if [ ! -f /root/mmci_next_step.sh ]; then
	# Either it's the first time, or we lost
	# track of where we were. Go back to first step.
	cp "${cwd}"/step1.sh /root/mmci_next_step.sh
	reboot
	exit 0
fi

cp /root/mmci_next_step.sh /root/mmci_curr_step.sh
exec /root/mmci_curr_step.sh
