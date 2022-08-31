#!/bin/bash

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"

OS_RELEASE="/etc/os-release"
if [ ! -f "$OS_RELEASE" ]; then
	echo "ERROR: cannot find $OS_RELEASE"
	exit 1
fi

function get_os_name() {
	local NAME=""

	NAME="$(cat $OS_RELEASE | grep ^NAME | cut -f2 -d'=')"
	export MMCI_OS_NAME="$NAME"
}

function get_os_id() {
	local ID=""

	ID="$(cat $OS_RELEASE | grep ^ID= | cut -f2 -d'=')"
	export MMCI_OS_ID="$ID"
}

function get_os_release() {
	local VERSION=""
	local VERSION_ID=""

	if [ -z "$MMCI_OS_NAME" ]; then
		get_os_name
	fi

	if [ -z "$MMCI_OS_ID" ]; then
		get_os_id
	fi

	#if [[ "$MMCI_OS_NAME" == "SLES" ]]; then
	#	VERSION="$(cat $OS_RELEASE | grep ^VERSION=)"
	#elif [[ "$MMCI_OS_NAME" =~ .*Tumbleweed ]]; then
	#	VERSION="$(cat $OS_RELEASE | grep ^VERSION | cut -f2 -d'=')"
	#fi
	if [ -z "$MMCI_OS_VERSION" ]; then
		VERSION="$(cat $OS_RELEASE | grep VERSION= | cut -f2 -d'=')"
		VERSION_ID="$(cat $OS_RELEASE | grep ^VERSION_ID= | cut -f2 -d'=')"
		export MMCI_OS_VERSION="$VERSION"
		export MMCI_OS_VERSION_ID="$VERSION_ID"
	fi
}

get_os_release

# By default we read ./ci-config, unless MMCI_CONFIGS is defined.
function read_configs() {
	# FIXME: Turn this list of paths into something that makes sense!
	MMCI_CONFIGS="${MMCI_DIR}/ci-config ${MMCI_HOSTDIR}/ci-config ./ci-config $MMCI_CONFIGS"
	for C in $MMCI_CONFIGS
	do
		if [ ! -e "$C" ]; then
			echo "WARNING: config file $C not found"
		else
			source "$C"
		fi
	done
}

# For all the scripts, we want to import the configuration files.
read_configs

# Some default values, used if we don't find them in the environment or in the config files.
[ -z "$MMCI_PACKAGE_MANAGER" ] && export MMCI_PACKAGE_MANAGER=zypper
if [ "$MMCI_PACKAGE_MANAGER" == "zypper" ]; then
	[ -z "$MMCI_PACKAGES_REFRESH" ] && export MMCI_PACKAGES_REFRESH="$MMCI_PACKAGE_MANAGER ref"
	[ -z "$MMCI_REPO_ALLOW_VENDOR_CHANGE" ] && export MMCI_REPO_ALLOW_VENDOR_CHANGE="no"
	[ "$MMCI_REPO_ALLOW_VENDOR_CHANGE"  == "yes" ] && VENDOR_CHANGE="--allow-vendor-change"
	[ -z "$MMCI_PACKAGE_MANAGER_CMD" ] && export MMCI_PACKAGE_MANAGER_CMD="$MMCI_PACKAGE_MANAGER --non-interactive --gpg-auto-import-keys $VENDOR_CHANGE"
	[ -z "$MMCI_PACKAGES_INSTALL" ] && export MMCI_PACKAGES_INSTALL="$MMCI_PACKAGE_MANAGER_CMD install --auto-agree-with-licenses --force-resolution --allow-downgrade"
	if [ -z "$MMCI_PACKAGES_UPDATE" ]; then
		if [[ "$MMCI_OS_ID" =~ .*tumbleweed.* ]]; then
			export MMCI_PACKAGES_UPDATE="$MMCI_PACKAGE_MANAGER_CMD dup --allow-downgrade --force-resolution --auto-agree-with-licenses"
		else
			export MMCI_PACKAGES_UPDATE="$MMCI_PACKAGE_MANAGER_CMD up --allow-downgrade --force-resolution --auto-agree-with-licenses"
		fi
	fi
fi

[ -z "$MMCI_MMTESTS_REPO" ] && export MMCI_MMTESTS_REPO=https://github.com/gormanm/mmtests.git
[ -z "$MMCI_MMTESTS_BRANCH" ] && export MMCI_MMTESTS_BRANCH=master
[ -z "$MMCI_MMTESTS_DIR" ] && export MMCI_MMTESTS_DIR="${DIR}/mmtests"

[ -z "$MMCI_LOGDIR" ] && export MMCI_LOGDIR="${DIR}/mmci_logs"
mkdir -p "$MMCI_LOGDIR"

[ -z "$MMCI_RESULTS_DIR" ] && export MMCI_RESULTS_DIR="${DIR}/mmci_results"
mkdir -p "$MMCI_RESULTS_DIR"

# TODO: syntax alias@ULR-regexp
if [ -z "$Tumbleweed_REPOS" ]; then
	export Tumbleweed_REPOS="
