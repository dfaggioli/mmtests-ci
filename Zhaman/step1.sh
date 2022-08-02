#!/bin/bash -x

DIR="/root"
CWD="${DIR}/mmtests-ci/$(hostname -s)"

echo STARTING step1 $(date) >> ${DIR}/mmci_steps.log
sleep 120
echo DONE step1 $(date) >> ${DIR}/mmci_steps.log

cp ${CWD}/step2.sh ${DIR}/mmci_next_step.sh
reboot

exit 0
