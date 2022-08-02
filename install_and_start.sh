#!/bin/bash -x

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
curl -o ${DIR}/mmci_step.sh https://raw.githubusercontent.com/dfaggioli/mmtests-ci/main/mmci_step.sh
chmod +x ${DIR}/mmci_step.sh

cat > ${DIR}/mmci.service <<EOF
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

cp ${DIR}/mmci.service /etc/systemd/system/
systemctl daemon-reload
# BEWARE: this will reboot the box and start the CI cycling!!!
#systemctl enable --now mmci
echo -e "Now do:\nsystemctl enable --now mmci"

exit 0
