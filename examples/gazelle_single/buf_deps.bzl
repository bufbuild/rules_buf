load("@rules_buf//buf:defs.bzl", "buf_repository")

def buf_dependencies():
    buf_repository(
        name = "build_buf_acme_paymentapis",
        commit = "6e230f46113f498392c82d12b1a07b70",
        digest = "b1-kURgwJ5BZi3AM654TkWMArHoktwHiQEDo_1goLg6tLE=",
        module = "buf.build/acme/paymentapis",
    )
    buf_repository(
        name = "build_buf_acme_petapis",
        commit = "84a33a06f0954823a6f2a089fb1bb82e",
        digest = "b1-xfEFCPasCydYs426BYqE_U3IJJO9ZTbcigg6zqlqyFg=",
        module = "buf.build/acme/petapis",
    )
    buf_repository(
        name = "build_buf_googleapis_googleapis",
        commit = "84c3cad756d2435982d9e3b72680fa96",
        digest = "b1-GVZocI28gwtZCKNAO4Jd83jaE_XMjcAuEBtjnWvybO0=",
        module = "buf.build/googleapis/googleapis",
    )
