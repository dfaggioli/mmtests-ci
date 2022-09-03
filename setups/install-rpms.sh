#!/bin/bash -x
#
# Install packages and/or package groups (called patterns in [open]SUSE).
#
# For installing some packages, use the '--packages' parameter, followed by
# a (coma separated) list of package names. For installing some patterns, use
# the '--patterns' parameter, followed by a (coma separated) list of pattern
# names.
#
# The special parameter '--kvm-all' can be used to install all the packages
# related to QEMU/kvm. The special parameter '--kvm-base' can be used to
# install only the basic set of packages needed for having a QEMU/kvm system
# up and running.
#
# All the various parameters can be used together and combiner, and they can
# even appear multiple times.
#
# Usage is: install-rpms.sh [--test TESTNAME] [--kvm-all] [--kvm-base] [--packages pkg1,pkg2,...]
#		[--patterns pttrn1,ptrn2,...]
PATTERNS_LIST=""
PACKAGES_LIST=""

log "STARTING install-rpms.sh (args: $@)"

while true ; do
	if [[ "$1" == "--test" ]]; then
		TESTNAME=$2
		shift 2
	elif [[ "$1" == "--kvm-all" ]]; then
		# We want to install all the QEMU/KVM packages. On [open]SUSE
		# this can be achieved by installing a couple of patterns (they
		# should be 'kvm_server' and 'kvm_tools', but do check in
		# common.sh).
		case "$MMCI_PACKAGE_MANAGER" in
			"zypper")
				PATTERNS_LIST="$PATTERNS_LIST $MMCI_PACKAGES_KVM_INSTALL_ALL_PATTERNS"
				;;
		esac
		shift
	elif [[ "$1" == "--kvm-base" ]]; then
		# We want to install only the minimal set of packages necessary
		# for having QEMU/KVM running. Check in common.sh for the list.
		case "$MMCI_PACKAGE_MANAGER" in
			"zypper")
				PACKAGES_LIST="$PACKAGES_LIST $MMCI_PACKAGES_KVM_INSTALL_BASE_PACKAGES"
				;;
		esac
		shift
	elif [[ "$1" == "--packages" ]]; then
		# The '--packages' parameter should be followed by a ','
		# separated list of package names.
		PACKAGES_LIST="$PACKAGES_LIST $(echo $2 | tr ',' ' ')"
		shift 2
	elif [[ "$1" == "--patterns" ]]; then
		# The '--pattern' parameter should be followed by a ','
		# separated list of pattern names.
		PATTERNS_LIST="$PATTERNS_LIST $(echo $2 | tr ',' ' ')"
		shift 2
	else
		break
	fi
done

case "$MMCI_PACKAGE_MANAGER" in
	"zypper")
		[[ "$PATTERNS_LIST" ]] && $MMCI_PACKAGES_PATTERNS_INSTALL $PATTERNS_LIST
		;;
	*)
		fail "ERROR: Support for $MMCI_PACKAGE_MANAGER not implemented yet"
		;;
esac
[[ "$PACKAGES_LIST" ]] && $MMCI_PACKAGES_INSTALL $PACKAGES_LIST

log "DONE install-rpms.sh"
exit 0
