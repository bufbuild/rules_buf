load("@bazel_gazelle//:def.bzl", "DEFAULT_LANGUAGES", "gazelle", "gazelle_binary")
load("@rules_buf//buf:defs.bzl", "buf_lint_test")

gazelle_binary(
    name = "gazelle-buf",
    languages = DEFAULT_LANGUAGES + [
        "@rules_buf//gazelle/buf:buf",
    ],
    visibility = ["//:__pkg__"],
)

# gazelle:prefix github.com/bufbuild/rules_buf/examples/gazelle_single
gazelle(
    name = "gazelle",
    gazelle = ":gazelle-buf",
)

gazelle(
    name = "gazelle-update-repos",
    args = [
        "--from_file=buf.lock",
        "-to_macro=buf_deps.bzl%buf_dependencies",
        "-prune",
    ],
    command = "update-repos",
    gazelle = ":gazelle-buf",
)

buf_lint_test(
    name = "petapis_proto_lint",
    targets = [
        "@build_buf_acme_petapis//:default_proto_library",
    ],
)
