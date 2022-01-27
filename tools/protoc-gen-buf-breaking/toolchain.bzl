"""
Declares the protoc-gen-buf-breaking toolchain
"""

def _toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
    )
    return [toolchain_info]

protoc_gen_buf_breaking_toolchain = rule(
    implementation = _toolchain_impl,
    attrs = {
        "cli": attr.label(
            doc = "The protoc-gen-buf-breaking cli",
            executable = True,
            cfg = "exec",
            mandatory = True,
        ),
    },
)
