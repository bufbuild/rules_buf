"""rules_buf dependencies"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

bazel_dependencies = {
    "bazel_skylib": {
        "sha256": "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
        "urls": [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        ],
    },
    "rules_proto": {
        "sha256": "e017528fd1c91c5a33f15493e3a398181a9e821a804eb7ff5acdd1d2d6c2b18d",
        "strip_prefix": "rules_proto-4.0.0-3.20.0",
        "urls": [
            "https://github.com/bazelbuild/rules_proto/archive/refs/tags/4.0.0-3.20.0.tar.gz",
        ],
    },
}

def rules_buf_dependencies():
    """Utility method to load all dependencies of `rules_buf`."""
    for name in bazel_dependencies:
        maybe(http_archive, name, **bazel_dependencies[name])
