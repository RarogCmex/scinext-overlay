# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10,11,12} )
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit cuda distutils-r1 multiprocessing

DESCRIPTION="Datasets, transforms and models to specific to computer vision"
HOMEPAGE="https://github.com/pytorch/vision"
SRC_URI="https://github.com/pytorch/vision/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/vision-${PV}"

PATCHES=( "${FILESDIR}/torchvision-0.20.1-nvcc-flags.patch" )

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda +jpeg +png +webp +ffmpeg heif avif debug nvdec"

# shellcheck disable=SC2016
RDEPEND="$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	')
	sci-libs/caffe2[${PYTHON_SINGLE_USEDEP}]
	sci-libs/pytorch[${PYTHON_SINGLE_USEDEP}]
	ffmpeg? ( media-video/ffmpeg )
	jpeg? ( media-libs/libjpeg-turbo )
	png? ( media-libs/libpng )
	webp? ( media-libs/libwebp )
	heif? ( media-libs/libheif )
	avif? (
		media-libs/libheif
		media-libs/libavif
		)
	cuda? (
		dev-util/nvidia-cuda-toolkit

		)
	nvdec? (
		>=x11-drivers/nvidia-drivers-550
		>=dev-util/nvidia-cuda-toolkit-12.3.2
	)
"
REQUIRED_USE="
	cuda? ( ffmpeg jpeg png )
	nvdec? ( cuda )"
#	dev-qt/qtcore:5 ?
DEPEND="${RDEPEND}"
# shellcheck disable=SC2016
BDEPEND="test? ( $(python_gen_cond_dep '
		dev-python/mock[${PYTHON_USEDEP}]
		')
	)"

distutils_enable_tests pytest

src_prepare() {
	default
	addpredict "/proc/self/task/"
	MAX_JOBS=$(makeopts_jobs)
	MAKEOPTS=-j1
	export MAKEOPTS MAX_JOBS

	mkdir -p "${WORKDIR}/include"
	if use nvdec; then
		# ToDo: Unbundle
		einfo "Preparing nvidia codec headers"
		pushd "${WORKDIR}/include"
		for file in "${FILESDIR}"/torchvision-0.20.1-video-codec-interface-12.2.72/*; do
			ln -s "$file" . || die "can't symlink nvidia codec headers"
		done
		popd
	fi

}

src_configure() {
	if use cuda; then
		FORCE_CUDA=1
		NVCC_FLAGS="$(cuda_gccdir -f | tr -d \")"
		BUILD_CUDA_SOURCES=1
		TORCHVISION_USE_NVJPEG=1
		TORCHVISION_LIBRARY="/usr/lib64"
		TORCHVISION_INCLUDE="${WORKDIR}/include"
		TORCHVISION_USE_VIDEO_CODEC="$(usex nvdec "1" "0")"
		export FORCE_CUDA NVCC_FLAGS BUILD_CUDA_SOURCES TORCHVISION_USE_NVJPEG TORCHVISION_USE_VIDEO_CODEC TORCHVISION_LIBRARY TORCHVISION_INCLUDE
	fi
	export DEBUG="$(usex debug "1" "0")"
	export TORCHVISION_USE_PNG="$(usex png "1" "0")"
	export TORCHVISION_USE_JPEG="$(usex jpeg "1" "0")"
	export TORCHVISION_USE_WEBP="$(usex webp "1" "0")"
	export TORCHVISION_USE_HEIC="$(usex heif "1" "0")"
	export TORCHVISION_USE_AVIF="$(usex avif "1" "0")"
	export TORCHVISION_USE_FFMPEG="$(usex ffmpeg "1" "0")"
}