repo-oss@http://download.opensuse.org/tumbleweed/repo/oss/
repo-update@http://download.opensuse.org/update/tumbleweed/
repo-non-oss@http://download.opensuse.org/tumbleweed/repo/non-oss/
"
#virt-devel@https://download.opensuse.org/repositories/Virtualization/openSUSE_Tumbleweed/
fi

if [ -z "$Leap154_REPOS" ]; then
	export Leap154_REPOS="
repo-backports-update@http://download.opensuse.org/update/leap/15.4/backports/
repo-non-oss@http://download.opensuse.org/distribution/leap/15.4/repo/non-oss/
repo-oss@http://download.opensuse.org/distribution/leap/15.4/repo/oss/
repo-sle-update@http://download.opensuse.org/update/leap/15.4/sle/
repo-update@http://download.opensuse.org/update/leap/15.4/oss/
repo-update-non-oss@http://download.opensuse.org/update/leap/15.4/non-oss/
"
fi

if [ -z "$Leap153_REPOS" ]; then
	export Leap153_REPOS="
repo-backports-update@http://download.opensuse.org/update/leap/15.3/backports/
repo-non-oss@http://download.opensuse.org/distribution/leap/15.3/repo/non-oss/
repo-oss@http://download.opensuse.org/distribution/leap/15.3/repo/oss/
repo-sle-update@http://download.opensuse.org/update/leap/15.3/sle/
repo-update@http://download.opensuse.org/update/leap/15.3/oss/
repo-update-non-oss@http://download.opensuse.org/update/leap/15.3/non-oss/
"
fi

if [ -z "$Leap152_REPOS" ]; then
	export Leap152_REPOS="
repo-non-oss@http://download.opensuse.org/distribution/leap/15.2/repo/non-oss/
repo-oss@http://download.opensuse.org/distribution/leap/15.2/repo/oss/
repo-update@http://download.opensuse.org/update/leap/15.2/oss/
repo-update-non-oss@http://download.opensuse.org/update/leap/15.2/non-oss/
"
fi

# TODO: Move to internal?
if [ -z "$SLES15SP2_REPOS" ]; then
	export SLES15SP2_REPOS="
server-product@http://ibs-mirror.prv.suse.net/ibs/SUSE/Products/SLE-SERVER/12-SP5/x86_64/product
server-update@http://ibs-mirror.prv.suse.net/ibs/SUSE/Updates/SLE-SERVER/12-SP5/x86_64/update
sdk-product@http://ibs-mirror.prv.suse.net/ibs/SUSE/Products/SLE-SDK/12-SP5/x86_64/product
sdk-update@http://ibs-mirror.prv.suse.net/ibs/SUSE/Updates/SLE-SDK/12-SP5/x86_64/update
"
#virt-devel@http://download.suse.de/ibs/Devel:/Virt:/SLE-12-SP5/SUSE_SLE-12-SP5_Update_standard
fi

# If PackageKit is there (which hopefully isn't the case) get rid of it
# TODO: Find a better way to do this!
function kill_packagekit() {
	killall -9 gnome-software
	killall -9 packagekitd
	systemctl disable --now packagekit
	systemctl disable --now packagekit-offline-update
	systemctl disable --now packagekit-background.service
	systemctl disable --now packagekit-background.timer
}

function set_default_repos() {
	kill_packagekit
	if [ "$MMCI_PACKAGE_MANAGER" == "zypper" ]; then
		local VERSION=""

		if [ ! -d "${MMCI_HOSTDIR}/repos.d-backup" ]; then
			mv /etc/zypp/repos.d "${MMCI_HOSTDIR}/repos.d-backup"
		else
			rm -rf /etc/zypp/repos.d
		fi

		if [[ "$MMCI_OS_ID" =~ .*tumbleweed.* ]]; then
			REPOS=$Tumbleweed_REPOS
		elif [[ "$MMCI_OS_ID" =~ ".*leap.*" ]]; then
			VERSION=$(echo $MMCI_OS_VERSION | tr -d '.')
			eval "REPOS=\$Leap_${VERSION}"
		elif [[ "$MMCI_OS_ID" =~ .*sles.* ]]; then
			# TODO: Fetch SLE repo URLs from somewhere and import the vars here
			VERSION=$(echo $MMCI_OS_VERSION | tr -d '-')
			eval "REPOS=\$${MMCI_OS_NAME}${VERSION}"
		fi

		# TODO: Repo priority
		for R in $REPOS ; do
			RALIAS=$(echo $R | awk -F '@' '{print $1}')
			zypper ar -f "$(echo $R | awk -F '@' '{print $2}')" "$RALIAS"
		done
	fi
}
export -f set_default_repos

function update_OS() {
	kill_packagekit
	$MMCI_PACKAGES_REFRESH || exit 255
	$MMCI_PACKAGES_UPDATE || exit 255
}
export -f update_OS

function log() {
	echo "$(date +\"%D-%T): $(realpath $0): $@" >> ${MMCI_LOGDIR}/steps.log
}
export -f log
