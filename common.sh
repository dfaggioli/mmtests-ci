#!/bin/bash

pushd () {
	command pushd "$@" > /dev/null
}
export -f pushd

popd () {
	command popd "$@" > /dev/null
}
export -f popd

## Default values of some variables. They all can be overridden, just by
## having them defined in config files.
##
## Note that we rely on $DIR and $MMCI_DIR to be defined already. This happens
## in mmci_step.sh, before including this file, but can also be done by
## defining (and exporting them to the environment!) outside of any script (as
## mmci_step.sh does check if they're there already).
##
## Default values (go check them in mmci_step.sh) are:
## - DIR=$HOME
## - MMCI_DIR=${DIR}/mmtests-ci

# Generic parameters. See setup_host_dirs() for some more.
export MMCI_HOST_BASEDIR="$MMCI_DIR"
ROOT_PART=$(mount | grep -E '\s/\s' | cut -f1 -d' ')
export ROOT_PART=$(basename $ROOT_PART)
export MMCI_HOSTPATH="$(hostname -s)/${ROOT_PART}"
export MMCI_HOSTDIR="${MMCI_HOST_BASEDIR}/${MMCI_HOSTPATH}"
export MMCI_RESULTS_BASEDIR="${DIR}/mmci-results"
export MMCI_LOGDIR="${DIR}/mmci-logs"
export MMCI_OS_RELEASE_FILE="/etc/os-release"
export MMCI_TERM_FILE="${DIR}/mmci_term"
export MMCI_PAUSE_FILE="${DIR}/mmci_pause"
export MMCI_PAUSE_TIME=120

# Package management (there's more later, after we've read the config files)
# Syntax for repositories is:
# - one line for each repository
# - each line: alias@URL
# TODO: Add repo priority
export MMCI_PACKAGE_MANAGER="zypper"
export MMCI_PACKAGES_ALLOW_VENDOR_CHANGE="yes"
export MMCI_PACKAGES_FORCE_RECOMMENDS="yes"
export MMCI_PACKAGE_REPOS_TUMBLEWEED="
repo-oss@http://download.opensuse.org/tumbleweed/repo/oss/
repo-update@http://download.opensuse.org/update/tumbleweed/
repo-non-oss@http://download.opensuse.org/tumbleweed/repo/non-oss/
virt-devel@https://download.opensuse.org/repositories/Virtualization/openSUSE_Tumbleweed/
"
export MMCI_PACKAGE_REPOS_LEAP154="
repo-oss@http://download.opensuse.org/distribution/leap/15.4/repo/oss/
repo-update@http://download.opensuse.org/update/leap/15.4/oss/
repo-sle-update@http://download.opensuse.org/update/leap/15.4/sle/
repo-backports-update@http://download.opensuse.org/update/leap/15.4/backports/
repo-non-oss@http://download.opensuse.org/distribution/leap/15.4/repo/non-oss/
repo-update-non-oss@http://download.opensuse.org/update/leap/15.4/non-oss/
"
export MMCI_PACKAGE_REPOS_LEAP153="
repo-oss@http://download.opensuse.org/distribution/leap/15.3/repo/oss/
repo-update@http://download.opensuse.org/update/leap/15.3/oss/
repo-sle-update@http://download.opensuse.org/update/leap/15.3/sle/
repo-backports-update@http://download.opensuse.org/update/leap/15.3/backports/
repo-non-oss@http://download.opensuse.org/distribution/leap/15.3/repo/non-oss/
repo-update-non-oss@http://download.opensuse.org/update/leap/15.3/non-oss/
"
export MMCI_PACKAGE_REPOS_LEAP152="
repo-oss@http://download.opensuse.org/distribution/leap/15.2/repo/oss/
repo-update@http://download.opensuse.org/update/leap/15.2/oss/
repo-non-oss@http://download.opensuse.org/distribution/leap/15.2/repo/non-oss/
repo-update-non-oss@http://download.opensuse.org/update/leap/15.2/non-oss/
"
# FIXME: Move to an additional git repo!
#export MMCI_PACKAGE_REPOS_SLES15SP2="
#server-product@http://ibs-mirror.prv.suse.net/ibs/SUSE/Products/SLE-SERVER/12-SP5/x86_64/product
#server-update@http://ibs-mirror.prv.suse.net/ibs/SUSE/Updates/SLE-SERVER/12-SP5/x86_64/update
#sdk-product@http://ibs-mirror.prv.suse.net/ibs/SUSE/Products/SLE-SDK/12-SP5/x86_64/product
#sdk-update@http://ibs-mirror.prv.suse.net/ibs/SUSE/Updates/SLE-SDK/12-SP5/x86_64/update
#virt-devel@http://download.suse.de/ibs/Devel:/Virt:/SLE-12-SP5/SUSE_SLE-12-SP5_Update_standard
#"

