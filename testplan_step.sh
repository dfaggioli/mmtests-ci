#!/bin/bash -x

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"

. "${MMCI_DIR}/common.sh"

# TODO: parametrize this
RESULTS="${DIR}/mmci-results/"

log "STARTING testplan_step.sh"

L=0
LASTLINE=$(cat ${MMCI_HOSTDIR}/testplan.step 2> /dev/null || echo "0")
while read -r -u 3 LINE; do
	L=$(($L + 1))
	echo "XXX $L $LINE $LASTLINE"
	[ "$LINE" == "START" ] && continue
	[[ "$LINE" =~ "^#.*" ]] && continue
	[ $L -le $LASTLINE ] && continue
	[ "$LINE" == "END" ] && break
	if [[ "$LINE" =~ "^TEST.*" ]]; then
		# FIXME: Use BASH_REMATCH https://stackoverflow.com/questions/17420994/how-can-i-match-a-string-with-a-regex-in-bash
		TESTNAME=$(echo "$LINE" | cut -f2 -d' ')
		#read -r -u 3 LINE
	fi
	read -r -u 3 LINE
	L=$(($L + 1))
	if [ ! -f "${MMCI_DIR}/${LINE}" ]; then
		log "WARNING: script ${MMCI_DIR}/${LINE} is missing. Trying to continue..."
	else
		log "RUNNING $LINE"
		eval ${MMCI_DIR}/${LINE} $TESTNAME
		if [ $? -ne 0 ]; then
			# The script failed. Either there's no need to run this
			# test, or something did not work. In any case, let's
			# jump to the next one
			LL=$(($L + 1))
			L=$(cat -n ${MMCI_HOSTDIR}/testplan |tail -n +${LL}|grep -B1 -m1 setups|head -1|cut -f1|xargs)
		fi
	fi
	echo $L > ${MMCI_HOSTDIR}/testplan.step
	break
done 3< ${MMCI_HOSTDIR}/testplan

log "DONE testplan_step.sh"

# FIXME: We're probably rebooting one time more than we could
if [ "$LINE" == "END" ]; then
	rm ${MMCI_HOSTDIR}/testplan.step
	exec "${MMCI_DIR}/reboot_to_next_os_step.sh" "${DIR}/mmci_next_step.sh"
else
	cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
fi
reboot
exit 0
