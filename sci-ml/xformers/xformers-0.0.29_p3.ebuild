# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( "python3_"{10..13} )

inherit distutils-r1 pypi cuda multiprocessing

MY_PV="$(ver_cut 0-3).post$(ver_cut 5-)"
# Third-party dependencies taken from
# https://github.com/facebookresearch/xformers/tree/main/third_party
# Unbundling is unpractical or impossible
CKT_CI="4e076909b6c1e1404d9ff5dc0e71e3be1c06569e"
CUTLASS_CI="7d49e6c7e2f8896c47f586706e67e1fb215529dc"
FLASH_CI="f86e3dd9192e41dee3814c4cfd8bbce4792e6753"
KEYWORDS="~amd64"
SRC_URI="https://github.com/facebookresearch/xformers/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz
https://github.com/Dao-AILab/flash-attention/archive/${FLASH_CI}.tar.gz -> ${P}-flash-${FLASH_CI}.gh.tar.gz
https://github.com/ROCm/composable_kernel/archive/${CKT_CI}.tar.gz -> ${P}-composable_kernel_tiled-${CKT_CI}.gh.tar.gz
https://github.com/NVIDIA/cutlass/archive/${CUTLASS_CI}.tar.gz -> ${P}-cutlass-${CUTLASS_CI}.gh.tar.gz
"

DESCRIPTION="Hackable and optimized Transformers building blocks, supporting a composable construction"
HOMEPAGE="
	https://github.com/facebookresearch/xformers
	https://pypi.org/project/xformers
"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="BSD"
RESTRICT="test"
SLOT="0/$(ver_cut 1-2 ${PV})"
IUSE=""
RDEPEND="
	=sci-ml/pytorch-2.6*[cuda,${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	dev-build/cmake
"
DOCS=( "README.md" )
src_prepare() {
	default
	addpredict "/proc/self/task/"
	export MAX_JOBS=$(makeopts_jobs)

	rm -d "${S}/third_party/composable_kernel_tiled" || die
	rm -d "${S}/third_party/cutlass" || die
	rm -d "${S}/third_party/flash-attention" || die

	mv "${WORKDIR}/composable_kernel-${CKT_CI}" "${S}/third_party/composable_kernel_tiled" || die
	mv "${WORKDIR}/cutlass-${CUTLASS_CI}" "${S}/third_party/cutlass" || die
	mv "${WORKDIR}/flash-attention-${FLASH_CI}" "${S}/third_party/flash-attention" || die

	cuda_add_sandbox
	cuda_src_prepare
	export CUDAFLAGS="$(cuda_gccdir -f | tr -d \")"
}
