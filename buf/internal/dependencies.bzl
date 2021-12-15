"""rules_buf dependencies"""

buf_toolchains_dependencies = {
    "buf-osx-arm64": {
        "sha256": "9ea62047c4b27f8ba076726de4f36f94985c9914bdd7d79f3273aa17dfe70d11",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/buf-Darwin-arm64"],
        "executable": True,
    },
    "buf-osx-x86_64": {
        "sha256": "426554e6c79be0cd2680cb22bfe157b7398d714f3dc7ddd799fa06f1d07681cf",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/buf-Darwin-x86_64"],
        "executable": True,
    },
    "buf-linux-aarch64": {
        "sha256": "fce46750e93e84fbd1c0e9bf5f72331dbcb07f23ec61c1f39f0007ab3387d1ab",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/buf-Linux-aarch64"],
        "executable": True,
    },
    "buf-linux-x86_64": {
        "sha256": "21dd740c9e76847c496348beab499a840825685f67a517015042204d98e714a3",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/buf-Linux-x86_64"],
        "executable": True,
    },
    "buf-windows-arm64": {
        "sha256": "f56b05c234a39babf985df0f737208a353c0dfec6bb7b9742a22b15636b023b6",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/buf-Windows-arm64.exe"],
        "executable": True,
    },
    "buf-windows-x86_64": {
        "sha256": "f720c720d077adbf84482fea3b5d98508ae37d8a82521746d11233d768b3c06a",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/buf-Windows-x86_64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-osx-arm64": {
        "sha256": "1ac912be717362fbc7836531f28e46f1be767372a6d0c88f806bcf5f54773734",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-breaking-Darwin-arm64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-osx-x86_64": {
        "sha256": "f979c9ebfb0ce08c3c498b12e95804122cc6935cff1bb4f05a34620c3f72d769",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-breaking-Darwin-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-linux-aarch64": {
        "sha256": "c1608e9a1b4677e5bdd256d7141d115de4880195c7316f44880256a512202557",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-breaking-Linux-aarch64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-linux-x86_64": {
        "sha256": "620c260ffe80297e7e5bdf48fc24f966e30b45e52f7d16b86a687af4a2d9ec59",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-breaking-Linux-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-windows-arm64": {
        "sha256": "121342c757cf5ffe05a7dde483e14334bb07b44fa6505e5f9a48b68d05f7afda",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-breaking-Windows-arm64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-windows-x86_64": {
        "sha256": "8fef81ea2577648d80c7faf1c87049148f0e450afafed4c077c3ce5deeb66ee6",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-breaking-Windows-x86_64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-lint-osx-arm64": {
        "sha256": "f00221f558192e171f9deb78a0218d5c8160ccdaa2e2d84e3e2d3f8fd2aa47e5",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Darwin-arm64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-osx-x86_64": {
        "sha256": "43207c579161c5b496facd9cabb14efd45b74fd9796ffc609526a5a11816011d",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Darwin-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-linux-aarch64": {
        "sha256": "875c60abf15a8b6aa688104e79907fb7e22d507c1d8834a2a7a1b3cfc1fcdd15",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Linux-aarch64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-linux-x86_64": {
        "sha256": "21f6ad41cfc677c53bd576690718cacfcefd06dca306c72c3e6beeee8ca0adad",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Linux-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-windows-arm64": {
        "sha256": "4e51ed0def521d37bfbddb1daf5f3686999e0b4e760ef7a0024340c293b0414b",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Windows-arm64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-lint-windows-x86_64": {
        "sha256": "ac2dc463193c3031d4d62caf42ecf10a1d869d8ac16ecd9c48a964162fa1db19",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Windows-x86_64.exe"],
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
