load(":platforms.bzl", "PLATFORMS")

def declare_toolchains(name, toolchain, cmd = "buf"):
    for p in PLATFORMS:
        exec_name = "{}_{}_{}".format(cmd, p["os"], p["cpu"])
        toolchain(
            name = exec_name,
            cli = "@{}//file".format(exec_name),
        )

        native.toolchain(
            name = "{}_toolchain".format(exec_name),
            toolchain = ":{}".format(exec_name),
            toolchain_type = ":toolchain_type",
        )

def register_toolchains(name):
    labels = [
        "@rules_buf//tools/{}:{}_{}_{}_toolchain".format(name, name, p["os"], p["cpu"])
        for p in PLATFORMS
    ]
    native.register_toolchains(
        *labels
    )
