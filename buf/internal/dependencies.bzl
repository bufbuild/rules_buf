"""rules_buf dependencies"""

buf_toolchains_dependencies = {
    "buf-osx-arm64": {
        "sha256": "af48c127fac69c443d29db423735e74da7c36237d6054d980582e10f1fe1c258",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/buf-Darwin-arm64"],
        "executable": True,
    },
    "buf-osx-x86_64": {
        "sha256": "53cf0d2e175d2556948b6dddf9f5c2a76893926513252165690b581279c5821f",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/buf-Darwin-x86_64"],
        "executable": True,
    },
    "buf-linux-aarch64": {
        "sha256": "62b9a21769971ff38a25583da3282cb82d8dbe0021eee7e2b0c062abafd22bcc",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/buf-Linux-aarch64"],
        "executable": True,
    },
    "buf-linux-x86_64": {
        "sha256": "50c1c65222c55e84251180d9c038962865fb0049653125a2f4fb522f043117b2",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/buf-Linux-x86_64"],
        "executable": True,
    },
    "buf-windows-arm64": {
        "sha256": "2008148e20b4025d1b9ea43b523026cc0d6cdec25d4eeb3f8fcd958be049a74f",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/buf-Windows-arm64.exe"],
        "executable": True,
    },
    "buf-windows-x86_64": {
        "sha256": "0d41c6b062e3dc1f96a649114c2076e763dd6275661e40a66caf6d4316f21706",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/buf-Windows-x86_64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-osx-arm64": {
        "sha256": "ae7b256062abb59904c0a5f6ee627e32307c36e328d247d1836087d67fdcf906",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-breaking-Darwin-arm64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-osx-x86_64": {
        "sha256": "597630e7519894fe24a976685455437ca3850019d41d9c973e21ffaea96cb944",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-breaking-Darwin-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-linux-aarch64": {
        "sha256": "297aa090e3c2aa335dd70e0a30517236dc0d43f88f2d2c2aa2f83c4d2b2fb9d5",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-breaking-Linux-aarch64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-linux-x86_64": {
        "sha256": "a845d8acc57a800ce166344050436b12695f87c8750283eea91ea7e339a502e2",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-breaking-Linux-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-windows-arm64": {
        "sha256": "6e372f4d609a53f47e6ad8883c4fbf1c31e74b83122de45a38d43abbecc7c748",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-breaking-Windows-arm64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-windows-x86_64": {
        "sha256": "f7e6139932e28b3e3fd5837f2f94c13678b978ebfdc1c84d72dc94fdf9dc29c4",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-breaking-Windows-x86_64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-lint-osx-arm64": {
        "sha256": "612c1f3967b10f34f9bb112331e473ecbcd44458bcf438a01bc0826cfbb66086",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-lint-Darwin-arm64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-osx-x86_64": {
        "sha256": "3960ba4111f05e85c5c1d772fdb00da1aa14eac16f2bfdeede6db2c66805b9a9",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-lint-Darwin-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-linux-aarch64": {
        "sha256": "45165de7e24c3d2298b343e868eefde8f5f25435477e0645caacf464221982c7",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-lint-Linux-aarch64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-linux-x86_64": {
        "sha256": "9e8a92491477fec00c6414231b35f78099f3f5b6e674a3812f59461af8af0b3c",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-lint-Linux-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-windows-arm64": {
        "sha256": "f758dfddd12dd9124d4b70c63f8ad1b841a1c28866af6f9be258a00b5063a211",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-lint-Windows-arm64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-lint-windows-x86_64": {
        "sha256": "8cfb5a8d19571738b20a83a067f6b44e63c6747413b6a4d6b408118e079fbfe0",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc11/protoc-gen-buf-lint-Windows-x86_64.exe"],
        "executable": True,
    },
}

bazel_dependencies = {
    "bazel_skylib": {
        "sha256": "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
        "urls": [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
    },
    "rules_proto": {
        "sha256": "66bfdf8782796239d3875d37e7de19b1d94301e8972b3cbd2446b332429b4df1",
        "strip_prefix": "rules_proto-4.0.0",
        "urls": [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_proto/archive/refs/tags/4.0.0.tar.gz",
            "https://github.com/bazelbuild/rules_proto/archive/refs/tags/4.0.0.tar.gz",
        ],
    },
}
