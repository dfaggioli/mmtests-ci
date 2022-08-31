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

TMP_REPO_LIST=$(mktemp ./repo-list-XXXX)
zypper lr -p -u | grep ^[0-9]* | tr -d ' ' > "$TMP_REPO_LIST"

cat $TMP_REPO_LIST

for R in $REPOS ; do
	RALIAS=$(echo $R | awk -F '@' '{print $1}')
	RURI=$(echo $R | awk -F '@' '{print $2}')
	RCHECK=$(echo "$RURI" | sed 's/\./\\./g' | sed 's/\//\\\//g')

	while read -r RL ; do
		get_repo_data "$RL"
		if echo $RL | grep -E "${RCHECK}(\/){0,}(\?.*){0,}$" ; then
			echo si
			exit
		fi
	done < $TMP_REPO_LIST
done
exit

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
