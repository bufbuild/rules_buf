load("@bazel_gazelle//:def.bzl", "gazelle")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

# gazelle:prefix github.com/bufbuild/rules_buf
# gazelle:exclude example/**
gazelle(
    name = "gazelle",
)

gazelle(
    name = "gazelle_update_repos",
    args = [
        "-from_file=go.mod",
        "-prune",
        "-to_macro=gazelle/buf/repositories.bzl%gazelle_buf_dependencies",
    ],
    command = "update-repos",
)

stardoc(
    name = "buf_rule_docs",
    out = "buf-rules.md",
    input = "//buf:defs.bzl",
    symbol_names = [
        "buf_lint_test",
        "buf_breaking_test",
    ],
    deps = [
        "//buf:defs",
    ],
)

alias(
    name = "generate_deps",
    actual = "//buf/internal/generate_deps:generate_deps",
)
