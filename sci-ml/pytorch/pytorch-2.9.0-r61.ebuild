# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
ROCM_VERSION=6.1

inherit distutils-r1 prefix cuda flag-o-matic rocm multiprocessing

DESCRIPTION="Tensors and Dynamic neural networks in Python"
HOMEPAGE="https://pytorch.org/"

# Starting from 2.7.0 pytorch moved flash attention out-of-tree,
# but hardcoded it as third_party subproject
# TODO: unbundle
FLASH_PV=2.7.4
FLASH_PN=flash-attention
FLASH_P=${FLASH_PN}-${FLASH_PV}
# caffe2-2.6.0 depends on future version of composable kernel
# TODO: replace it with RDEPEND in the future
CK_COMMIT=7fe50dc3da2069d6645d9deb8c017a876472a977
CK_P=composable_kernel-${CK_COMMIT:0:8}

SRC_URI="https://github.com/pytorch/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	flash? (
		https://github.com/Dao-AILab/${FLASH_PN}/archive/refs/tags/v${FLASH_PV}.tar.gz
		-> ${FLASH_P}.gh.tar.gz
	)
	rocm? ( https://github.com/ROCm/composable_kernel/archive/${CK_COMMIT}.tar.gz -> ${P}-${CK_P}.tar.gz )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda distributed fbgemm +flash +memefficient gloo magma mkl mpi nnpack numa +numpy onednn openblas atlas opencl openmp +qnnpack rocm xnnpack vulkan nccl"
RESTRICT="test"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	mpi? ( distributed )
	gloo? ( distributed )
	?? ( cuda rocm )
	rocm? (
		|| ( ${ROCM_REQUIRED_USE} )
		!flash
	)
	nccl? ( cuda )
"

RDEPEND="
	${PYTHON_DEPS}
	!sci-libs/caffe2
	dev-cpp/abseil-cpp:=
	dev-cpp/gflags:=
	dev-cpp/glog:=
	dev-cpp/nlohmann_json
	dev-cpp/opentelemetry-cpp
	dev-libs/cpuinfo
	dev-libs/libfmt:=
	dev-libs/protobuf:=
	dev-libs/pthreadpool
	dev-libs/sleef
	sci-ml/foxi
	<sci-ml/onnx-1.18.0
	~sci-ml/kineto-0.4.0_p20250617
	virtual/lapack
	atlas? ( sci-libs/atlas[fortran,lapack] )
	numa? ( sys-process/numactl )
	cuda? (
		dev-libs/cudnn
		>=sci-ml/cudnn-frontend-1.12.0:=
		>=dev-util/nvidia-cuda-toolkit-12.9:=[profiler]
		dev-libs/cudss:=
		dev-libs/cusparselt:=
		nccl? ( dev-libs/nccl )
	)
	fbgemm? ( sci-ml/FBGEMM )
	gloo? ( sci-ml/gloo[cuda?] )
	magma? ( sci-libs/magma )
	mpi? ( virtual/mpi )
	nnpack? ( sci-ml/NNPACK )
	numpy? ( $(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		') )
	onednn? ( =dev-libs/oneDNN-3.6* )
	opencl? ( virtual/opencl )
	qnnpack? (
		!sci-libs/QNNPACK
		sci-ml/gemmlowp
		dev-libs/clog
	)
	rocm? (
		nccl? ( >=dev-libs/rccl-6.3:= <dev-libs/rccl-7.1:= )
		>=dev-util/hip-6.3:=       <dev-util/hip-7.1:=
		>=dev-util/roctracer-6.3:= <dev-util/roctracer-7.1:=
		>=sci-libs/hipBLAS-6.3:=   <sci-libs/hipBLAS-7.1:=
		>=sci-libs/hipBLASLt-6.3:= <sci-libs/hipBLASLt-7.1:=
		>=sci-libs/hipFFT-6.3:=    <sci-libs/hipFFT-7.1:=
		>=sci-libs/hipRAND-6.3:=   <sci-libs/hipRAND-7.1:=
		>=sci-libs/hipSOLVER-6.3:= <sci-libs/hipSOLVER-7.1:=
		>=sci-libs/hipSPARSE-6.3:= <sci-libs/hipSPARSE-7.1:=
		>=sci-libs/miopen-6.3:=    <sci-libs/miopen-7.1:=
		>=sci-libs/rocBLAS-6.3:=   <sci-libs/rocBLAS-7.1:=
		>=sci-libs/rocRAND-6.3:=   <sci-libs/rocRAND-7.1:=
		>=sci-libs/rocSOLVER-6.3:= <sci-libs/rocSOLVER-7.1:=
		memefficient? ( sci-libs/aotriton-bin:0/0.11 )
	)
	distributed? (
		sci-ml/tensorpipe[cuda?]
		dev-cpp/cpp-httplib
	)
	xnnpack? ( >=sci-ml/XNNPACK-2024.02.29 )
	mkl? ( sci-libs/mkl )
	openblas? ( sci-libs/openblas )
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/sympy[${PYTHON_USEDEP}]
	')
"

DEPEND="
	${RDEPEND}
	dev-libs/psimd
	sci-ml/FP16
	dev-libs/FXdiv
	dev-libs/pocketfft
	dev-libs/flatbuffers
	cuda? ( ~dev-libs/cutlass-3.9.2[tools(+)] )
	onednn? ( sci-libs/ideep )
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	')
"

BDEPEND="dev-build/cmake"

PATCHES=(
	"${FILESDIR}"/${PN}-2.5.1-cpp-httplib.patch
	"${FILESDIR}"/${PN}-2.5.1-cudnn_include_fix.patch
	"${FILESDIR}"/${PN}-2.5.1-glog-0.6.0.patch
	"${FILESDIR}"/${PN}-2.5.1-unbundle_fmt.patch
	"${FILESDIR}"/${PN}-2.5.1-unbundle_kineto.patch
	"${FILESDIR}"/${PN}-2.6.0-rocm-fix-std-cpp17.patch
	"${FILESDIR}"/${PN}-2.7.0-glog-0.7.1.patch
	"${FILESDIR}"/${PN}-2.7.1-aotriton-fixes.patch
	"${FILESDIR}"/${PN}-2.8.0-rocm-minus-flash.patch
	"${FILESDIR}"/${PN}-2.8.0-unbundle_pocketfft.patch
	"${FILESDIR}"/${P}-gentoo.patch
	"${FILESDIR}"/${P}-cmake.patch
)

pkg_pretend(){
	if use cuda && [[ -z ${TORCH_CUDA_ARCH_LIST} ]]; then
		ewarn "WARNING: pytorch's caffe2 is being built with its default CUDA compute capabilities: 3.5 and 7.0."
		ewarn "These may not be optimal for your GPU."
		ewarn ""
		ewarn "To configure pytorch with the CUDA compute capability that is optimal for your GPU,"
		ewarn "set TORCH_CUDA_ARCH_LIST in your make.conf, and re-emerge caffe2."
		ewarn "For example, to use CUDA capability 7.5 & 3.5, add: TORCH_CUDA_ARCH_LIST=7.5 3.5"
		ewarn "For a Maxwell model GPU, an example value would be: TORCH_CUDA_ARCH_LIST=Maxwell"
		ewarn ""
		ewarn "You can look up your GPU's CUDA compute capability at https://developer.nvidia.com/cuda-gpus"
		ewarn "or by running /opt/cuda/extras/demo_suite/deviceQuery | grep 'CUDA Capability'"
	fi
}

src_prepare(){
	addpredict "/proc/self/task/"
	export MAX_JOBS=$(makeopts_jobs) MAKEOPTS="-j1"

	filter-lto #bug 862672

	einfo "Moving third_party..."
	if use flash; then
		mv "${WORKDIR}"/${FLASH_P}/* third_party/${FLASH_PN}/ || die
	fi

	# Change libaotriton path
	sed -i \
		-e "s|}/lib|}/$(get_libdir)|g" \
		cmake/External/aotriton.cmake \
		|| die

	# Fix path lookup in setup.py
	sed -i '/from setuptools.dist import Distribution/a sys.path[:0] = os.getcwd()' setup.py || die "can't fix setup"

	# Drop legacy from pyproject.toml
	sed -e "/build-backend/s|:__legacy__||" \
		-i pyproject.toml || die

	# Unbundle fmt
	sed -i \
		-e 's|::fmt-header-only||' \
		c10/CMakeLists.txt \
		cmake/Dependencies.cmake \
		torch/CMakeLists.txt \
		|| die

	# Drop third_party from CMake tree
	sed -i \
		-e '/add_subdirectory.*third_party/d' \
		CMakeLists.txt \
		cmake/Dependencies.cmake \
		cmake/ProtoBuf.cmake \
		aten/src/ATen/CMakeLists.txt \
		|| die

	default
	pushd torch/csrc/jit/serialization || die
	flatc --cpp --gen-mutable --scoped-enums mobile_bytecode.fbs || die
	popd

	# prefixify the hardcoded paths, after all patches are applied
	hprefixify \
		aten/CMakeLists.txt \
		caffe2/CMakeLists.txt \
		cmake/Metal.cmake \
		cmake/Modules/*.cmake \
		cmake/Modules_CUDA_fix/FindCUDNN.cmake \
		cmake/Modules_CUDA_fix/upstream/FindCUDA/make2cmake.cmake \
		cmake/Modules_CUDA_fix/upstream/FindPackageHandleStandardArgs.cmake \
		cmake/public/LoadHIP.cmake \
		cmake/public/cuda.cmake \
		cmake/Dependencies.cmake \
		torch/CMakeLists.txt \
		CMakeLists.txt

	if use rocm; then
		sed -e "s:/opt/rocm:/usr:" \
			-e "s:lib/cmake:$(get_libdir)/cmake:g" \
			-i cmake/public/LoadHIP.cmake || die

		# TODO: delete, when caffe2 depends on systemwide composable_kernel
		sed -e "s:third_party/composable_kernel:../composable_kernel-${CK_COMMIT}:g" \
			-i aten/src/ATen/CMakeLists.txt || die

		# Bug 959808: fix for gfx101x targets
		pushd "${WORKDIR}/composable_kernel-${CK_COMMIT}" > /dev/null || die
		eapply "${FILESDIR}"/composable-kernel-6.4.1-expand-isa.patch
		popd > /dev/null || die

		if tc-is-clang; then
			# Systemwide gcc (for absl and at::TensorBase) + hipcc (llvm>=18) need abi-compat=17.
			# But systemwide clang>=18 + hipcc (>=llvm-18) need opposite!
			# See also: https://github.com/llvm/llvm-project/issues/102443#issuecomment-2329726287
			sed '/-fclang-abi-compat=17/d' -i cmake/Dependencies.cmake || die
		fi

		# Workaround for libc++ issue https://github.com/llvm/llvm-project/issues/100802
		sed 's/std::memcpy/memcpy/g' -i c10/util/Half.h || die

		ebegin "HIPifying cuda sources"
		${EPYTHON} tools/amd_build/build_amd.py || die
		eend $?
	fi

}

src_configure(){
	einfo "Performing build configuration..."
	einfo "This might take a few seconds to complete"

	# Dev Notes:
	# Main pytorch build system (setup.py) is based on environment variables
	# So we eventually have to ether write our own build system or use a lot of them
	# Moreover, there are interesting note in tools/build_pytorch_libs.py:
	# 	"XXX - our cmake file sometimes looks at the system environment
	# 	and not cmake flags!
	# 	you should NEVER add something to this list. It is bad practice to
	# 	have cmake read the environment"
	# Internal function _create_build_env() do 'my_env = os.environ.copy()'
	# So all the necessary cmake -D'USE_FLAG' also can hilariously be used from envvars
	# I have just checked and tested it out.
	# (Sarcastic) Very human design!
	# Unironically, this actually helps a lot.

	# Version and build variables:
	PYTORCH_BUILD_VERSION="${PV}"
	PYTORCH_BUILD_NUMBER=0
	export PYTORCH_BUILD_VERSION PYTORCH_BUILD_NUMBER
	# Dev Note:
	# Exporting a bunch of variables is faster than one per one line

	# Main settings:
	USE_DISTRIBUTED=$(usex distributed 1 0)
	USE_FBGEMM=$(usex fbgemm 1 0)
	USE_KINETO=1
	USE_MAGMA=$(usex magma 1 0)
	USE_MPI=$(usex mpi 1 0)
	USE_NNPACK=$(usex nnpack 1 0)
	USE_NUMA=$(usex numa 1 0)
	USE_NUMPY=$(usex numpy 1 0)
	USE_OPENMP=$(usex openmp 1 0)
	USE_TENSORPIPE=$(usex distributed 1 0)
	USE_CCACHE=OFF
	USE_KLEIDIAI=OFF # TODO
	export USE_DISTRIBUTED USE_FBGEMM USE_KINETO USE_MAGMA USE_NUMPY USE_MPI USE_OPENMP \
	USE_NNPACK USE_NUMA USE_CCACHE USE_KLEIDIAI

	# System libs and unbundling
	BUILD_TEST=0
	CMAKE_BUILD_DIR="${BUILD_DIR}"
	USE_FAKELOWP=OFF # FakeLowp operators. They also depend on fbgemm
	USE_GFLAGS=ON
	USE_GLOG=ON
	USE_MPS=OFF
	USE_ITT=OFF # Intel(R) VTune Profiler ITT functionality
	USE_PYTORCH_METAL=OFF
	USE_PYTORCH_QNNPACK=$(usex qnnpack 1 0)
	USE_SNPE=OFF # Qualcomm library
	USE_SYSTEM_LIBS=ON
	USE_XNNPACK=$(usex xnnpack 1 0)
	USE_SYSTEM_XNNPACK=$(usex xnnpack 1 0)
	USE_VALGRIND=OFF
	export USE_SYSTEM_LIBS USE_PYTORCH_METAL USE_VALGRIND USE_FAKELOWP USE_SNPE \
	BUILD_TEST USE_ITT USE_GFLAGS USE_GLOG USE_MPS USE_XNNPACK

	# Blas settings
	if use mkl; then
		export BLAS=MKL
	elif use openblas; then
		export BLAS=OpenBLAS
	elif use atlas; then
		export BLAS=ATLAS
	else
		#TODO: Add support for eigen
		export BLAS=Generic
	fi

	# OpenCL settings
	export USE_OPENCL=$(usex opencl 1 0)

	# Nvidia cuda settings
	if use cuda; then
		# Enable cuda building on-place
		addpredict "/dev/nvidiactl" # bug 867706
		addpredict "/dev/char"
		addpredict "/proc/self/task" # bug 926116
		# Cuda settings
		USE_CUDA=1
		USE_CUDNN=1
		USE_CUSPARSELT=1
		USE_CUDSS=1
		USE_CUFILE=1 # TODO: Check if it is bundled in cuda toolkit 11.8
		USE_NCCL=$(usex nccl 1 0)
		USE_SYSTEM_NCCL=1
		export USE_CUDA USE_CUDNN USE_CUSPARSELT USE_CUDSS USE_CUFILE USE_NCCL USE_SYSTEM_NCCL
		# Cuda flags
		CMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
		TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-3.5 7.0}"
		export CMAKE_CUDA_FLAGS TORCH_CUDA_ARCH_LIST
	fi

	# Flash and Mem-eff attention
	USE_FLASH_ATTENTION=$(usex flash 1 0)
	USE_MEM_EFF_ATTENTION=$(usex memefficient 1 0)
	export USE_FLASH_ATTENTION USE_MEM_EFF_ATTENTION

	# Intel OneAPI settings
	export USE_MKLDNN=$(usex onednn 1 0) USE_XPU=OFF
	# TODO: USE_XPU requires big effort to support, and it seems that intel have already dropped this idea.
	# However, it is good to keep tracking for it
	if use onednn; then
		MKLDNN_FOUND=ON
		MKLDNN_LIBRARIES=dnnl
		MKLDNN_INCLUDE_DIR="${ESYSROOT}/usr/include/oneapi/dnnl"
		export MKLDNN_FOUND MKLDNN_LIBRARIES MKLDNN_INCLUDE_DIR
	fi

	# Experimental Vulkan API backend
	USE_VULKAN=$(usex vulkan 1 0)

	# AMD ROCM
	export USE_ROCM=$(usex rocm 1 0)
	if use rocm; then
		PYTORCH_ROCM_ARCH="$(get_amdgpu_flags)"
		if use memefficient; then
			export AOTRITON_INSTALLED_PREFIX="${ESYSROOT}/usr"
		fi
		USE_NCCL=1
		USE_SYSTEM_NCCL=1
		export PYTORCH_ROCM_ARCH USE_NCCL USE_SYSTEM_NCCL
	fi
	default

}
