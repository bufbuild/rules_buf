workspace(name = "rules_buf")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "rules_proto",
    sha256 = "66bfdf8782796239d3875d37e7de19b1d94301e8972b3cbd2446b332429b4df1",
    strip_prefix = "rules_proto-4.0.0",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_proto/archive/refs/tags/4.0.0.tar.gz",
        "https://github.com/bazelbuild/rules_proto/archive/refs/tags/4.0.0.tar.gz",
    ],
)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()


http_file(
      name = "protoc_gen_buf_lint",
      urls = ["https://github.com/bufbuild/buf/releases/download/v1.0.0-rc8/protoc-gen-buf-lint-Darwin-arm64"],
      sha256 = "f00221f558192e171f9deb78a0218d5c8160ccdaa2e2d84e3e2d3f8fd2aa47e5",
      executable = True
)

git_repository(
    name = "protobuf",
    remote = "https://github.com/protocolbuffers/protobuf.git",
    # tag = "v3.18.0",
    commit = "89b14b1d16eba4d44af43256fc45b24a6a348557",
    shallow_since = "1631638108 -0700",
    recursive_init_submodules = True
)

