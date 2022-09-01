#!/bin/bash -x

log "STARTING official_rpms_setup.sh (args: $@)"

set_default_repos
update_OS

# FIXME: Move this into its own setups/install_kvm_rpms.sh base|all
#KVM_INSTALL_BASE="qemu-x86 tftp libvirt-daemon-qemu virt-install libvirt-client libvirt-daemon-config-network tigervnc virt-manager vm-install"
KVM_INSTALL_ALL_PATTERNS="kvm_server kvm_tools"
$MMCI_PACKAGES_INSTALL -t pattern --recommends $KVM_INSTALL_ALL_PATTERNS

log "DONE official_rpms_setup.sh"

exit 0