# Other OS and services names and stuff
export MMCI_LIBVIRTD_SERVICE_NAME="libvirtd"

# MMTests related values
export MMCI_MMTESTS_REPO=https://github.com/gormanm/mmtests.git
export MMCI_MMTESTS_BRANCH=master
export MMCI_MMTESTS_DIR="${DIR}/mmtests"
export MMCI_MMTESTS_FORCE_MONITORS="no"

# Stuff specific to tests
export MMCI_BUILD_QEMU_DIR="${DIR}/qemu"
export MMCI_BUILD_QEMU_URL_BASE="https://download.qemu.org/"
export MMCI_BUILD_QEMU_REPO="https://gitlab.com/qemu-project/qemu.git"
export MMCI_BUILD_QEMU_BRANCH="master"
export MMCI_BUILD_QEMU_VERSION="7.1.0" # Any version, git-SOME_HASH, git-latest
export MMCI_BUILD_QEMU_MAKE_CHECK="no"

# XXX
function read_configs() {
	# FIXME: Turn this list of paths into something that makes sense!
	MMCI_CONFIGS="${MMCI_DIR}/ci-config ${DIR}/ci-config $MMCI_CONFIGS"
	for C in $MMCI_CONFIGS ; do [[ -f "$C" ]] && . "$C" ; done
}
read_configs

# FIXME: Switch to a "more elegant" way of writing to both console and logfile
function log() {
	LOG="$(date +\"%D-%T): $(realpath $0): $@"
	echo "$LOG" ; echo "$LOG" >> ${MMCI_LOGDIR}/steps.log
}
export -f log

function fail() {
	local MSG=$1
	local ERR=$2

	[[ $ERR ]] || ERR=1
	log "ERROR: $MSG"
	exit $ERR
}
export -f fail

# FIXME: Do we need to check if MMCI_OS_NAME, MMCI_OS_ID, etc are there,
#        maybe from config, before reading them? MMmm... not sure. What would
#        be the point, and the use case, of overriding these?
function get_os_name() {
	export MMCI_OS_NAME="$(cat $MMCI_OS_RELEASE_FILE | grep ^NAME | cut -f2 -d'=' | tr -d '"')"
}

function get_os_id() {
	export MMCI_OS_ID="$(cat $MMCI_OS_RELEASE_FILE | grep ^ID= | cut -f2 -d'=' | tr -d '"')"
}

function get_os_release() {
	[[ -f "$MMCI_OS_RELEASE_FILE" ]] || fail "Cannot find $MMCI_OS_RELEASE_FILE"
	[[ "$MMCI_OS_NAME" ]] || get_os_name
	[[ "$MMCI_OS_ID" ]] || get_os_id
	if [[ ! "$MMCI_OS_VERSION" ]]; then
		export MMCI_OS_VERSION="$(cat $MMCI_OS_RELEASE_FILE | grep VERSION= | cut -f2 -d'=')"
		export MMCI_OS_VERSION_ID="$(cat $MMCI_OS_RELEASE_FILE | grep ^VERSION_ID= | cut -f2 -d'=')"
	fi
}
get_os_release

