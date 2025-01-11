# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1

CRATES="
        autocfg@1.4.0
        cfg-if@1.0.0
        heck@0.5.0
        indoc@2.0.5
        itoa@1.0.14
        libc@0.2.169
        memchr@2.7.4
        memmap2@0.9.5
        memoffset@0.9.1
        once_cell@1.20.2
        portable-atomic@1.10.0
        proc-macro2@1.0.92
        pyo3-build-config@0.23.3
        pyo3-ffi@0.23.3
        pyo3-macros-backend@0.23.3
        pyo3-macros@0.23.3
        pyo3@0.23.3
        quote@1.0.38
        ryu@1.0.18
        serde@1.0.217
        serde_derive@1.0.217
        serde_json@1.0.135
        syn@2.0.95
        target-lexicon@0.12.16
        unicode-ident@1.0.14
        unindent@0.2.3
        aho-corasick@1.1.3
        allocator-api2@0.2.21
        anes@0.1.6
        anstyle@1.0.10
        bit-set@0.8.0
        bit-vec@0.8.0
        bitflags@2.7.0
        bumpalo@3.16.0
        byteorder@1.5.0
        cast@0.3.0
        ciborium-io@0.2.2
        ciborium-ll@0.2.2
        ciborium@0.2.2
        clap@4.5.26
        clap_builder@4.5.26
        clap_lex@0.7.4
        criterion-plot@0.5.0
        criterion@0.5.1
        crossbeam-deque@0.8.6
        crossbeam-epoch@0.9.18
        crossbeam-utils@0.8.21
        crunchy@0.2.2
        either@1.13.0
        equivalent@1.0.1
        errno@0.3.10
        fastrand@2.3.0
        fnv@1.0.7
        foldhash@0.1.4
        getrandom@0.2.15
        half@2.4.1
        hashbrown@0.15.2
        hermit-abi@0.4.0
        is-terminal@0.4.13
        itertools@0.10.5
        js-sys@0.3.76
        lazy_static@1.5.0
        linux-raw-sys@0.4.15
        log@0.4.24
        num-traits@0.2.19
        oorandom@11.1.4
        plotters-backend@0.3.7
        plotters-svg@0.3.7
        plotters@0.3.7
        ppv-lite86@0.2.20
        proc-macro2@1.0.93
        proptest@1.6.0
        quick-error@1.2.3
        rand@0.8.5
        rand_chacha@0.3.1
        rand_core@0.6.4
        rand_xorshift@0.3.0
        rayon-core@1.12.1
        rayon@1.10.0
        regex-automata@0.4.9
        regex-syntax@0.8.5
        regex@1.11.1
        rustix@0.38.43
        rusty-fork@0.3.0
        same-file@1.0.6
        syn@2.0.96
        tempfile@3.15.0
        tinytemplate@1.2.1
        unarray@0.1.4
        wait-timeout@0.2.0
        walkdir@2.5.0
        wasi@0.11.0+wasi-snapshot-preview1
        wasm-bindgen-backend@0.2.99
        wasm-bindgen-macro-support@0.2.99
        wasm-bindgen-macro@0.2.99
        wasm-bindgen-shared@0.2.99
        wasm-bindgen@0.2.99
        web-sys@0.3.76
        winapi-util@0.1.9
        windows-sys@0.52.0
        windows-sys@0.59.0
        windows-targets@0.52.6
        windows_aarch64_gnullvm@0.52.6
        windows_aarch64_msvc@0.52.6
        windows_i686_gnu@0.52.6
        windows_i686_gnullvm@0.52.6
        windows_i686_msvc@0.52.6
        windows_x86_64_gnu@0.52.6
        windows_x86_64_gnullvm@0.52.6
        windows_x86_64_msvc@0.52.6
        zerocopy-derive@0.7.35
        zerocopy@0.7.35
"


DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 cargo

DESCRIPTION="Simple, safe way to store and distribute tensors"
HOMEPAGE="
	https://pypi.org/project/safetensors/
	https://huggingface.co/
"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}"/${P}/bindings/python

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

QA_FLAGS_IGNORED="usr/lib/.*"
RESTRICT="test" #depends on single pkg ( pytorch )

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	test? (
		dev-python/h5py[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	rm tests/test_{tf,paddle,flax}_comparison.py || die
	rm benches/test_{pt,tf,paddle,flax}.py || die
}

src_configure() {
	cargo_src_configure
	distutils-r1_src_configure
}

python_compile() {
	cargo_src_compile
	distutils-r1_python_compile
}

src_compile() {
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
}
