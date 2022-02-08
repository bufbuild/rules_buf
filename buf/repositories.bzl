"""Dependencies and toolchains required to use rules_buf."""

load("//buf/internal:dependencies.bzl", _rules_buf_dependencies = "rules_buf_dependencies")
load("//buf/internal:toolchain.bzl", _rules_buf_toolchains = "rules_buf_toolchains")

rules_buf_dependencies = _rules_buf_dependencies
rules_buf_toolchains = _rules_buf_toolchains
