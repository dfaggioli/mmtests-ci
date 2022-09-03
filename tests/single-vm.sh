#!/bin/bash -x

echo $@

start_libvirtd
prepare_mmtests

MONITORS="-m"
[[ "$MMCI_MMTESTS_RUN_MONITORS" == "no" ]] && MONITORS="-n"

pushd $MMCI_MMTESTS_DIR
./run-kvm.sh $MONITOR -L -C host-configs/config-2vm-4vcpu-4ram -L -c config BLA2
popd

exit 0
