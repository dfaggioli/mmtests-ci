#!/bin/bash -x

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"

. "${MMCI_DIR}/common.sh"

log "STARTING $(realpath $0)"

LASTLINE=$(cat ${MMCI_HOSTDIR}/testplan.step 2> /dev/null || echo "START")
while read -r -u 3 LINE; do
	[ "$LINE" != "$LASTLINE" ] && continue
	[ "$LINE" == "END" ] && break
	read -r -u 3 LINE
	log "RUNNING $LINE"
	sleep 180 # FIXME: ~ ./$LINE
	echo "$LINE" > ${MMCI_HOSTDIR}/testplan.step
	break
done 3< ${MMCI_HOSTDIR}/testplan

log "DONE $(realpath $0)"

# FIXME: We're probably rebooting one time more than we could
if [ "$LINE" == "END" ]; then
	rm ${MMCI_HOSTDIR}/testplan.step
	exec "${MMCI_DIR}/reboot_to_next_os_step.sh" "${DIR}/mmci_next_step.sh"
else
	cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
fi
reboot
exit 0
