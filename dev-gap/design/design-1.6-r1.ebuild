# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The Design Package for GAP"
HOMEPAGE="http://www.gap-system.org/Packages/${PN}.html"
SLOT="4.10.0"
SRC_URI="https://www.gap-system.org/pub/gap/gap-$(ver_cut 1-2 ${SLOT})/tar.bz2/gap-${SLOT}.tar.bz2"

LICENSE="GPL-2+"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sci-mathematics/gap:${SLOT}
	dev-gap/grape:${SLOT}"

S="${WORKDIR}/gap-${SLOT}/pkg/${PN}"

DOCS="README"
HTML_DOCS=htm/*

src_install(){
	default

	insinto /usr/share/gap/pkg/"${PN}"
	doins -r doc htm lib
	doins *.g
}
