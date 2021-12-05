"""Loads external dependencies."""
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

VERSION = "v1.0.0-rc8"

_buf_deps = {
    "buf_osx_arm64": {
        "sha256": "9ea62047c4b27f8ba076726de4f36f94985c9914bdd7d79f3273aa17dfe70d11",
    },    
    "buf_osx_x86_64": {
        "sha256": "426554e6c79be0cd2680cb22bfe157b7398d714f3dc7ddd799fa06f1d07681cf"
    },
    "buf_linux_aarch64": {
        "sha256": "fce46750e93e84fbd1c0e9bf5f72331dbcb07f23ec61c1f39f0007ab3387d1ab"
    },
    "buf_linux_x86_64": {
        "sha256": "21dd740c9e76847c496348beab499a840825685f67a517015042204d98e714a3"
    },
    "buf_windows_arm64": {
        "sha256": "f56b05c234a39babf985df0f737208a353c0dfec6bb7b9742a22b15636b023b6"
    },
    "buf_windows_x86_64": {
        "sha256": "f720c720d077adbf84482fea3b5d98508ae37d8a82521746d11233d768b3c06a"
    },        

    "protoc-gen-buf-breaking_osx_arm64": {
        "sha256": "1ac912be717362fbc7836531f28e46f1be767372a6d0c88f806bcf5f54773734",
    },    
    "protoc-gen-buf-breaking_osx_x86_64": {
        "sha256": "f979c9ebfb0ce08c3c498b12e95804122cc6935cff1bb4f05a34620c3f72d769"
    },
    "protoc-gen-buf-breaking_linux_aarch64": {
        "sha256": "c1608e9a1b4677e5bdd256d7141d115de4880195c7316f44880256a512202557"
    },
    "protoc-gen-buf-breaking_linux_x86_64": {
        "sha256": "620c260ffe80297e7e5bdf48fc24f966e30b45e52f7d16b86a687af4a2d9ec59"
    },
    "protoc-gen-buf-breaking_windows_arm64": {
        "sha256": "121342c757cf5ffe05a7dde483e14334bb07b44fa6505e5f9a48b68d05f7afda"
    },
    "protoc-gen-buf-breaking_windows_x86_64": {
        "sha256": "8fef81ea2577648d80c7faf1c87049148f0e450afafed4c077c3ce5deeb66ee6"
    },       

    "protoc-gen-buf-lint_osx_arm64": {
        "sha256": "f00221f558192e171f9deb78a0218d5c8160ccdaa2e2d84e3e2d3f8fd2aa47e5",
    },    
    "protoc-gen-buf-lint_osx_x86_64": {
        "sha256": "43207c579161c5b496facd9cabb14efd45b74fd9796ffc609526a5a11816011d"
    },
    "protoc-gen-buf-lint_linux_aarch64": {
        "sha256": "875c60abf15a8b6aa688104e79907fb7e22d507c1d8834a2a7a1b3cfc1fcdd15"
    },
    "protoc-gen-buf-lint_linux_x86_64": {
        "sha256": "21f6ad41cfc677c53bd576690718cacfcefd06dca306c72c3e6beeee8ca0adad"
    },
    "protoc-gen-buf-lint_windows_arm64": {
        "sha256": "4e51ed0def521d37bfbddb1daf5f3686999e0b4e760ef7a0024340c293b0414b"
    },
    "protoc-gen-buf-lint_windows_x86_64": {
        "sha256": "ac2dc463193c3031d4d62caf42ecf10a1d869d8ac16ecd9c48a964162fa1db19"
    },       
}


def download_releases(name, platforms):
    for p in platforms:
        exec_name = "{}_{}_{}".format(name, p["os"], p["cpu"])
        http_file(
            name = exec_name,
            urls = [
                "https://github.com/bufbuild/buf/releases/download/{}/{}-{}".format(VERSION, name, p["download_suffix"]),
            ],
            sha256 = _buf_deps[exec_name]["sha256"],
            executable = True,            
        )

