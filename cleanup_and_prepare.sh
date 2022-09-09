#!/bin/bash -x

systemctl disable --now mmci
rm /etc/systemd/system/mmci.service
systemctl daemon-reload

# FIXME: All these names should come from config...
pushd /root
rm -f mmci_pause mmci_term mmci_curr_step.sh mmci_next_step.sh mmci_step.sh mmci.service
rm -f install_and_start.sh
rm -rf mmtests-ci
rm -rf mmtests
rm -rf mmci-logs
echo "Opportunities of further cleanups:"
echo " rm -rf mmci-results"
echo " rm -rf qemu"
popd

wget https://raw.githubusercontent.com/dfaggioli/mmtests-ci/main/install_and_start.sh
chmod +x install_and_start.sh
exit 0
