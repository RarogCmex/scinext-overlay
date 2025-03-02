# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( "python3_"{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Differentiable SDE solvers for pytorch with GPU support"
HOMEPAGE="
	https://github.com/google-research/torchsde
	https://pypi.org/project/torchsde
"
SRC_URI="https://github.com/google-research/torchsde/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}/torchsde-0.2.6-pytest.patch"
)

RDEPEND="
	>=sci-libs/pytorch-1.6.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.19[${PYTHON_USEDEP}]
		>=dev-python/scipy-1.5[${PYTHON_USEDEP}]
		>=dev-python/trampoline-0.1.2[${PYTHON_USEDEP}]
	')
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-40.8.0[${PYTHON_USEDEP}]
		dev-python/wheel[${PYTHON_USEDEP}]
	')
"
DOCS=( "DOCUMENTATION.md" "README.md" )

distutils_enable_tests pytest #It works but takes very long time
