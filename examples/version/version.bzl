_TOOLCHAIN = "@rules_buf//tools/buf:toolchain_type"

def _print_buf_version_impl(ctx):
    buf = ctx.toolchains[_TOOLCHAIN].cli

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "{} --version".format(buf.short_path),
        is_executable = True,
    )

    files = [buf]
    runfiles = ctx.runfiles(
        files = files,
    )

    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]

print_buf_version = rule(
    implementation = _print_buf_version_impl,
    toolchains = [_TOOLCHAIN],
    executable = True,
)
