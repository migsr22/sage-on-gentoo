# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

DESCRIPTION="A portable, high performance parallel ray tracing system"
HOMEPAGE="http://jedi.ks.uiuc.edu/~johns/raytracer/"
SRC_URI="http://jedi.ks.uiuc.edu/~johns/raytracer/files/${PV}/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples jpeg mpi opengl png threads"

RESTRICT="mirror"

CDEPEND="jpeg? ( media-libs/jpeg )
	mpi? ( virtual/mpi )
	opengl? ( virtual/opengl )
	png? ( media-libs/libpng )"
DEPEND="${CDEPEND}
	dev-util/pkgconfig"
RDEPEND="${CEPEND}"

S="${WORKDIR}/${PN}/unix"

# TODO: Test on alpha, ia64, ppc
# TODO: MPI: Depend on lam or virtual ? Test MPI
# TODO: Check for threads dependencies
# TODO: add other architectures
# TODO: X, Motif, MBOX, Open Media Framework, Spaceball I/O, MGF ?

TACHYON_MAKE_TARGET=

src_prepare() {
	if use jpeg ; then
		sed -i \
			-e "s:USEJPEG=:USEJPEG=-DUSEJPEG:g" \
			-e "s:JPEGLIB=:JPEGLIB=-ljpeg:g" Make-config \
			|| die "sed failed"
	fi

	if use png ; then
		sed -i \
			-e "s:USEPNG=:USEPNG=-DUSEPNG:g" \
			-e "s:PNGINC=:PNGINC=$(pkg-config libpng --cflags):g" \
			-e "s:PNGLIB=:PNGLIB=$(pkg-config libpng --libs):g" Make-config \
			|| die "sed failed"
	fi

	if use mpi ; then
		sed -i "s:MPIDIR=:MPIDIR=/usr:g" Make-config || die "sed failed"
	fi
}

src_compile() {
	if use threads ; then
		if use opengl ; then
			TACHYON_MAKE_TARGET=linux-thr-ogl

			if use mpi ; then
				die "tachyon does not support MPI with OpenGL and threads"
			fi
		elif use mpi ; then
			TACHYON_MAKE_TARGET=linux-lam-thr
		elif use amd64 ; then
			TACHYON_MAKE_TARGET=linux-64-thr
		elif use ia64 ; then
			TACHYON_MAKE_TARGET=linux-ia64-thr
		else
			TACHYON_MAKE_TARGET=linux-thr
		fi

		# TODO: Support for linux-athlon-thr ?
	else
		if use opengl ; then
			# TODO: Support target: linux-lam-64-ogl

			die "OpenGL is only available with USE=threads!"
		elif use mpi ; then
			if use amd64 ; then
				TACHYON_MAKE_TARGET=linux-lam-64
			else
				TACHYON_MAKE_TARGET=linux-lam
			fi

			# TODO: Support for linux-mpi, linux-mpi-64 ?
		elif use amd64 ; then
			TACHYON_MAKE_TARGET=linux-64
		elif use ppc ; then
			TACHYON_MAKE_TARGET=linux-ppc
		elif use alpha ; then
			TACHYON_MAKE_TARGET=linux-alpha
		elif use ia64 ; then
			TACHYON_MAKE_TARGET=linux-ia64
		else
			TACHYON_MAKE_TARGET=linux
		fi

		# TODO: Support for linux-p4, linux-athlon, linux-ps2 ?
	fi

	if [[ -z "${TACHYON_MAKE_TARGET}" ]]; then
		die "No target found, check use flags"
	else
		# TODO: remove this once we are sure makefile target selection works
		einfo "Using target: ${TACHYON_MAKE_TARGET}"
	fi

	emake ${TACHYON_MAKE_TARGET} || die "emake failed"
}

src_install() {
	cd ..
	dodoc Changes README || die "dodoc failed"

	if use doc ; then
		dohtml docs/tachyon/* || die "dohtml failed"
	fi

	cd compile/${TACHYON_MAKE_TARGET}

	dobin tachyon || die "dobin failed"
	dolib libtachyon.a || die "dolib failed"

	if use examples; then
		cd "${S}"/../scenes
		insinto /usr/share/${PN}/examples
		doins * || die "doins failed"
	fi
}
