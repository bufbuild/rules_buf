load("@bazel_gazelle//:def.bzl", "gazelle", "gazelle_binary")
load("@rules_buf//buf:defs.bzl", "buf_lint_test")

gazelle_binary(
    name = "gazelle-buf",
    languages = [
        # Ensure proto extension is loaded before buf.
        "@bazel_gazelle//language/proto:go_default_library",
        "@rules_buf//gazelle/buf:buf",
    ],
    visibility = ["//:__pkg__"],
)

# gazelle:build_file_name BUILD
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
