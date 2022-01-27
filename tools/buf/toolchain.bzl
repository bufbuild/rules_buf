"""
Declares the buf toolchain
"""

def _buf_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
    )
    return [toolchain_info]

buf_toolchain = rule(
    implementation = _buf_toolchain_impl,
    attrs = {
        "cli": attr.label(
            doc = "The buf cli",
            executable = True,
            cfg = "exec",
            mandatory = True,
        ),
    },
)
