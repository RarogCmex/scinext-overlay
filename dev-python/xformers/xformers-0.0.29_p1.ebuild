# Copyright 2024-2025 Orson Teodoro <orsonteodoro@hotmail.com>
# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# RarogCmex: ebuild for test purpose. It will be rewriten later
# TODO package
# fairscale
# fvcore
# flake8-copyright
# pyre-check
# pyre-extensions
# submitit

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( "python3_"{10..12} )

inherit distutils-r1 pypi cuda


KEYWORDS=""
S="${WORKDIR}/${PN}-0.0.29.post1"
SRC_URI="https://github.com/facebookresearch/xformers/archive/refs/tags/v0.0.29.post1.tar.gz -> ${P}.tar.gz"


DESCRIPTION="Hackable and optimized Transformers building blocks, supporting a composable construction"
HOMEPAGE="
	https://github.com/facebookresearch/xformers
	https://pypi.org/project/xformers
"
LICENSE="BSD"
RESTRICT="test" # Untested
SLOT="0/$(ver_cut 1-2 ${PV})"
IUSE=""
RDEPEND+="
	>=sci-libs/pytorch-2.5[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"
DEPEND+="
	${RDEPEND}
"
BDEPEND+="
	dev-build/cmake
"
DOCS=( "README.md" )
src_prepare() {
	default
	cuda_add_sandbox
	cuda_src_prepare
}
