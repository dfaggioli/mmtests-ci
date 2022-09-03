#!/bin/bash -x
#
# XXX
#
# Usage is:

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

# XXX
# check_run_test $TESTNAME

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
			HC=$(fetch_test_config -h $HCONFIG)
			[[ $HC ]] || fail "Cannot find the host config file $HCONFIG for the configuration $HCONF"

			start_libvirtd
			BIN="run-kvm"
			HC_STR="-L -C $HC"
		fi

		# XXX
		TEST=$(echo $T | awk -F '@' '{print $1}')
		TCONFIG=$(echo $T | awk -F '@' '{print $2}')
		TC=$(fetch_test_config $TCONFIG)
		[[ $TC ]] || fail "Cannot find the config file $TCONFIG for the test $TEST"

		# Run the test
		TESTID="${TEST}_${HCONF}_$(date +%m%d%Y_%H%M)"
		rm -rf work/log
		./${BIN}.sh $MONITOR $HC_STR -c $TC $TESTID

		# Save the results
		cp -a ./work/log/* "${MMCI_RESULTS_DIR}/${TESTNAME}/multi-vms/"
	done
done

popd
exit 0
