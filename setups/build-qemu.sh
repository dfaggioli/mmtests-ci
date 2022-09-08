#!/bin/bash -x

log "STARTING build-qemu.sh (args: $@)"

VER="$MMCI_BUILD_QEMU_VERSION"
CONFIG="default" # TODO: Make an MMCI_ config parameter for this
PREFIX="$MMCI_BUILD_QEMU_INSTALL_PREFIX"
CHECK="no" # TODO: Make an MMCI_ config parameter for this
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
[[ "$PREFIX" ]] || PREFIX="${MMCI_BUILD_QEMU_DIR}/qemu-${VER}/install"

function configure() {
	case "$CONFIG" in
		"default")
			./configure --prefix=${PREFIX}/usr --firmwarepath=${PREFIX}/usr/share/qemu --libdir=${PREFIX}/usr/lib64 --libexecdir=${PREFIX}/usr/libexec --localstatedir=${PREFIX}/var --sysconfdir=${PREFIX}/etc
			;;
		"opensuse-tumbleweed-pkg")
			./configure --docdir=${PREFIX}/usr/share/doc/packages '--extra-cflags=-O2 -Wall -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -fstack-protector-strong -funwind-tables -fasynchronous-unwind-tables -fstack-clash-protection -Werror=return-type -flto=auto -g' --firmwarepath=${PREFIX}/usr/share/qemu --libdir=${PREFIX}/usr/lib64 --libexecdir=${PREFIX}/usr/libexec --localstatedir=${PREFIX}/var --prefix=${PREFIX}/usr --sysconfdir=${PREFIX}/etc --with-git-submodules=ignore '--with-pkgversion=Virtualization / openSUSE_Tumbleweed' --python=/usr/bin/python3 --disable-alsa --disable-attr --disable-auth-pam --disable-avx2 --disable-avx512f --disable-block-drv-whitelist-in-tools --disable-bochs --disable-bpf --disable-brlapi --disable-bsd-user --disable-bzip2 --disable-cap-ng --disable-capstone --disable-cfi --disable-cfi-debug --disable-cloop --disable-cocoa --disable-coreaudio --disable-coroutine-pool --disable-crypto-afalg --disable-curl --disable-curses --disable-dbus-display --disable-debug-info --disable-debug-mutex --disable-debug-tcg --disable-dmg --disable-docs --disable-dsound --disable-fdt --disable-fuse --disable-fuse-lseek --disable-fuzzing --disable-gcrypt --disable-gettext --disable-gio --disable-glusterfs --disable-gnutls --disable-gtk --disable-guest-agent --disable-guest-agent-msi --disable-hax --disable-hax --disable-hvf --disable-hvf --disable-iconv --disable-iconv --disable-install-blobs --disable-jack --disable-kvm --disable-kvm --disable-l2tpv3 --disable-libdaxctl --disable-libiscsi --disable-libnfs --disable-libpmem --disable-libssh --disable-libudev --disable-libusb --disable-linux-aio --disable-linux-io-uring --disable-linux-user --disable-live-block-migration --disable-lto --disable-lzfse --disable-lzo --disable-malloc-trim --disable-membarrier --disable-module-upgrades --disable-modules --disable-mpath --disable-multiprocess --disable-netmap --disable-nettle --disable-numa --disable-nvmm --disable-opengl --disable-oss --disable-pa --disable-parallels --disable-pie --disable-plugins --disable-pvrdma --disable-qcow1 --disable-qed --disable-qom-cast-debug --disable-rbd --disable-rdma --disable-replication --disable-rng-none --disable-safe-stack --disable-sanitizers --disable-sdl --disable-sdl-image --disable-seccomp --disable-selinux --disable-slirp --disable-slirp-smbd --disable-smartcard --disable-snappy --disable-sparse --disable-spice --disable-spice-protocol --disable-stack-protector --disable-strip --disable-system --disable-tcg --disable-tcg-interpreter --disable-tools --disable-tpm --disable-u2f --disable-usb-redir --disable-user --disable-vde --disable-vdi --disable-vhost-crypto --disable-vhost-kernel --disable-vhost-net --disable-vhost-scsi --disable-vhost-user --disable-vhost-user-blk-server --disable-vhost-user-fs --disable-vhost-vdpa --disable-vhost-vsock --disable-virglrenderer --disable-virtfs --disable-virtiofsd --disable-vnc --disable-vnc-jpeg --disable-vnc-png --disable-vnc-sasl --disable-vte --disable-vvfat --disable-werror --disable-whpx --disable-whpx --disable-xen --disable-xen-pci-passthrough --disable-xkbcommon --disable-zstd --without-default-devices --enable-lto --disable-linux-user --enable-libpmem --enable-xen --enable-xen-pci-passthrough --enable-numa --enable-kvm --enable-libdaxctl --enable-linux-io-uring --enable-rbd --enable-alsa --enable-attr --enable-bochs --enable-brlapi --enable-bzip2 --enable-cap-ng --enable-cloop --enable-coroutine-pool --enable-curl --enable-curses --enable-dbus-display --enable-dmg --enable-docs --enable-fdt --enable-gcrypt --enable-gettext --enable-gio --enable-glusterfs --enable-gnutls --enable-gtk --enable-guest-agent --enable-iconv --enable-install-blobs --enable-jack --enable-l2tpv3 --enable-libiscsi --enable-libnfs --enable-libssh --enable-libudev --enable-libusb --enable-linux-aio --enable-live-block-migration --enable-lzfse --enable-lzo --enable-modules --enable-mpath --enable-opengl --enable-oss --enable-pa --enable-parallels --enable-pie --enable-pvrdma --enable-qcow1 --enable-qed --enable-rdma --enable-replication --enable-seccomp --enable-selinux --enable-slirp-smbd --enable-slirp=system --enable-smartcard --enable-snappy --enable-spice --enable-spice-protocol --enable-system --enable-tcg --enable-tools --enable-tpm --enable-usb-redir --enable-vde --enable-vdi --enable-vhost-crypto --enable-vhost-kernel --enable-vhost-net --enable-vhost-scsi --enable-vhost-user --enable-vhost-user-blk-server --enable-vhost-user-fs --enable-vhost-vdpa --enable-vhost-vsock --enable-virglrenderer --enable-virtfs --enable-virtiofsd --enable-vnc --enable-vnc-jpeg --enable-vnc-png --enable-vnc-sasl --enable-vte --enable-vvfat --enable-werror --enable-xkbcommon --enable-zstd --with-default-devices \
			;;
	esac
	[[ $? -eq 0 ]] || fail "configure script failed for QEMU $VER"
}

