"""Define module extensions for using rules_buf with bzlmod.
See https://bazel.build/docs/bzlmod#extension-definition
"""

load("//buf/internal:toolchain.bzl", "buf_download_releases")

def _extension_impl(module_ctx):
    buf_download_releases(
        name = "rules_buf_toolchains",
        # TODO: get desired version from the attr
        version = "v1.27.0",
    )

ext = module_extension(
    implementation = _extension_impl,
)
