#!/bin/bash

[ -z "$DIR" ] && export DIR="/root"
[ -z "$MMCI_DIR" ] && export MMCI_DIR="${DIR}/mmtests-ci"
export MMCI_HOSTDIR="${MMCI_DIR}/$(hostname -s)"

# By default we read ./ci-config, unless MMCI_CONFIGS is defined.
function read_configs() {
	MMCI_CONFIGS="${MMCI_DIR}/ci-config ${MMCI_HOSTDIR}/ci-config $MMCI_CONFIGS"
	[ "$MMCI_CONFIGS" == "" ] && MMCI_CONFIGS="./ci-config"
	for C in "$MMCI_CONFIGS"
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
[ -z "$MMCI_PACKAGE_MANAGER" ] && export MMTESTS_PACKAGE_MANAGER=zypper
[ -z "$MMCI_PACKAGE_MANAGER_CMD" ] && export MMTESTS_PACKAGE_MANAGER_CMD="$MMCI_PACKAGE_MANAGER --non-interactive --gpg-auto-import-keys"
[ -z "$MMCI_PACKAGE_INSTALL" ] && export MMCI_PACKAGE_INSTALL="$MMCI_PACKAGE_MANAGER_CMD install -l --force-resolution"
[ -z "$MMCI_PACKAGES_UPDATE" ] && export MMCI_PACKAGES_UPDATE="$MMCI_PACKAGE_MANAGER_CMD dup"

[ -z "$MMCI_MMTESTS_REPO" ] && export MMCI_MMTESTS_REPO=https://github.com/gormanm/mmtests.git
[ -z "$MMCI_MMTESTS_BRANCH" ] && export MMCI_MMTESTS_BRANCH=master
[ -z "$MMCI_MMTESTS_DIR" ] && export MMCI_MMTESTS_DIR="~/mmtests"

[ -z "$MMCI_REPO_ALLOW_VENDOR_CHANGE" ] && export MMCI_REPO_ALLOW_VENDOR_CHANGE="yes"

[ -z "$MMCI_LOGDIR" ] && export MMCI_LOGDIR="${MMCI_DIR}/logs"
mkdir -p "$MMCI_LOGDIR"

function log() {
	echo "$(date +\"%D-%T): $(realpath $0): $@" >> ${MMCI_LOGDIR}/steps.log
}

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

function get_os_version() {
	local VERSION=""

	if [ -z "$MMCI_OS_NAME" ]; then
		get_os_name
	fi

	if [[ "$MMCI_OS_NAME" =~ "SLES$" ]]; then
		VERSION="$(cat $OS_RELEASE | grep ^VERSION)"
	elif [[ "$MMCI_OS_NAME" =~ ".*Tumbleweed" ]]; then
		VERSION="$(cat $OS_RELEASE | grep ^VERSION | cut -f2 -d'=')"
	fi
	export MMCI_OS_VERSION="$VERSION"
}

get_os_version
