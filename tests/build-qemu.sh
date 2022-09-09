#!/bin/bash -x


VER="$MMCI_BUILD_QEMU_VERSION"
CONFIG="default" # TODO: Make an MMCI_ config parameter for this

log "STARTING build-qemu.sh (args: $@)"

while true ; do
	if [[ "$1" == "--test" ]]; then
		TESTNAME=$2
		shift 2
	elif [[ "$1" == "--version" ]]; then
		VER=$2
		shift 2
	elif [[ "$1" == "--config" ]]; then
		CONFIG=$1
		shift 2
	elif [[ "$1" == "--check" ]]; then
		CHECK="yes"
		shift
	else
		break
	fi
done
# TESTGROUP (that we need in check_test.sh) is just build-qemu.
# FIXME: make it the actual name of this script (dinamically determining it)
TESTGROUP="build-qemu"

[[ "$MMCI_BUILD_QEMU_BUILD_BASE" ]] || MMCI_BUILD_QEMU_BUILD_BASE="${MMCI_BUILD_QEMU_DIR}/qemu-${VER}"
[[ "$MMCI_BUILD_QEMU_INSTALL_BASE" ]] || MMCI_BUILD_QEMU_INSTALL_BASE="${MMCI_BUILD_QEMU_DIR}/qemu-${VER}"
BUILD="${MMCI_BUILD_QEMU_BUILD_BASE}/build"
PREFIX="${MMCI_BUILD_QEMU_INSTALL_BASE}/install"
mkdir -p "$BUILD" "$PREFIX"

# Do we need to build, e.g., because something changed? Note that we also
# (re)build even if the check says we can skip, in case we (for whatever
# reason) don't have anything built that we can use.
${MMCI_DIR}/check_test.sh --testname "$TESTNAME" --testgroup "$TESTGROUP"
if [[ $? -ne 0 ]] && [[ -d "${PREFIX}/usr" ]]; then
	log "Skipping ${TESTNAME}: nothing changed since last run"
	# Exiting with !0 should mean we skipp all the other steps
	# for this test.
	exit 2
fi

# FIXME: About $BUILD, do the right thing, depending on $VER. E.g., if
#        it's a released version, no need to re-download, just clean!
#        If it's git-latest, no need to re-clone, just update. Etc.
rm -rf "${BUILD}/*" "${PREFIX}/*"
pushd "$BUILD"

case "$MMCI_PACKAGE_MANAGER" in
	"zypper")
		DEPS="${MMCI_DIR}/setups/qemu-build-deps"
		[[ -f "${MMCI_HOSTDIR}/qemu-build-deps" ]] && DEPS="${MMCI_HOSTDIR}/qemu-build-deps"
		[[ -f "${MMCI_HOSTDIR}/qemu-build-${VER}-deps" ]] && DEPS="${MMCI_HOSTDIR}/qemu-build-${VER}-deps"
		[[ -f $DEPS ]] && $MMCI_PACKAGES_INSTALL $(cat $DEPS)
		;;
esac

case "$VER" in
	"7.1.0" | "7.0.0" | "6.2.0")
		wget ${MMCI_BUILD_QEMU_URL_BASE}/qemu-${VER}.tar.xz
		tar xf qemu-${VER}.tar.xz
		cd "qemu-${VER}"
		;;
	"git-*")
		# FIXME: Right now, we're always clone master and go with it
		HASH="$(echo $VER | cut -f2 -d'-')"
		# TODO: actually support arbitrary hases (we might need to remove --single-branch)
		# TODO: detect if HASH is a tag, and support that as well
		git clone --single-branch --branch $MMCI_BUILD_QEMU_BRANCH $MMCI_BUILD_QEMU_REPO qemu-git-$HASH
		cd qemu-git-$HASH
		git submodule init
		git submodule update --recursive
		;;
	*)
esac

