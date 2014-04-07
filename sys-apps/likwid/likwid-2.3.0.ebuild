# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils toolchain-funcs versionator

MY_PV="$(get_version_component_range 1-2 ${PV})"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="A lightweight performance-oriented tool suite for x86 multicore environments"
HOMEPAGE="https://code.google.com/p/likwid/"
SRC_URI="https://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="+bench fortran gnuplot instrument mpi msrd +static"

DEPEND="dev-lang/perl"
RDEPEND="dev-lang/perl
	mpi? ( || ( sys-cluster/mvapich2 sys-cluster/openmpi ) )
	gnuplot? ( dev-lang/perl[ithreads] sci-visualization/gnuplot )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Make compiler output verbose
	sed -i 's:\(Q\s\+?=\s\+\)@:\1:' Makefile || die "Patch for compiler verbosity failed"

	# Respect user defined compiler environment
	sed -i -e "s:^\(CC\s\+\=\s\+\).*$:\1$(tc-getCC):" \
		-e "s:^\(FC\s\+\=\s\+\).*$:\1$(tc-getF77):" \
		-e "s:^\(AS\s\+\=\s\+\).*$:\1$(tc-getAS):" \
		-e "s:^\(AR\s\+\=\s\+\).*$:\1$(tc-getAR):" \
		include_GCC.mk || die "Forcing use of local compilers"
	sed -i 's:^\(CFLAGS\s\+\=\s\+\):#\1:' include_GCC.mk || die "Forcing use of local CFLAGS"

	# Make perl scripts optional
	sed -i 's:\(@cp\s\+-f\s\+perl/likwid-\)\*\(\s\+\$(PREFIX)/bin\):\1mpirun\2\n\t\1perfscope\2:' Makefile || die "Making perl scripts optional failed"

	# Fix make target for tests
	#sed -i 's/\(all:\s\+\)test-marker/\1testmarker/' test/Makefile || die "Fixing test Makefile failed"
}

src_configure() {
	if ! use mpi; then
		sed -i 's:@\(cp\s\+-f\s\+perl/likwid-mpirun\s\+\$(PREFIX)/bin\):@#\1:' Makefile || die "Removing mpirun failed"
	fi
	if use gnuplot; then
		# Fix path of feedGnuplot in likwid-perfscope
		sed -i "s:\./\(feedGnuplot\):\1:" "perl/likwid-perfscope" || die "Fixing feedGnuplot path failed"
	else
		sed -i 's:@\(cp\s\+-f\s\+perl/likwid-perfscope\s\+\$(PREFIX)/bin\):@#\1:' Makefile || die "Removing perfscope failed"
		sed -i 's:@\(cp\s\+-f\s\+perl/feedGnuplot\s\+\$(PREFIX)/bin\):@#\1:' Makefile || die "Removing feedGnuplot failed"
	fi

	# Change installation path of binaries
	sed -i 's:\(PREFIX\s\+=\s\+\)/usr/local\(#NO SPACE\):\1$(DESTDIR)/usr\2:' config.mk || die "Patch for binary installation path failed"
	# Change installation path of documentation
	sed -i 's:\(MANPREFIX\s\+=\s\+\)\$(PREFIX)/man\(#NO SPACE\):\1$(PREFIX)/share/man\2:' config.mk || die "Patch for documentation installation path failed"

	# Optionally enable shared library
	if ! use static; then
		sed -i 's:\(SHARED_LIBRARY\s\+=\s\+\)NO\(#NO SPACE\):\1YES\2:' config.mk || die "Enabling shared library failed"
	fi
	# Optionally enable fortran module
	if use fortran; then
		sed -i 's:#\(FORTRAN_INTERFACE\s\+=\s\+likwid\.mod\):\1:' config.mk || die "Enabling fortran module failed"
	fi
	# Optionally build likwid-bench with marker API for likwid-perfctr
	if use instrument; then
		sed -i 's:#\(DEFINES\s\++=\s\+-DPERFMON\):\1:' include_GCC.mk include_ICC.mk || die "Enabling instrumentation failed"
	fi
	# Optionally enable communication with msr-daemon
	if use msrd; then
		sed -i -e 's:^\(MSRDAEMON\s\+=\s\+NO#NO SPACE\):#\1:' -e 's:^#\(MSRDAEMON\s\+=\s\+$(PREFIX)/bin/likwid-msrD#NO SPACE\):\1:' config.mk || die "Enabling msr daemon features failed"
	fi
}

src_compile() {
	# Parallel make fails
	emake -j1
	if use bench; then
		if use amd64; then
			emake -j1 likwid-bench || die
		fi
	fi
	if use msrd; then
		cd "${S}/src/msr-daemon"
		emake -j1 || die
	fi
}
