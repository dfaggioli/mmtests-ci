#!/bin/bash

PACKAGES="
    bc \
    brlapi-devel \
    bzip2 \
    ccache \
    cyrus-sasl-devel \
    gcc \
    gcc-c++ \
    mkisofs \
    gettext-runtime \
    git \
    glib2-devel \
    glusterfs-devel \
    libgnutls-devel \
    gtk3-devel \
    libaio-devel \
    libattr-devel \
    libcap-ng-devel \
    libepoxy-devel \
    libfdt-devel \
    libiscsi-devel \
    libjpeg8-devel \
    libpmem-devel \
    libpng16-devel \
    librbd-devel \
    libseccomp-devel \
    libssh-devel \
    lzo-devel \
    make \
    libSDL2_image-devel \
    ncurses-devel \
    ninja \
    libnuma-devel \
    perl \
    libpixman-1-0-devel \
    python3-base \
    python3-virtualenv \
    rdma-core-devel \
    libSDL2-devel \
    snappy-devel \
    libspice-server-devel \
    systemd-devel \
    systemtap-sdt-devel \
    tar \
    usbredir-devel \
    virglrenderer-devel \
    xen-devel \
    vte-devel \
    zlib-devel
"

zypper ref
zypper --non-interactive dup --allow-vendor-change
zypper --non-interactive install $PACKAGES