# Configure
case "$CONFIG" in
	"default")
		./configure --prefix=${PREFIX}/usr --firmwarepath=${PREFIX}/usr/share/qemu --libdir=${PREFIX}/usr/lib64 --libexecdir=${PREFIX}/usr/libexec --localstatedir=${PREFIX}/var --sysconfdir=${PREFIX}/etc
		;;
	"opensuse-tumbleweed-pkg")
		# FIXME: Put this mess in a config file!
		./configure --docdir=${PREFIX}/usr/share/doc/packages '--extra-cflags=-O2 -Wall -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -fstack-protector-strong -funwind-tables -fasynchronous-unwind-tables -fstack-clash-protection -Werror=return-type -flto=auto -g' --firmwarepath=${PREFIX}/usr/share/qemu --libdir=${PREFIX}/usr/lib64 --libexecdir=${PREFIX}/usr/libexec --localstatedir=${PREFIX}/var --prefix=${PREFIX}/usr --sysconfdir=${PREFIX}/etc --with-git-submodules=ignore '--with-pkgversion=Virtualization / openSUSE_Tumbleweed' --python=/usr/bin/python3 --disable-alsa --disable-attr --disable-auth-pam --disable-avx2 --disable-avx512f --disable-block-drv-whitelist-in-tools --disable-bochs --disable-bpf --disable-brlapi --disable-bsd-user --disable-bzip2 --disable-cap-ng --disable-capstone --disable-cfi --disable-cfi-debug --disable-cloop --disable-cocoa --disable-coreaudio --disable-coroutine-pool --disable-crypto-afalg --disable-curl --disable-curses --disable-dbus-display --disable-debug-info --disable-debug-mutex --disable-debug-tcg --disable-dmg --disable-docs --disable-dsound --disable-fdt --disable-fuse --disable-fuse-lseek --disable-fuzzing --disable-gcrypt --disable-gettext --disable-gio --disable-glusterfs --disable-gnutls --disable-gtk --disable-guest-agent --disable-guest-agent-msi --disable-hax --disable-hax --disable-hvf --disable-hvf --disable-iconv --disable-iconv --disable-install-blobs --disable-jack --disable-kvm --disable-kvm --disable-l2tpv3 --disable-libdaxctl --disable-libiscsi --disable-libnfs --disable-libpmem --disable-libssh --disable-libudev --disable-libusb --disable-linux-aio --disable-linux-io-uring --disable-linux-user --disable-live-block-migration --disable-lto --disable-lzfse --disable-lzo --disable-malloc-trim --disable-membarrier --disable-module-upgrades --disable-modules --disable-mpath --disable-multiprocess --disable-netmap --disable-nettle --disable-numa --disable-nvmm --disable-opengl --disable-oss --disable-pa --disable-parallels --disable-pie --disable-plugins --disable-pvrdma --disable-qcow1 --disable-qed --disable-qom-cast-debug --disable-rbd --disable-rdma --disable-replication --disable-rng-none --disable-safe-stack --disable-sanitizers --disable-sdl --disable-sdl-image --disable-seccomp --disable-selinux --disable-slirp --disable-slirp-smbd --disable-smartcard --disable-snappy --disable-sparse --disable-spice --disable-spice-protocol --disable-stack-protector --disable-strip --disable-system --disable-tcg --disable-tcg-interpreter --disable-tools --disable-tpm --disable-u2f --disable-usb-redir --disable-user --disable-vde --disable-vdi --disable-vhost-crypto --disable-vhost-kernel --disable-vhost-net --disable-vhost-scsi --disable-vhost-user --disable-vhost-user-blk-server --disable-vhost-user-fs --disable-vhost-vdpa --disable-vhost-vsock --disable-virglrenderer --disable-virtfs --disable-virtiofsd --disable-vnc --disable-vnc-jpeg --disable-vnc-png --disable-vnc-sasl --disable-vte --disable-vvfat --disable-werror --disable-whpx --disable-whpx --disable-xen --disable-xen-pci-passthrough --disable-xkbcommon --disable-zstd --without-default-devices --enable-lto --disable-linux-user --enable-libpmem --enable-xen --enable-xen-pci-passthrough --enable-numa --enable-kvm --enable-libdaxctl --enable-linux-io-uring --enable-rbd --enable-alsa --enable-attr --enable-bochs --enable-brlapi --enable-bzip2 --enable-cap-ng --enable-cloop --enable-coroutine-pool --enable-curl --enable-curses --enable-dbus-display --enable-dmg --enable-docs --enable-fdt --enable-gcrypt --enable-gettext --enable-gio --enable-glusterfs --enable-gnutls --enable-gtk --enable-guest-agent --enable-iconv --enable-install-blobs --enable-jack --enable-l2tpv3 --enable-libiscsi --enable-libnfs --enable-libssh --enable-libudev --enable-libusb --enable-linux-aio --enable-live-block-migration --enable-lzfse --enable-lzo --enable-modules --enable-mpath --enable-opengl --enable-oss --enable-pa --enable-parallels --enable-pie --enable-pvrdma --enable-qcow1 --enable-qed --enable-rdma --enable-replication --enable-seccomp --enable-selinux --enable-slirp-smbd --enable-slirp=system --enable-smartcard --enable-snappy --enable-spice --enable-spice-protocol --enable-system --enable-tcg --enable-tools --enable-tpm --enable-usb-redir --enable-vde --enable-vdi --enable-vhost-crypto --enable-vhost-kernel --enable-vhost-net --enable-vhost-scsi --enable-vhost-user --enable-vhost-user-blk-server --enable-vhost-user-fs --enable-vhost-vdpa --enable-vhost-vsock --enable-virglrenderer --enable-virtfs --enable-virtiofsd --enable-vnc --enable-vnc-jpeg --enable-vnc-png --enable-vnc-sasl --enable-vte --enable-vvfat --enable-werror --enable-xkbcommon --enable-zstd --with-default-devices \
		;;
esac
if [[ $? -eq 0 ]]; then
	rm -rf "${BUILD}/*" "${PREFIX}/*"
	fail "Configure script failed for QEMU $VER during test $TESTNAME"
fi

# Build
JOBS=$(grep -c '^processor' /proc/cpuinfo)
make -O -j $JOBS V=1 VERBOSE=1
[[ $? -eq 0 ]] || fail "Build failed for QEMU $VER during test $TESTNAME"
if [[ $? -eq 0 ]]; then
	rm -rf "${BUILD}/*" "${PREFIX}/*"
	fail "Build failed for QEMU $VER during test $TESTNAME"
fi

# Check
if [[ "$MMCI_BUILD_QEMU_MAKE_CHECK" != "yes" ]] && return
	make check V=1 VERBOSE=1
	# TODO: Make a switch for making make-check failures fatal
	[[ $? -eq 0 ]] || log "WARNING: Build checks failed for QEMU $VER during test $TESTNAME"
fi

# Install
make -j $JOBS install V=1 VERBOSE=1
if [[ $? -eq 0 ]]; then
	rm -rf "${BUILD}/*" "${PREFIX}/*"
	fail "Install failed for QEMU $VER during test $TESTNAME"
fi

popd

log "DONE build-qemu.sh"

# If we're here, the test is finished, and  we can call it as success.
# Since we called check_test.sh, let's inform "it" that we're done
# and that it went well.
${MMCI_DIR}/check_test.sh --testname "$TESTNAME" --testgroup "$TESTGROUP" --success
[[ $? -eq 0 ]] || fail "Something went very wrong when checking results..."

# FIXME: Only for debugging!
sleep 300

exit 0
