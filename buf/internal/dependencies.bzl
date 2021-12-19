"""rules_buf dependencies"""

buf_toolchains_dependencies = {
    "buf-osx-arm64": {
        "sha256": "b9c2bbbddbda09dd10c0d6f381d9e0999fa259fd01549252300516fa0a55e45e",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/buf-Darwin-arm64"],
        "executable": True,
    },
    "buf-osx-x86_64": {
        "sha256": "7c890cd32365311ae1ed692ae308253eb88e1b4749283d43bc166d6d7d81fd67",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/buf-Darwin-x86_64"],
        "executable": True,
    },
    "buf-linux-aarch64": {
        "sha256": "203b685586edc9905f6cf16ccd1414097efea633f870a466a43efd63f0c41c2a",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/buf-Linux-aarch64"],
        "executable": True,
    },
    "buf-linux-x86_64": {
        "sha256": "3d164e6473485cb12ea66e3d050b1410df4a248efc168749cd5c76c31970777b",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/buf-Linux-x86_64"],
        "executable": True,
    },
    "buf-windows-arm64": {
        "sha256": "c24e943f896b178322372664a73491426d52569c60c6a19db22c9718b93b5ae6",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/buf-Windows-arm64.exe"],
        "executable": True,
    },
    "buf-windows-x86_64": {
        "sha256": "d9410cc8b2a49e93c66f080b38ca245f9a05a6ad65e5b6e2e473d350b9be2b48",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/buf-Windows-x86_64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-osx-arm64": {
        "sha256": "6dfa79b09b96582570e67797b5a90a9ad2e6e6b215b8f84333ae44b4fa1a679d",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-breaking-Darwin-arm64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-osx-x86_64": {
        "sha256": "030cbae6dbec425f7408bb7f3dbc7db7e427781625a0030b95041cf789cbb4d8",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-breaking-Darwin-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-linux-aarch64": {
        "sha256": "af72520405e49127768e0efed9f198ca23afd035578ef19794cd61a32d51f5d0",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-breaking-Linux-aarch64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-linux-x86_64": {
        "sha256": "6e44ff0abe4cf6833022ab07674441f86b43faf1583ba83eacdbe113009ad279",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-breaking-Linux-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-windows-arm64": {
        "sha256": "1bf8875f09215bebb2d9fe8b0a1f635b25a33341051e70a8c13c096a09c9dcb0",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-breaking-Windows-arm64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-breaking-windows-x86_64": {
        "sha256": "9dadca3df5090b9d5bfe304b816c229a6b40c0daf537cf2f6882840ec2862320",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-breaking-Windows-x86_64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-lint-osx-arm64": {
        "sha256": "133bc1ba5cdad830a014b94e2773d7d605769cdd6bede22bb6dabd0dd4ba8647",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-lint-Darwin-arm64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-osx-x86_64": {
        "sha256": "6d582509ee917e2f318fd14aa095f0173440c165628f182584f2c4a326da18d1",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-lint-Darwin-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-linux-aarch64": {
        "sha256": "924dbf3b60c3c2fe6be99f05f08240cbce5e1af6d097ed6c0e72b5d6844aa0d2",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-lint-Linux-aarch64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-linux-x86_64": {
        "sha256": "d5ffe027cf3057619a45f883699781463cb1144426d9db529ddf13860afb8f59",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-lint-Linux-x86_64"],
        "executable": True,
    },
    "protoc-gen-buf-lint-windows-arm64": {
        "sha256": "1e68edab8331ecb46caced01718c2635778158127256998ab1ba773840fd0615",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-lint-Windows-arm64.exe"],
        "executable": True,
    },
    "protoc-gen-buf-lint-windows-x86_64": {
        "sha256": "befa4c91ddc7dbb181bbbe329aea296ac8eb317593a4ac037fe431aff509154b",
        "urls": ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc10/protoc-gen-buf-lint-Windows-x86_64.exe"],
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
