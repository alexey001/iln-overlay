# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit toolchain-funcs

DESCRIPTION="Link programmer for STM8 devices"
HOMEPAGE="https://github.com/vdudouyt/stm8flash"
if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/vdudouyt/stm8flash.git"
	inherit git-r3
else
	SRC_URI=""
	KEYWORDS="~amd64"
	die "no releases yet"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="virtual/libusb:1"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile(){
	local PKG_CONFIG="$(tc-getPKG_CONFIG)"
	local CFLAGS="${CFLAGS} --std=gnu99 $(${PKG_CONFIG} --cflags libusb-1.0)"
	local LIBS="${LDFLAGS} $(${PKG_CONFIG} --libs libusb-1.0)"

	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LIBS="${LIBS}"
}

src_install() {
	dodir /usr/bin
	default
}
