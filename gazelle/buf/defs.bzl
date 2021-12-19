"""proto_library macros used by `buf_module` not for direct use"""

load("@rules_proto//proto:defs.bzl", _proto_library = "proto_library")

def proto_library(name, **kwargs):
    _proto_library(name = "default_proto_library", **kwargs)
