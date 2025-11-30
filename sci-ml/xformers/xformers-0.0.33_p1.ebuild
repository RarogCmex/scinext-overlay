# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( "python3_"{11..13} )

inherit distutils-r1 pypi cuda multiprocessing

MY_PV="$(ver_cut 0-3).post$(ver_cut 5-)"
#MY_PV=$PV
# Third-party dependencies taken from
# https://github.com/facebookresearch/xformers/tree/main/third_party
# Unbundling is unpractical or impossible
CKT_CI="50fad035248b154cdfa4505cf5de7465ce146149"
CUTLASS_CI="8afb19d9047afc26816a046059afe66763e68aa5"
FLASH_CI="de1584b5328321189a4d7832fe29bbd6813bf6ed"
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
	|| (
	>=sci-ml/pytorch-2.8:=[cuda,${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2[cuda]
	)
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

pkg_pretend(){
	if [[ -z ${TORCH_CUDA_ARCH_LIST} ]]; then
		ewarn "WARNING: xformers are being built with its default CUDA compute capabilities"
		ewarn "These may not be optimal for your GPU"
		ewarn ""
		ewarn "To configure xformers with the CUDA compute capability that is optimal for your GPU,"
		ewarn "set TORCH_CUDA_ARCH_LIST in your make.conf, and re-emerge xformers"
		ewarn "Xformers uses pytorch's compute capabilities"
		ewarn "For example, to use CUDA capability 7.5 & 3.5, add: TORCH_CUDA_ARCH_LIST=7.5 3.5"
		ewarn "For a Maxwell model GPU, an example value would be: TORCH_CUDA_ARCH_LIST=Maxwell"
		ewarn ""
		ewarn "You can look up your GPU's CUDA compute capability at https://developer.nvidia.com/cuda-gpus"
		ewarn "or by running /opt/cuda/extras/demo_suite/deviceQuery | grep 'CUDA Capability'"
	fi
}

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
	export NVCC_FLAGS="$(cuda_gccdir -f | tr -d \")"
}
