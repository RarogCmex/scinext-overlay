# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
inherit python-any-r1 cmake prefix cuda

CommitId=09e10ad38fdcdcba065f2e5871a219fa9a9f0067

DESCRIPTION="part of the PyTorch Profiler"
HOMEPAGE="https://github.com/pytorch/kineto"
SRC_URI="https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}"/${PN}-${CommitId}

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="test"

RDEPEND="
	dev-libs/libfmt
	dev-libs/dynolog
	dev-util/nvidia-cuda-toolkit
"
DEPEND="${RDEPEND}"
BDEPEND="
	test? ( dev-cpp/gtest )
	${PYTHON_DEPS}
"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}"/${PN}-0.4.0-gcc13.patch
)

src_prepare() {
	eapply "${FILESDIR}"/${P}-test.patch
	cd libkineto
	cmake_src_prepare
}

src_configure() {
	cuda_sanitize
	cd libkineto
	local mycmakeargs=(
		-DCUDA_SOURCE_DIR="${EPREFIX}"/opt/cuda
		-DLIBKINETO_THIRDPARTY_DIR="${EPREFIX}"/usr/include/
		-DKINETO_BUILD_TESTS=$(usex test)
		-DCUDA_SOURCE_DIR="/opt/cuda"
	)
	# TODO: Add support for ROCM
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-0.4.0_p20231031-gentoo.patch)

	cmake_src_configure
}
