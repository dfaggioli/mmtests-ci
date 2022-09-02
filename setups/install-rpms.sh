#!/bin/bash -x
#
# $1 is the repository configuration we want to setup. It can be:
# - default: only default repos
# - virt-devel: default plus [open]SUSE's devel project/staging repos

log "STARTING install-rpms.sh (args: $@)"

# First of all, 
case "$MMCI_OS_ID" in
	"opensuse-tumbleweed"|"opensuse-microos")
		DEFAULT_REPOS="repo-oss repo-update repo-non-oss"
		;;
	"opensuse-leap")
		DEFAULT_REPOS="repo-oss repo-update repo-non-oss repo-update-non-oss"
		[[ "$MMCI_OS_VERSION_ID" =~ 15\.[3|4] ]] && DEFAULT_REPOS="$DEFAULT_REPOS repo-sle-update repo-backports-update"
		;;
	"sles")
		;;
esac
VIRTDEV_REPOS="$DEFAULT_REPOS virt-devel"

case "$1" in
	"virt-devel")
		setup_repos $VIRTDEV_REPOS
		;;
	*)
		setup_repos $DEFAULT_REPOS
		# Catches "default" as well
		;;
esac
update_OS

# FIXME: Move this into its own setups/install_kvm_rpms.sh base|all
#KVM_INSTALL_BASE="qemu-x86 tftp libvirt-daemon-qemu virt-install libvirt-client libvirt-daemon-config-network tigervnc virt-manager vm-install"
KVM_INSTALL_ALL_PATTERNS="kvm_server kvm_tools"
$MMCI_PACKAGES_PATTERNS_INSTALL $KVM_INSTALL_ALL_PATTERNS

log "DONE install-rpms.sh"

exit 0