# XXX
if [[ "$MMCI_PACKAGE_MANAGER" == "zypper" ]]; then
	if [[ "$MMCI_OS_ID" =~ .*microos$ ]]; then
		fail "Support for transactional-update not implemented (but coming soon)"
	fi
	[[ "$MMCI_PACKAGE_MANAGER_CMD" ]] || export MMCI_PACKAGE_MANAGER_CMD="$MMCI_PACKAGE_MANAGER --non-interactive --gpg-auto-import-keys"
	[[ "$MMCI_PACKAGES_REFRESH" ]] || export MMCI_PACKAGES_REFRESH="$MMCI_PACKAGE_MANAGER_CMD ref"
	[[ "$MMCI_PACKAGES_ALLOW_VENDOR_CHANGE" == "yes" ]] && VENDOR_CHANGE="--allow-vendor-change"
	[[ "$MMCI_PACKAGES_FORCE_RECOMMENDS" == "yes" ]] && RECOMMENDS="--recommends"
	[[ "$MMCI_PACKAGES_INSTALL" ]] || export MMCI_PACKAGES_INSTALL="$MMCI_PACKAGE_MANAGER_CMD install --auto-agree-with-licenses --force-resolution --allow-downgrade $VENDOR_CHANGE $RECOMMENDS"
	[[ "$MMCI_PACKAGES_PATTERNS_INSTALL" ]] || export MMCI_PACKAGES_PATTERNS_INSTALL="$MMCI_PACKAGES_INSTALL -t pattern"
	[[ "$MMCI_PACKAGES_UPDATE" ]] || export MMCI_PACKAGES_UPDATE="$MMCI_PACKAGE_MANAGER_CMD dist-upgrade --auto-agree-with-licenses --force-resolution --allow-downgrade $VENDOR_CHANGE $RECOMMENDS"
	# TODO: Do we need a 'zypper up' variant of the above for Leap and SLE ?
	[[ $MMCI_PACKAGES_KVM_INSTALL_ALL_PATTERNS ]] || export MMCI_PACKAGES_KVM_INSTALL_ALL_PATTERNS="kvm_server kvm_tools"
	[[ $MMCI_PACKAGES_KVM_INSTALL_BASE_PACKAGES ]] || export MMCI_PACKAGES_KVM_INSTALL_BASE_PACKAGES="qemu-x86 tftp libvirt-daemon-qemu virt-install libvirt-client libvirt-daemon-config-network tigervnc virt-manager vm-install"
fi

# If PackageKit is there (which hopefully isn't the case) get rid of it
# FIXME: Maybe find a better way to do this ?
function kill_packagekit() {
	killall -9 gnome-software
	killall -9 packagekitd
	systemctl disable --now packagekit
	systemctl disable --now packagekit-offline-update
	systemctl disable --now packagekit-background.service
	systemctl disable --now packagekit-background.timer
}
export -f kill_packagekit

