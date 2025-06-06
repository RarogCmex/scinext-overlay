# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_STANDARD="77 90"
PYTHON_COMPAT=( python3_{10..13} )

inherit cmake fortran-2 python-any-r1 toolchain-funcs cuda

MY_PV=$(ver_rs 3 '-')

DESCRIPTION="Matrix Algebra on GPU and Multicore Architectures"
HOMEPAGE="
	https://icl.utk.edu/magma/
	https://github.com/icl-utk-edu/magma
"
SRC_URI="https://icl.utk.edu/projectsfiles/${PN}/downloads/${PN}-${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc +cuda +openblas test"

RDEPEND="
	cuda? ( dev-util/nvidia-cuda-toolkit )
	openblas? ( sci-libs/openblas )
	!openblas? (
		virtual/blas
		virtual/lapack
	)
"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
"
BDEPEND="
	virtual/pkgconfig
	sys-apps/sed
	doc? ( app-text/doxygen[dot] )
"

RESTRICT="!test? ( test )"

#PATCHES=(
#	"${FILESDIR}/${PN}-2.7.2-gentoo.patch"
#	"${FILESDIR}/${PN}-2.7.2-cuda.patch"
#)

pkg_setup() {
	fortran-2_pkg_setup
	python-any-r1_pkg_setup
	tc-check-openmp || die "Need OpenMP to compile ${P}"
}

src_prepare() {
	# distributed pc file not so useful so replace it
	cat <<-EOF > ${PN}.pc
		prefix=${EPREFIX}/usr
		libdir=\${prefix}/$(get_libdir)
		includedir=\${prefix}/include
		Name: ${PN}
		Description: ${DESCRIPTION}
		Version: ${PV}
		Libs: -L\${libdir} -lmagma_sparse -lmagma
		Libs.private: -lm -lpthread -ldl
		Cflags: -I\${includedir}
		Requires: $(usex openblas "openblas" "blas lapack")
	EOF

	rm -r blas_fix || die

	sed -i -e 's|LIBRARY DESTINATION lib|LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"|' \
       -e 's|ARCHIVE DESTINATION lib|ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"|' \
       -e 's|DESTINATION lib/pkgconfig|DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"|' \
       CMakeLists.txt || die

	cmake_src_prepare
	use cuda && cuda_src_prepare
}

src_configure() {
	# other options: Intel10_64lp, Intel10_64lp_seq, Intel10_64ilp, Intel10_64ilp_seq, Intel10_32, FLAME, ACML, Apple, NAS
	local blasvendor="Generic"
	use openblas && blasvendor="OpenBLAS"

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DMAGMA_ENABLE_CUDA=$(usex cuda)
		-DMAGMA_ENABLE_HIP=OFF
		-DUSE_FORTRAN=ON
		-DCMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"

		-DBLA_VENDOR=${blasvendor}
		-DGPU_TARGET=${MAGMA_GPU_TARGET:-sm_70}
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	local DOCS=( README ReleaseNotes )
	use doc && local HTML_DOCS=( docs/html/. )

	cmake_src_install

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${PN}.pc"
}
