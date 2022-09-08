#!/bin/bash -x

#[ -z "$DIR" ] && export DIR="/root"
#[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
#. "${MMCI_DIR}/common.sh"

log "STARTING reboot_to_next_os_step.sh"

log " Reinstate original repositories configuration"
if [ "$MMCI_PACKAGE_MANAGER" == "zypper" ]; then
	if [ -d "${MMCI_HOSTDIR}/repos.d-backup" ]; then
		rm -rf /etc/zypp/repos.d
		mv "${MMCI_HOSTDIR}/repos.d-backup" /etc/zypp/repos.d
	fi
else
	log "WARNING: Only zypper based-distros are currently supported"
fi
update_OS

# Here we want to tweak GRUB (or whatever) to make sure that we will boot in
# the "next" OS that we want to test on this host (if any, of course)!
#
# Since every (partition on every) machine may potential have its own way
# of doing such, rely on them for providing it. That is, we just import steps
# that we expect to find in the machine-&-partition specific configuration
# files, where testplans also are (if not, we just reboot).
[[ -f "${MMCI_HOSTDIR}/next_os" ]] . "${MMCI_HOSTDIR}/next_os"

# Done! the update_all_step.sh script will be run again, on this OS, when
# we will be back here, in this partition.
sleep 300

log "DONE reboot_to_next_os_step.sh"

cp -a "${MMCI_DIR}/update_all_step.sh" "${DIR}/mmci_next_step.sh"
reboot

exit 0
