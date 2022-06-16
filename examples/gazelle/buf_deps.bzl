load("@rules_buf//buf:defs.bzl", "buf_dependencies")

def buf_deps():
    buf_dependencies(
        name = "buf_deps_barapis",
        modules = [
            "buf.build/acme/paymentapis:6e230f46113f498392c82d12b1a07b70",
            "buf.build/acme/petapis:84a33a06f0954823a6f2a089fb1bb82e",
            "buf.build/envoyproxy/protoc-gen-validate:dc09a417d27241f7b069feae2cd74a0e",
            "buf.build/googleapis/googleapis:84c3cad756d2435982d9e3b72680fa96",
        ],
    )
    buf_dependencies(
        name = "buf_deps_fooapis",
        modules = [
            "buf.build/acme/paymentapis:6e230f46113f498392c82d12b1a07b70",
            "buf.build/acme/petapis:84a33a06f0954823a6f2a089fb1bb82e",
            "buf.build/googleapis/googleapis:84c3cad756d2435982d9e3b72680fa96",
        ],
    )
