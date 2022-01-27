"""Buf toolchains macros to declare and register toolchains"""

_BUF_RELEASE_PLATFORMS = [
    {
        "os": "osx",
        "cpu": "arm64",
    },
    {
        "os": "osx",
        "cpu": "x86_64",
    },
    {
        "os": "linux",
        "cpu": "aarch64",
    },
    {
        "os": "linux",
        "cpu": "x86_64",
    },
    {
        "os": "windows",
        "cpu": "arm64",
    },
    {
        "os": "windows",
        "cpu": "x86_64",
    },
]

def declare_toolchains(name, toolchain, cmd = "buf"):
    for p in _BUF_RELEASE_PLATFORMS:
        exec_name = "{}-{}-{}".format(cmd, p["os"], p["cpu"])
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
        "@rules_buf//tools/{}:{}-{}-{}_toolchain".format(name, name, p["os"], p["cpu"])
        for p in _BUF_RELEASE_PLATFORMS
    ]
    native.register_toolchains(
        *labels
    )
