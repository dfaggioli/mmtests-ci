#!/bin/bash -x
#
# XXX
#
# Supported test names are:
# - official-rpms
#
# If a non supported test name is provided, we just _always_ run the test.
#
# Usage is:

TNAME="test"
TGROUP="default"

while true ; do
	if [[ "$1" == "--testname" ]]; then
		TNAME="$2"
		shift 2
	elif [[ "$1" == "--testgroup" ]]; then
		TGROUP="$2"
		shift 2
	else
		break
	fi
done

function check_rpms() {
	local RPMLIST=$(mktemp /tmp/curr-rpm-list-XXXX.txt)
	local LATEST_RPMLIST="${MMCI_RESULTS_DIR}/${TNAME}/rpm-packages.txt"

	[[ -f "$LATEST_RPMLIST" ]] || touch "$LATEST_RPMLIST"
	rpm -qa | sort > "$RPMLIST"

	if diff "$LATEST_RPMLIST" "$RPMLIST" ; then
		mv "$RPMLIST" "$LATEST_RPMLIST"
		echo "go"
	else
		echo "no-go"
	fi
}

case "$TNAME" in
	official-rpms)
		CHECK=$(check_rpms)
		;;
	*)
		CHECK="go"
		;;
esac

[[ "$CHECK" == "go" ]] && exit 0
exit 1
