#!/bin/bash -x

#[ -z "$DIR" ] && export DIR="/root"
#[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
#export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"
#. "${MMCI_DIR}/common.sh"

# TODO: parametrize this
RESULTS="${DIR}/mmci-results/"

log "STARTING testplan_step.sh"

L=0
LASTLINE=$(cat ${MMCI_HOSTDIR}/testplan.step 2> /dev/null || echo "0")
while read -r -u 3 LINE; do
	echo "XXX $MMCI_OS_ID $MMCI_OS_VERSION_ID"
	L=$(($L + 1))
	[ "$LINE" == "END" ] && break
	[ "$LINE" == "START" ] && continue
	[[ "$LINE" =~ ^#.* ]] && continue
	if [[ "$LINE" =~ ^TEST.* ]]; then
		# FIXME: Use BASH_REMATCH https://stackoverflow.com/questions/17420994/how-can-i-match-a-string-with-a-regex-in-bash
		TESTNAME=$(echo "$LINE" | cut -f2 -d' ')
		#" TODO: Do we need to write TESTNAME to file, e.g., for saving results properly?
		continue
	fi
	[ $L -le $LASTLINE ] && continue
	if [ ! -f "$(echo ${MMCI_DIR}/${LINE} | awk '{print $1;}')" ]; then
		log "WARNING: script ${MMCI_DIR}/${LINE} is missing. Trying to continue..."
	else
		log "RUNNING $LINE"
		CMD=$(echo "$LINE" | cut -f1 -d' ')
		[[ $(wc -w <<< "$LINE") -gt 1 ]] && PARAMS=$(echo "$LINE" | cut -f2- -d' ')
		${MMCI_DIR}/${CMD} --test $TESTNAME ${PARAMS}
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
# FIXME: We probably can get rid of the file descr. logic
done 3< ${MMCI_HOSTDIR}/testplan

log "DONE testplan_step.sh"

# FIXME: We're probably rebooting one time more than we could
if [ "$LINE" == "END" ]; then
	rm -f ${MMCI_HOSTDIR}/testplan.step
	exec "${MMCI_DIR}/reboot_to_next_os_step.sh" "${DIR}/mmci_next_step.sh"
else
	cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
fi
reboot
exit 0
