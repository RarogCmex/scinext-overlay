# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11,12,13} )
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit cuda distutils-r1 multiprocessing

DESCRIPTION="Datasets, transforms and models to specific to computer vision"
HOMEPAGE="https://github.com/pytorch/vision"
SRC_URI="https://github.com/pytorch/vision/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/vision-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda +jpeg +png +webp +ffmpeg debug"

# shellcheck disable=SC2016
RDEPEND="$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	')
	|| (
		>=sci-ml/pytorch-2.7.0-r54[cuda?,${PYTHON_SINGLE_USEDEP}]
		sci-ml/caffe2[cuda?]
	)
	ffmpeg? ( media-video/ffmpeg )
	jpeg? ( media-libs/libjpeg-turbo )
	png? ( media-libs/libpng )
	webp? ( media-libs/libwebp )
	cuda? (
		dev-util/nvidia-cuda-toolkit
		)
"
REQUIRED_USE="
	cuda? ( ffmpeg jpeg png )"


DEPEND="${RDEPEND}"
# shellcheck disable=SC2016
BDEPEND="test? ( $(python_gen_cond_dep '
		dev-python/mock[${PYTHON_USEDEP}]
		')
	)"

distutils_enable_tests pytest

pkg_pretend() {
	if use ffmpeg; then
		ewarn "video decoding/encoding (ffmpeg backend) is being deprecated in torchvision"
		ewarn "see https://github.com/pytorch/vision/pull/8997"
	fi
}

src_prepare() {
	default
	addpredict "/proc/self/task/"
	MAX_JOBS=$(makeopts_jobs)
	MAKEOPTS=-j1
	export MAKEOPTS MAX_JOBS
}

src_configure() {
	if use cuda; then
		FORCE_CUDA=1
		NVCC_FLAGS="$(cuda_gccdir -f | tr -d \")"
		BUILD_CUDA_SOURCES=1
		TORCHVISION_USE_NVJPEG=1
		TORCHVISION_LIBRARY="/usr/lib64"
		TORCHVISION_INCLUDE="${WORKDIR}/include"
		export FORCE_CUDA NVCC_FLAGS BUILD_CUDA_SOURCES TORCHVISION_USE_NVJPEG TORCHVISION_USE_VIDEO_CODEC TORCHVISION_LIBRARY TORCHVISION_INCLUDE
	fi
	export DEBUG="$(usex debug "1" "0")"
	export TORCHVISION_USE_PNG="$(usex png "1" "0")"
	export TORCHVISION_USE_JPEG="$(usex jpeg "1" "0")"
	export TORCHVISION_USE_WEBP="$(usex webp "1" "0")"
	export TORCHVISION_USE_FFMPEG="$(usex ffmpeg "1" "0")"
}
