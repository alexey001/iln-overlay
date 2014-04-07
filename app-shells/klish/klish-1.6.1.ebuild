# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=4
inherit eutils
DESCRIPTION="CISCO-Like command line shell"
HOMEPAGE="http://code.google.com/p/klish"
SRC_URI="http://klish.googlecode.com/files/${P}.tar.bz2"
LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="+libxml2 debug"

# A space delimited list of portage features to restrict. man 5 ebuild
# for details.  Usually not needed.
#RESTRICT="strip"


# Build-time dependencies, such as
#    ssl? ( >=dev-libs/openssl-0.9.6b )
#    >=dev-lang/perl-5.6.1-r1
# It is advisable to use the >= syntax show above, to reflect what you
# had installed on your system when you tested the package.  Then
# other users hopefully won't be caught without the right version of
# a dependency.
DEPEND=" libxml2? ( dev-libs/libxml2 )"

# Run-time dependencies. Must be defined to whatever this depends on to run.
# The below is valid if the same run-time depends are required to compile.
RDEPEND="${DEPEND}"

# Source directory; the dir where the sources can be found (automatically
# unpacked) inside ${WORKDIR}.  The default value for S is ${WORKDIR}/${P}
# If you don't need to change it, leave the S= line out of the ebuild
# to keep it tidy.
#S=${WORKDIR}/${P}



src_configure() {
	econf $(use_with libxml2) $(use_enable debug) --includedir=/usr/include/klish
}


src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	keepdir /etc/clish
	dodoc -r xml-examples
}
