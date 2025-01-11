# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Thanks Orson Teodoro <orsonteodoro@hotmail.com> for unfinished ebuild

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
COMMIT_ID="1d98f39c3015594e2ac8ed48dccc2f393b4dd82b"
PYTHON_COMPAT=( "python3_"{10..13} "python3_13t" ) # Upstream lists up to 3.7

inherit distutils-r1

DESCRIPTION="Simple and tiny yield-based trampoline implementation for pure python"
HOMEPAGE="
	https://github.com/ferreum/trampoline
	https://gitlab.com/ferreum/trampoline/-/tree/master
	https://pypi.org/project/trampoline
"
SRC_URI="https://github.com/ferreum/trampoline/archive/${COMMIT_ID}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT_ID}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

IUSE="test"
RESTRICT="!test? ( test )"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )
"
BDEPEND="${RDEPEND}"
DEPEND="${RDEPEND}"
DOCS=( "README.rst" )

python_test() {
	"${EPYTHON}" test_trampoline.py || die "Tests fail with ${EPYTHON}"
}
