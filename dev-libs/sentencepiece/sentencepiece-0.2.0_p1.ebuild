# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
COMMIT_ID="d8f741853847553169444afc12c00f4bbff3e9ce"

inherit cmake

DESCRIPTION="Unsupervised text tokenizer for Neural Network-based text generation"
HOMEPAGE="https://github.com/google/sentencepiece"
SRC_URI="
	https://github.com/google/${PN}/archive/${COMMIT_ID}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
S="${WORKDIR}/${PN}-${COMMIT_ID}"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs test"
RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DSPM_BUILD_TEST=$(usex test ON OFF)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if ! use static-libs; then
		find "${ED}/usr/$(get_libdir)" -name "*.a" -delete || die
	fi
}
