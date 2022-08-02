#!/bin/bash

if [ $"$(id -u)" != "0" ]; then
	echo "ERROR: please, be root"
	exit 255
fi

DIR="/root"
if [ ! -d $DIR ]; then
	echo "ERROR: we need $DIR, and it's not there"
	exit 255
fi

cd $DIR
curl -o $DIR https://raw.githubusercontent.com/dfaggioli/mmtests-ci/main/mmci_step.sh
chmow +x mmci_step.sh

cat > /etc/systemd/system/mmci.service <<EOF
[Unit]
Description=MMTests CI step script
After=default.target

[Service]
User=root
Type=simple
RemainAfterExit=yes
ExecStart=/root/mmci_step.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target
EOF

# BEWARE: this will reboot the box and start the CI cycling!!!
#systemctl enable --now mmci
