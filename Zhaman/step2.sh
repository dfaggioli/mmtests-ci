#!/bin/bash -x

DIR="/root"
CWD="${DIR}/mmtests-ci/$(hostname -s)"

echo STARTING step2 $(date) >> ${DIR}/mmci_steps.log
sleep 300
echo DONE step2 $(date) >> ${DIR}/mmci_steps.log

cp ${CWD}/step3.sh ${DIR}/mmci_next_step.sh
chmod +x ${DIR}/mmci_next_step.sh
reboot

exit 0
