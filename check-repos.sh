#!/bin/bash -x
#set -euo pipefail

# Write an update string into the job_running file.
# TODO: Put this in Jenkins' pipeline file?
#echo `date` $1 >> /var/jenkins/job_running

. common.sh

NR=
ALIAS=
ENA=
PRIO=
URI=
function get_repo_data ()
{
	NR=$(echo "$1" | awk -F '|' '{print $1}' | tr -d ' ')
	ALIAS=$(echo "$1" | awk -F '|' '{print $2}' | tr -d ' ')
	ENA=$(echo "$1" | awk -F '|' '{print $4}' | tr -d ' ')
	PRIO=$(echo "$1" | awk -F '|' '{print $7}' | tr -d ' ')
	URI=$(echo "$1" | awk -F '|' '{print $8}' | tr -d ' ')
}

if [ -z "$MMCI_OS_NAME" ]; then
	get_os_version
fi

if grep -q "Tumbleweed" <<< "$MMCI_OS_NAME" ; then
	REPOS=$Tumbleweed_REPOS
elif grep -q "SLES" <<< "$MMCI_OS_NAME" ; then
	VERSION=$(echo $MMCI_OS_VERSION | tr -d '-')
	eval "REPOS=\$${MMCI_OS_NAME}${VERSION}"
fi
if [ -z "$REPOS" ]; then
	echo "WARNING: not configuring/checking any special repository"
	$MMCI_PACKAGE_REFRESH
	exit 0
fi

TMP_RP_LST=$(mktemp ./repo-list-XXXX)
zypper lr -p -u | grep ^[0-9]* | tr -d ' ' > "$TMP_RP_LST"

for R in $REPOS
do
	RALIAS=$(echo $R | awk -F '@' '{print $1}')
	RURI=$(echo $R | awk -F '@' '{print $2}')
	RCHECK=$(echo "$RURI" | sed 's/\./\\./g' | sed 's/\//\\\//g')
	RCHECK=$(grep -E "${RCHECK}(\/){0,}(\?.*){0,}$" "$TMP_RP_LST")
	if [ -z "$RCHECK" ]; then
		echo "WARNING: No repository matching $R has been found. Trying adding"
		zypper ar "$(echo $R | awk -F '@' '{print $2}')" "$RALIAS"
		if [ $? -ne 0 ]; then
			echo "ERROR: cannot add missing repo $R"
			exit 1
		fi
	fi
	for RR in $RCHECK
	do
		get_repo_data "$RR"
		if [ "$ENA" = "No" ]; then
			zypper mr -e $NR
		else
			echo "Repo $URI (alias $ALIAS) already on"
		fi
	done
done
rm -f "$TMP_RP_LST"

$MMCI_PACKAGE_REFRESH
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to refresh repositories"
	exit 1
fi

exit 0