function build() {
	make -O -j $(grep -c '^processor' /proc/cpuinfo) V=1 VERBOSE=1
	[[ $? -eq 0 ]] || fail "Build failed for QEMU $VER"
}

function check() {
	[[ "$CHECK" == "no" ]] && return
	make check V=1 VERBOSE=1
	# TODO: Make a switch for making make-check failures fatal
	[[ $? -eq 0 ]] || log "WARNING: Build checks failed for QEMU $VER"
}

function install() {
	make install
}

case "$MMCI_PACKAGE_MANAGER" in
	"zypper")
		DEPS=$(cat ${MMCI_DIS}/setups/qemu-build-deps)
		[[ -f "${MMCI_HOSTDIR}/qemu-build-deps" ]] && DEPS=$(cat "${MMCI_HOSTDIR}/qemu-build-deps")
		$MMCI_PACKAGES_INSTALL wget git-core tar $DEPS
		;;
esac

pushd "$MMCI_BUILD_QEMU_DIR"

mkdir -p qemu-${VER}/src qemu-${VER}/install
cd "qemu-${VER}/src"

case "$VER" in
	"7.1.0" | "7.0.0" | "6.2.0")
		wget https://download.qemu.org/qemu-${VER}.tar.xz
		tar xf qemu-${VER}.tar.xz
		cd "qemu-${VER}"
		;;
	"git-*")
		HASH="$(echo $VER | cut -f2 -d'-')"
		git clone $MMCI_BUILD_QEMU_REPO qemu-git-$HASH
		cd qemu-git-$HASH
		git submodule init
		git submodule update --recursive
		;;
	*)
esac

configure 
build
install

cd .. ; cd ..
pwd

popd

sleep 600

log "DONE build-qemu.sh"
exit 0
