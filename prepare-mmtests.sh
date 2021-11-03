#!/bin/bash

. common.sh

if [ -d "$MMCI_MMTESTS_DIR" ]; then
	echo "ERROR: target dir for MMTests exists already. Terminating"
	exit 1
fi

git clone --branch $MMCI_MMTESTS_BRANCH --single-branch $MMCI_MMTESTS_REPO "$MMCI_MMTESTS_DIR"
if [ $? -ne 0 ]; then
	echo "ERROR: cannot clone MMTests locally"
	exit 1
fi

pushd "$MMCI_MMTESTS_DIR"
./bin/generate-generic-configs
./bin/generate-nas.sh
./bin/generate-fs-configs

popd
exit 0
