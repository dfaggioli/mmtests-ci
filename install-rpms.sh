#!/bin/bash
#set -euo pipefail

# TODO: Factor these out in a common script
ZYPP="zypper --non-interactive --gpg-auto-import-keys"
ZYPP_IN="$ZYPP install -l --force-resolution"
ZYPP_REF="$ZYPP ref"
ZYPP_DUP="$ZYPP dup"

# Modify zypper configuration to allow Vendor changes:
sed -i 's/# solver.allowVendorChange = false/solver.allowVendorChange = true/' /etc/zypp/zypp.conf

# TODO: Do we want to handle installing from specific repo?
#FROM="--from xxx" / "-r xxx"

# First of all, update everything
$ZYPP_REF
$ZYP_DUP

LIST_PKGS=0
LIST_PTTRNS=0
PP_ALL=0
declare -a PKGS=()
declare -a PTTRNS=()
while [ $# -gt 0 ]; do
	case "$1" in
		--packages)
			LIST_PKGS=1
			LIST_PTTRNS=0
			shift
			continue
			;;
		--patterns)
			LIST_PKGS=0
			LIST_PTTRNS=1
			shift
			continue
			;;
		all)
			if [ $LIST_PKGS -eq 1 ] || [ $LIST_PTTRNS -eq 1 ]; then PP_ALL=1 ; fi
			shift
			continue
			;;
		*)
			PP=$1
			shift
			;;
	esac

	if [ $LIST_PKGS -eq 1 ]; then
		PKGS+=( "$PP" )
	elif [ $LIST_PTTRNS -eq 1 ]; then
		PTTRNS+=( "$PP" )
	fi
done

if [ ${PP_ALL} -eq 1 ]; then
	if [ ${#PKGS[@]} -ne 0 ] || [ ${#PTTRNS[@]} -ne 0 ]; then
		echo "ERROR: Do not mix 'all' with package names"
		exit 1
	fi
	KVM_INSTALL_RPMS="all"
fi

if [ ${#PKGS[@]} -eq 1 ] && [ -f $PKGS ]; then
	KVM_INSTALL_RPMS=$(cat "$PKGS")
elif [ ${#PKGS[@]} -ge 1 ]; then
	KVM_INSTALL_RPMS="${PKGS[@]}"
fi
if [ ${#PTTRNS[@]} -eq 1 ] && [ -f $PTTRNS ]; then
	KVM_INSTALL_PATTERNS=$(cat "$PTTRNS")
elif [ ${#PTTRNS[@]} -ge 1 ]; then
	KVM_INSTALL_PATTERNS="${PTTRNS[@]}"
fi

# By default, just install everything!
[ -z "$KVM_INSTALL_RPMS" ] && KVM_INSTALL_RPMS="all"

if [ "$KVM_INSTALL_RPMS" = "all" ]; then
	KVM_INSTALL_PATTERNS="kvm_server kvm_tools"
	KVM_INSTALL_RPMS="virt-viewer"
fi

if [ ! -z "$KVM_INSTALL_PATTERNS" ]; then
	$ZYPP_IN $FROM -t pattern $KVM_INSTALL_PATTERN
fi
if [ ! -z "$KVM_INSTALL_RPMS" ]; then
	$ZYPP_IN $FROM $KVM_INSTALL_RPMS
fi
