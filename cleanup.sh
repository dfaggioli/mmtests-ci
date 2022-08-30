#!/bin/bash -x

systemctl disable --now mmci
rm /etc/systemd/system/mmci.service
systemctl daemon-reload

pushd /root
rm -f mmci_pause mmci_term mmci_curr_step.sh mmci_next_step.sh mmci_step.sh mmci.service
rm -f install_and_start.sh
rm -rf mmtests-ci
rm -rf mmtests
rm -rf mmci_logs
echo "For cleaning up results, do:"
echo "rm -rf mmci_results"
popd

wget https://raw.githubusercontent.com/dfaggioli/mmtests-ci/main/install_and_start.sh
chmod +x install_and_start.sh
exit 0
