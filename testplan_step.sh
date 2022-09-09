#!/bin/bash

# The config files might have defined where results should be put already
# (hopefully basing on $MMCI_RESULTS_BASEDIR). If that is not the case, it's
# time to do it now, and create the directory itself as well.
[[ ! "$MMCI_RESULTS_DIR" ]] && export MMCI_RESULTS_DIR="${MMCI_RESULTS_BASEDIR}/${MMCI_HOSTPATH}"
mkdir -p "$MMCI_RESULTS_DIR"

log "STARTING testplan_step.sh"

L=0
LASTLINE=$(cat ${MMCI_HOSTDIR}/testplan.step 2> /dev/null || echo "0")
while read -r -u 3 LINE; do
	L=$(($L + 1))
	[[ "$LINE" == "END" ]] && break
	[[ "$LINE" == "START" ]] && continue
	[[ "$LINE" =~ ^#.* ]] && continue
	if [[ "$LINE" =~ ^TEST.* ]]; then
		# FIXME: Use BASH_REMATCH https://stackoverflow.com/questions/17420994/how-can-i-match-a-string-with-a-regex-in-bash
		TESTNAME=$(echo "$LINE" | cut -f2 -d' ')
		#" TODO: Do we need to write TESTNAME to file, e.g., for saving results properly?
		continue
	fi
	[[ $L -le $LASTLINE ]] && continue
	#CMD="$(echo ${LINE} | awk '{print $1;}')"
	CMD="$(echo "$LINE" | cut -f1 -d' ')"
	if  [[ ! -f "${MMCI_DIR}/${CMD}" ]]; then
		log "WARNING: script ${MMCI_DIR}/${CMD} is missing. Trying to continue..."
	else
		log "About to run: $LINE"
		[[ $(wc -w <<< "$LINE") -gt 1 ]] && PARAMS=$(echo "$LINE" | cut -f2- -d' ')
		${MMCI_DIR}/${CMD} --test $TESTNAME ${PARAMS}
		if [[ $? -ne 0 ]]; then
			# The script failed. Either there's no need to run this
			# test, or something did not work. If this happens, we
			# directly to the *next test* (i.e., to what follows
			# the next TEST label in the plan.
			#
			# FIXME: Actually, currently, we jump to the first script
			# that we find that is in setups, which may or may not be
			# the same thing. Improve this!
			LL=$(($L + 1))
			L=$(cat -n ${MMCI_HOSTDIR}/testplan | tail -n +${LL} | grep -B1 -m1 setups | head -1 | cut -f1 | xargs)
		fi
	fi
	echo $L > ${MMCI_HOSTDIR}/testplan.step
	break
# FIXME: We probably can get rid of the file descr. logic
done 3< ${MMCI_HOSTDIR}/testplan

log "DONE testplan_step.sh"

# FIXME: We're probably rebooting one time more than necessary
if [[ "$LINE" == "END" ]]; then
	rm -f ${MMCI_HOSTDIR}/testplan.step
	exec "${MMCI_DIR}/reboot_to_next_os_step.sh" "${DIR}/mmci_next_step.sh"
else
	cp -a "${MMCI_DIR}/testplan_step.sh" "${DIR}/mmci_next_step.sh"
fi
reboot
exit 0
