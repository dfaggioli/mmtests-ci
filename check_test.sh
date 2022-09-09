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
TMPDIR="${MMCI_DIR}/tmp_check_test_dir"
CHECK="go"

while true ; do
	if [[ "$1" == "--testname" ]]; then
		TNAME="$2"
		shift 2
	elif [[ "$1" == "--testgroup" ]]; then
		TGROUP="$2"
		shift 2
	elif [[ "$1" == "--success" ]]; then
		if [[ ! -d "$TMPDIR" ]] || [[ $(ls "$TMPDIR" | wc -l) -eq 0 ]]; then
			log "WARNING: Called with '--success' but nothing in $TMPDIR. That is wrong!"
		fi
		mv  "${TMPDIR}/*" "${MMCI_RESULTS_DIR}/${TESTNAME}/${TESTGROUP}"
		rmdir "$TMPDIR"
		exit 0
	else
		break
	fi
done

function check_rpms() {
	local RPMLIST="${TMPDIR}/rpm-packages.txt"
	local LATEST_RPMLIST="${MMCI_RESULTS_DIR}/${TNAME}/${TGROUP}/rpm-packages.txt"


	[[ -f "$LATEST_RPMLIST" ]] || touch "$LATEST_RPMLIST"
	rpm -qa | sort > "$RPMLIST"

	if diff "$LATEST_RPMLIST" "$RPMLIST" ; then
		# They look the same, no need to do anything!
		touch "$LATEST_RPMLIST"
		CHECK="no-go"
	else
		CHECK="go"
	fi
}

mkdir -p "$TMPDIR"
case "$TNAME" in
	"official-rpms" | "devel-virt-rpms" | "qemu-*-*-0")
		check_rpms
		;;
esac

[[ "$CHECK" == "go" ]] && exit 0
rm -rf "$TMPDIR" ; exit 1
