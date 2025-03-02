# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
ROCM_VERSION=6.1

inherit distutils-r1 prefix cuda flag-o-matic rocm multiprocessing

DESCRIPTION="Tensors and Dynamic neural networks in Python"
HOMEPAGE="https://pytorch.org/"
SRC_URI="https://github.com/pytorch/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda distributed fbgemm flash-attention gloo mkl mpi nnpack numa +numpy onednn openblas atlas opencl openmp qnnpack rocm xnnpack mimalloc vulkan"
RESTRICT="test"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	mpi? ( distributed )
	gloo? ( distributed )
	?? ( cuda rocm )
	rocm? (
		|| ( ${ROCM_REQUIRED_USE} )
		!flash-attention
	)
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
	dev-libs/libfmt
	dev-libs/protobuf:=
	dev-libs/pthreadpool
	dev-libs/sleef
	sci-libs/foxi
	sci-libs/onnx
	virtual/lapack
	mimalloc? ( dev-libs/mimalloc )
	atlas? ( sci-libs/atlas[fortran,lapack] )
	numa? ( sys-process/numactl )
	cuda? (
		dev-libs/cudnn
		>=dev-libs/cudnn-frontend-1.9.0:0/8
		dev-util/nvidia-cuda-toolkit:=[profiler]
		=dev-libs/cutlass-3.6*
		dev-libs/cusparselt
		dev-libs/cudss
		dev-libs/nccl
	)
	fbgemm? ( >=dev-libs/FBGEMM-2023.12.01 )
	gloo? ( sci-libs/gloo[cuda?] )
	mpi? ( virtual/mpi )
	nnpack? ( sci-libs/NNPACK )
	numpy? ( $(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		') )
	onednn? ( =dev-libs/oneDNN-3.6* )
	opencl? ( virtual/opencl )
	qnnpack? (
		dev-cpp/gemmlowp
	)
	rocm? (
		=dev-libs/rccl-6.1*[${ROCM_USEDEP}]
		=dev-util/hip-6.1*
		=dev-util/roctracer-6.1*[${ROCM_USEDEP}]
		=sci-libs/hipBLAS-6.1*[${ROCM_USEDEP}]
		=sci-libs/hipBLASLt-6.1*
		=sci-libs/hipCUB-6.1*[${ROCM_USEDEP}]
		=sci-libs/hipFFT-6.1*[${ROCM_USEDEP}]
		=sci-libs/hipRAND-6.1*[${ROCM_USEDEP}]
		=sci-libs/hipSOLVER-6.1*[${ROCM_USEDEP}]
		=sci-libs/hipSPARSE-6.1*[${ROCM_USEDEP}]
		=sci-libs/miopen-6.1*[${ROCM_USEDEP}]
		=sci-libs/rocPRIM-6.1*[${ROCM_USEDEP}]
		=sci-libs/rocThrust-6.1*[${ROCM_USEDEP}]
		amdgpu_targets_gfx90a? ( =sci-libs/hipBLASLt-6.1*[amdgpu_targets_gfx90a] )
		amdgpu_targets_gfx940? ( =sci-libs/hipBLASLt-6.1*[amdgpu_targets_gfx940] )
		amdgpu_targets_gfx941? ( =sci-libs/hipBLASLt-6.1*[amdgpu_targets_gfx941] )
		amdgpu_targets_gfx942? ( =sci-libs/hipBLASLt-6.1*[amdgpu_targets_gfx942] )
	)
	distributed? (
		sci-libs/tensorpipe[cuda?]
		dev-cpp/cpp-httplib
	)
	xnnpack? ( >=sci-libs/XNNPACK-2024.02.29 )
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
	onednn? ( sci-libs/ideep )
	dev-libs/psimd
	dev-libs/FP16
	dev-libs/FXdiv
	dev-libs/pocketfft
	dev-libs/flatbuffers
	>=sci-libs/kineto-0.4.0_p20240525
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	')
"

BDEPEND="dev-build/cmake"

PATCHES=(
	"${FILESDIR}"/${PN}-2.5.1-unbundle_fmt.patch
	"${FILESDIR}"/${PN}-2.5.1-unbundle_kineto.patch
	"${FILESDIR}"/${PN}-2.5.1-cudnn_include_fix.patch
	"${FILESDIR}"/${PN}-2.6.0-gentoo.patch
	"${FILESDIR}"/${PN}-2.5.1-cpp-httplib.patch
	"${FILESDIR}"/${PN}-2.5.1-glog-0.6.0.patch
	"${FILESDIR}"/${PN}-2.5.1-generic-blas.patch
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

	# Fix path lookup in setup.py
	sed -i '/from setuptools.dist import Distribution/a sys.path[:0] = os.getcwd()' setup.py || die "can't fix setup"

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

	# Kineto
	sed -i 's/set(KINETO_LIBRARY_TYPE "static"/set(KINETO_LIBRARY_TYPE "shared"/g' cmake/Dependencies.cmake ||die
	sed -i '/KINETO_SOURCE_DIR/d' cmake/Dependencies.cmake || die
	sed -i '/if(NOT TARGET kineto)/a find_package(kineto CONFIG NAMES kinetoLibrary REQUIRED PATHS /usr/share/cmake/kineto/)' cmake/Dependencies.cmake || die
	sed -i '/if(USE_KINETO)/a target_include_directories(torch_cpu PRIVATE ${PROJECT_SOURCE_DIR}/c10/util)' caffe2/CMakeLists.txt || die

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
			-e "s/HIP 1.0/HIP 1.0 REQUIRED/" \
			-i cmake/public/LoadHIP.cmake || die

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

	# Version:
	PYTORCH_BUILD_VERSION="${PV}"
	PYTORCH_BUILD_NUMBER=0
	export PYTORCH_BUILD_VERSION PYTORCH_BUILD_NUMBER
	# Dev Note:
	# Exporting a bunch of variables is faster than one per one line

	# Main settings:
	USE_DISTRIBUTED=$(usex distributed 1 0)
	USE_FBGEMM=$(usex fbgemm 1 0)
	USE_KINETO=0 # TODO: It seems that out-of-source kineto is broken at this point. Wait till 2.6.0
	USE_MAGMA=0 # TODO: Add magma support
	USE_MIMALLOC=$(usex mimalloc 1 0)
	USE_MPI=$(usex mpi 1 0)
	USE_NNPACK=$(usex nnpack 1 0)
	USE_NUMA=$(usex numa 1 0)
	USE_NUMPY=$(usex numpy 1 0)
	USE_OPENMP=$(usex openmp 1 0)
	USE_TENSORPIPE=$(usex distributed 1 0)
	USE_CCACHE=OFF
	export USE_DISTRIBUTED USE_FBGEMM USE_KINETO USE_MAGMA USE_NUMPY USE_MPI USE_OPENMP \
	USE_NNPACK USE_NUMA USE_MIMALLOC USE_CCACHE

	# System libs and unbundling
	BUILD_TEST=OFF
	CMAKE_BUILD_DIR="${BUILD_DIR}"
	USE_FAKELOWP=OFF # FakeLowp operators. They also depend on fbgemm
	USE_GFLAGS=ON
	USE_GLOG=ON
	USE_MPS=OFF
	USE_ITT=OFF # Intel(R) VTune Profiler ITT functionality
	USE_PYTORCH_METAL=OFF
	USE_PYTORCH_QNNPACK=$(usex qnnpack 1 0)
	USE_SNPE=OFF # Qualcomm library
	USE_SYSTEM_CPUINFO=ON
	USE_SYSTEM_EIGEN_INSTALL=ON
	USE_SYSTEM_FP16=ON
	USE_SYSTEM_FXDIV=ON
	USE_SYSTEM_GLOO=ON
	USE_SYSTEM_LIBS=ON
	USE_SYSTEM_NVTX=ON
	USE_SYSTEM_ONNX=ON
	USE_SYSTEM_PSIMD=ON
	USE_SYSTEM_PTHREADPOOL=ON
	USE_SYSTEM_PYBIND11=ON
	USE_SYSTEM_SLEEF=ON
	USE_XNNPACK=$(usex xnnpack 1 0)
	USE_SYSTEM_XNNPACK=$(usex xnnpack 1 0)
	USE_VALGRIND=OFF
	export USE_SYSTEM_LIBS USE_SYSTEM_CPUINFO USE_SYSTEM_XNNPACK USE_PYTORCH_QNNPACK USE_SYSTEM_EIGEN_INSTALL \
	USE_SYSTEM_FP16 USE_SYSTEM_FXDIV USE_SYSTEM_GLOO USE_SYSTEM_ONNX USE_SYSTEM_PSIMD USE_SYSTEM_PTHREADPOOL \
	USE_SYSTEM_PYBIND11 USE_SYSTEM_SLEEF USE_PYTORCH_METAL USE_VALGRIND USE_FAKELOWP USE_SNPE USE_SYSTEM_NVTX \
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
		USE_NCCL=1
		export USE_CUDA USE_CUDNN USE_CUSPARSELT USE_CUDSS USE_CUFILE USE_NCCL
		# Cuda flags
		CMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
		TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-3.5 7.0}"
		export CMAKE_CUDA_FLAGS TORCH_CUDA_ARCH_LIST
	fi

	# Flash and Mem-eff attention
	USE_FLASH_ATTENTION=$(usex flash-attention 1 0)
	USE_MEM_EFF_ATTENTION=$(usex flash-attention 1 0)
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
		USE_NCCL=1
		USE_SYSTEM_NCCL=ON
		export PYTORCH_ROCM_ARCH USE_NCCL USE_SYSTEM_NCCL
	fi
	default

}
