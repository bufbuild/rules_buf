"""Dependencies and toolchains required to use rules_proto."""

load("//tools:platforms.bzl", "PLATFORMS")
load(":deps.bzl", "download_releases")
load("//tools:toolchain.bzl", "register_toolchains")

def rules_buf_toolchains():
    """Declares buf toolchains. Provides the buf cli, protoc-gen-buf-breaking, and protoc-gen-buf-lint"""
    download_releases("buf", PLATFORMS)
    download_releases("protoc-gen-buf-breaking", PLATFORMS)
    download_releases("protoc-gen-buf-lint", PLATFORMS)
    
    register_toolchains("buf")
    register_toolchains("protoc-gen-buf-breaking")
    register_toolchains("protoc-gen-buf-lint")
