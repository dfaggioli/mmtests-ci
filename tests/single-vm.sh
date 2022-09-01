#!/bin/bash -x

echo $@

systemctl enable --now libvirtd

prepare_mmtests

exit 0
