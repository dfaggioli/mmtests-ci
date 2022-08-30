#!/bin/bash
#set -euo pipefail

. common.sh

# TODO: Do we want to handle installing from specific repo?
#FROM="--from xxx" / "-r xxx"

#### Modify zypper configuration to allow Vendor changes
###if [ "$MMCI_REPO_ALLOW_VENDOR_CHANGE" = "yes" ]; then
###	sed -i 's/# solver.allowVendorChange = false/solver.allowVendorChange = true/' /etc/zypp/zypp.conf
###fi
###
#### First of all, update everything
###$MMCI_PACKAGE_REFRESH && $MMCI_PACKAGES_UPDATE

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
		all|base)
			#if [ $LIST_PKGS -eq 1 ] || [ $LIST_PTTRNS -eq 1 ]; then PP_ALL=1 ; fi
			break
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

KVM_INSTALL_BASE="qemu-x86 tftp libvirt-daemon-qemu virt-install libvirt-client libvirt-daemon-config-network tigervnc virt-manager vm-install"
if [ "$1" = "all" ]; then
	if [ ${#PKGS[@]} -ne 0 ] || [ ${#PTTRNS[@]} -ne 0 ]; then
		echo "ERROR: Do not mix 'all' with package names"
		exit 1
	fi
	MMCI_INSTALL_PATTERNS="kvm_server kvm_tools"
	MMCI_INSTALL_RPMS="virt-viewer"
elif [ "$1" = "base" ]; then
	if [ ${#PKGS[@]} -ne 0 ] || [ ${#PTTRNS[@]} -ne 0 ]; then
		echo "ERROR: Do not mix 'base' with package names"
		exit 1
	fi
	MMCI_INSTALL_RPMS="$KVM_INSTALL_BASE"
else
	if [ ${#PKGS[@]} -eq 1 ] && [ -f $PKGS ]; then
		MMCI_INSTALL_RPMS=$(cat "$PKGS")
	elif [ ${#PKGS[@]} -ge 1 ]; then
		MMCI_INSTALL_RPMS="${PKGS[@]}"
	fi
	if [ ${#PTTRNS[@]} -eq 1 ] && [ -f $PTTRNS ]; then
		MMCI_INSTALL_PATTERNS=$(cat "$PTTRNS")
	elif [ ${#PTTRNS[@]} -ge 1 ]; then
		MMCI_INSTALL_PATTERNS="${PTTRNS[@]}"
	fi
fi

# By default, install the basics...
[ -z "$MMCI_INSTALL_RPMS" ] && MMCI_INSTALL_RPMS="$KVM_INSTALL_BASE"

if [ ! -z "$MMCI_INSTALL_PATTERNS" ]; then
	$MMCI_PACKAGE_INSTALL $FROM -t pattern $MMCI_INSTALL_PATTERNS
	if [ $? -ne 0 ]; then
		echo "ERROR: failed installing patterns: $MMCI_INSTALL_PATTERNS"
		exit 1
	fi
fi
if [ ! -z "$MMCI_INSTALL_RPMS" ]; then
	$MMCI_PACKAGE_INSTALL $FROM $MMCI_INSTALL_RPMS
	if [ $? -ne 0 ]; then
		echo "ERROR: failed installing packages: $MMCI_INSTALL_RPMS"
		exit 1
	fi
fi

exit 0
