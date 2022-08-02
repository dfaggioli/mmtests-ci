#!/bin/bash -x

DIR="/root"
CWD="${DIR}/mmtests-ci/$(hostname -s)"

echo STARTING step3 $(date) >> ${DIR}/mmci_steps.log
sleep 300
echo DONE step3 $(date) >> ${DIR}/mmci_steps.log

# If it's the last step, remember olh-autoinst, to change partition!
# The first step of the loop will be run again on this OS, when we
# will be back here, i.e., after someone of the other partitions does
# an olh-autoinst-set-default to us.
#
# Another thing to remember, if this is the last one, is to set the
# generic step1.sh as next, not the one for this host
cp ${CWD}/../step1.sh ${DIR}/mmci_next_step.sh
chmox +x ${DIR}/mmci_next_step.sh
reboot

exit 0
