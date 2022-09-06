#!/bin/bash -x
#
# XXX
#
# Usage is:

# XXX
TESTGROUP=$(cat /proc/${PPID}/comm)
TESTGROUP=$(basename $TESTGROUP)
TESTGROUP=$(echo $TESTGROUP | cut -f1 -d'.')

${DIR}/check_test.sh --testname "$TESTNAME" --testgroup "$TESTGROUP"
if [[ $? -eq 0 ]] ; then
	log "Skipping ${TESTNAME}: nothing changed since last run"
	exit 0
fi

[[ "$MMCI_MMTESTS_FORCE_MONITORS" == "yes" ]] && MONITORS="-m"

pushd $MMCI_MMTESTS_DIR

while true ; do
	if [[ "$1" == "--test" ]]; then
		TESTNAME=$2
		shift 2
	elif [[ "$1" == "--force-monitors" ]]; then
		MONITORS="-m"
		shift
	elif [[ "$1" == "--force-no-monitors" ]]; then
		MONITORS="-n"
		shift
	else
		break
	fi
done

prepare_mmtests
for H in $HOST_CONFIGS ; do
	for T in $TESTS ; do
		# XXX
		HCONF=$(echo $H | awk -F '@' '{print $1}')
		HCONFIG=$(echo $H | awk -F '@' '{print $2}')
		if [[ "$HCONFIG" == "-" ]]; then
			# Baremetal run!
			BIN="run-mmtests"
			HC_STR=""
		else
			HC=$(fetch_mmtests_config -h $HCONFIG)
			[[ $HC ]] || fail "Cannot find the host config file $HCONFIG for the configuration $HCONF"

			start_libvirtd
			BIN="run-kvm"
			echo export MMTESTS_PSSH_OUTDIR=/tmp >> $HC
			echo export MMTESTS_PSSH_CONFIG_OPTIONS="-v" >> $HC
			echo MMTESTS_SSH_CONFIG_OPTIONS="-o LogLevel=INFO" >> $HC
			cp "$HC" "${MMCI_MMTESTS_DIR}/mmtests-host-config"
			HC_STR="-L -C mmtests-host-config"
		fi

		# XXX
		TEST=$(echo $T | awk -F '@' '{print $1}')
		TCONFIG=$(echo $T | awk -F '@' '{print $2}')
		TC=$(fetch_mmtests_config $TCONFIG)
		[[ $TC ]] || fail "Cannot find the config file $TCONFIG for the test $TEST"
		cp "$TC" "${MMCI_MMTESTS_DIR}/mmtests-config"

		# Run the test
		TESTID="${TEST}_${HCONF}_$(date +%m%d%Y_%H%M)"
		rm -rf work/log
		bash -x ./${BIN}.sh $MONITOR $HC_STR -c mmtests-config $TESTID

		# Save the results
		mkdir -p "${MMCI_RESULTS_DIR}/${TESTNAME}/${TESTGROUP}"
		cp -a ./work/log/* "${MMCI_RESULTS_DIR}/${TESTNAME}/$TESTGROUP/"
	done
done

popd
exit 0
