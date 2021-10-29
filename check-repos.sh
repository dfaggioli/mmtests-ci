#!/bin/bash
#set -euo pipefail

# Write an update string into the job_running file.
# TODO: Put this in Jenkins' pipeline file?
#echo `date` $1 >> /var/jenkins/job_running

# TODO: Factor these out in a common script
ZYPP_IN="zypper --non-interactive --gpg-auto-import-keys innstall -l --force-resolution"
ZYPP_REF="zypper --gpg-auto-import-keys --non-interactive ref"

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

function get_os_version ()
{
	if [[ "$NAME" =~ "SLES$" ]]; then
		eval "$(cat /etc/os-release | grep ^VERSION)"
	elif [[ "$NAME" =~ ".*Tumbleweed" ]]; then
		eval "VERSION=$(cat /etc/os-release | grep ^VERSION | cut -f2 -d'=')"
	else
		echo ""
	fi
}

NAME=
DISTRO=
eval "$(cat /etc/os-release | grep ^NAME)"
if [[ "$NAME" =~ SLES$ ]]; then
	DISTRO="SLES"
	if [ -z "$CHECK_REPOS" ]; then
		CHECK_REPOS="
Devel:/Virt:@
"
	fi
	REPOS="
SLE-SERVER@product
SLE-SERVER@update
SLE-SDK@product
SLE-SDK@update
${CHECK_REPOS}
"
elif [[ "$NAME" =~ .*Tumbleweed$ ]]; then
	# TODO: And Leap too!
	DISTRO="TUMBLEWEED"
	if [ -z "$CHECK_REPOS" ]; then
		CHECK_REPOS="
download.opensuse.org/repositories/Virtualization@
"
	fi
	REPOS="
download.opensuse.org/tumbleweed@oss
download.opensuse.org/update@tumbleweed
${CHECK_REPOS}
"
fi
VERSION=$(get_os_version)

TMP_RP_LST=$(mktemp ./repo-list-XXXX)
zypper lr -p -u | grep ^[0-9]* | tr -d ' ' > "$TMP_RP_LST"

for R in $REPOS
do
	CHECK=$(echo $R | awk -F '@' '{print $1}' | sed 's/\./\\./g' | sed 's/\//\\\//g')
	END=$(echo $R | awk -F '@' '{print $2}' | sed 's/\./\\./g' | sed 's/\//\\\//g')
	[ -z "$END" ] && END='.*'
	REP=$(grep -E "${CHECK}.*\/(${END})(\/){0,}(\?.*){0,}$" "$TMP_RP_LST")
	if [ -z "$REP" ]; then
		echo "WARNING: No repository matching $R has been found"
		exit 1
	fi
	for RR in $REP
	do
		get_repo_data "$RR"
		if [ "$ENA" = "No" ]; then
			zypper mr -e $NR
		else
			echo "Repo $URI ($NR, $ALIAS) already on"
		fi
	done

done

rm -f "$TMP_RP_LST"
exit 0
