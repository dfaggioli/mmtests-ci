#!/bin/bash

# Setup repos?
zypper ref

#FROM="--from xxx"
zypper --non-interactive install $FROM -t pattern kvm_server kvm_tools 
zypper --non-interactive dup --allow-vendor-change
