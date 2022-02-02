"""Dependencies required to use buf gazelle extension."""

def gazelle_buf_dependencies():
    """Utility method to load dependecies of the buf gazelle extension"""

    go_repository(
        name = "com_github_bazelbuild_bazel_gazelle",
        importpath = "github.com/bazelbuild/bazel-gazelle",
        sum = "h1:gPaI2C0hRAhNT4w3bdSCift3nFjq0j07I4bmSDeneA4=",
        version = "v0.24.0",
    )
    go_repository(
        name = "in_gopkg_yaml_v3",
        importpath = "gopkg.in/yaml.v3",
        sum = "h1:h8qDotaEPuJATrMmW04NCwg7v22aHH28wwpauUhK9Oo=",
        version = "v3.0.0-20210107192922-496545a6307b",
    )