# XXX Explain logic and arguments
function add_repos() {
	local REPO_LIST=$@

	kill_packagekit
	if [ "$MMCI_PACKAGE_MANAGER" == "zypper" ]; then
		local NAME=""
		local VERSION=""
		local REPOS=""
		local RALIAS=""
		local RURL=""
		local DEFAULT_REPOS=""

		# Backup existing repositories, but do it just once
		# (hopefully, when the MMCI is started first on this OS)
		if [ ! -d "${MMCI_HOSTDIR}/repos.d-backup" ]; then
			mv /etc/zypp/repos.d "${MMCI_HOSTDIR}/repos.d-backup"
			mkdir /etc/zypp/repos.d
		else
			rm -rf /etc/zypp/repos.d/*
		fi

		NAME=$(echo $MMCI_OS_NAME | awk '{print $NF;}' | tr [a-z] [A-Z])
		if [[ "$NAME" == "TUMBLEWEED" ]]; then
			REPOS=$MMCI_PACKAGE_REPOS_TUMBLEWEED
			DEFAULT_REPOS="repo-oss repo-update repo-non-oss"
		else
			VERSION=$(echo $MMCI_OS_VERSION | tr -d '.')
			eval "REPOS=\$MMCI_PACKAGE_REPOS_${NAME}${VERSION}"
			if [[ "$NAME" == "LEAP" ]]; then
				DEFAULT_REPOS="repo-oss repo-update repo-non-oss repo-update-non-oss"
				[[ "$MMCI_OS_VERSION_ID" =~ 15\.[3|4] ]] && DEFAULT_REPOS="$DEFAULT_REPOS repo-sle-update repo-backports-update"
			else
				# I.e., SLE
				log "WARNING: SLE Support not implemented yet"
			fi
		fi

		REPO_LIST=$(echo $REPO_LIST | sed "s/default/$DEFAULT_REPOS/")
		for R in $REPO_LIST ; do
			if [[ "$R" =~ .*\@(https?|ftp|file)://.* ]]; then
				# This element is a "repo-spec" (see above)
				RALIAS=$(echo $R | awk -F '@' '{print $1}')
				RURL=$(echo $R | awk -F '@' '{print $2}')
			elif [[ "$R" =~ (https?|ftp|file)://.* ]] && curl --head --silent --fail $R &> /dev/null; then
				# This element is just an URL
				RALIAS=$(mktemp /etc/zypp/repos.d/repo-XXXX-XXXX-XXX)
				RURL=$R
			else
				# Last chance: it must be an alias that  we can
				# use as an index in the repos "array" defined
				# above for each distro.
				RR=$(grep  -E "\b${R}\@" <<< $REPOS | head -1)
				[[ ! $RR ]] && continue
				RALIAS=$(echo $RR | awk -F '@' '{print $1}')
				RURL=$(echo $RR | awk -F '@' '{print $2}')
			fi
			zypper ar -f "$RURL" "$RALIAS"
		done
	fi
}
export -f add_repos

function update_OS() {
	kill_packagekit
	$MMCI_PACKAGES_REFRESH || fail "Cannot refresh packages"
	$MMCI_PACKAGES_UPDATE || fail "Cannot update packages"
}
export -f update_OS

function start_libvirtd() {
	local CONN=$1 # connection string (optional)

	# TODO: Maybe check if it's running already
	systemctl start $MMCI_LIBVIRTD_SERVICE_NAME || fail "Cannot start libvirtd service. Skipping test..."
	command -v virsh &> /dev/null || fail "virsh command not found. Skipping test..."
	virsh -v &> /dev/null || fail "Libvirt daemon not reachable. Skipping test..."
}
export -f start_libvirtd

function prepare_mmtests() {
	pushd $MMCI_MMTESTS_DIR || fail "Cannot reach MMTests directory"
	./bin/generate-generic-configs
	./bin/generate-nas.sh
	./bin/generate-fs-configs
	./bin/generate-localmachine-host-configs
	popd
}
export -f prepare_mmtests

function fetch_mmtests_config() {
	local PREFIX=""
	local CONFIG=""

	if [[ "$1" == "-h" ]]; then
		PREFIX="host-"
		shift
	fi
	CONFIG="$1"
	shift

	if [[ -f "${MMCI_HOSTDIR}/${CONFIG}" ]]; then
		echo "${MMCI_HOSTDIR}/${CONFIG}"
	elif [[ -f "${MMCI_DIR}/${PREFIX}configs/${CONFIG}" ]]; then
		echo "${MMCI_DIR}/${PREFIX}configs/${CONFIG}"
	elif [[ -f "${MMCI_MMTESTS_DIR}/${PREFIX}configs/${CONFIG}" ]]; then
		echo "${MMCI_MMTESTS_DIR}/${PREFIX}configs/${CONFIG}"
	elif [[ -f "${MMCI_MMTESTS_DIR}/${CONFIG}" ]]; then
		echo "${MMCI_MMTESTS_DIR}/${PREFIX}${CONFIG}"
	else
		echo ""
	fi
}
export -f fetch_mmtests_config

