"""
Declares the protoc-gen-buf-lint toolchain
"""

def _toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
    )
    return [toolchain_info]

protoc_gen_buf_lint_toolchain = rule(
    implementation = _toolchain_impl,
    attrs = {
        "cli": attr.label(
            doc = "The protoc-gen-buf-lint cli",
            executable = True,
            cfg = "exec",
            mandatory = True,
        ),
    },
)
