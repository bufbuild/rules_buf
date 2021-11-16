load("@rules_proto//proto:defs.bzl", "ProtoInfo")

def _buf_lint_aspect_impl(target, ctx):  
    proto_info = target[ProtoInfo]
    if ctx.rule.kind == "proto_library":  
        args = ctx.actions.args()
        args.add_joined(["--plugin", "protoc-gen-buf-lint", ctx.executable._lint], join_with="=")   
        args.add_all([ "--descriptor_set_in", proto_info.direct_descriptor_set, "--buf-lint_out=."])   
        args.add_all(proto_info.direct_sources)   
        out = ctx.actions.declare_file("lint.txt")    
        inputs = [proto_info.direct_descriptor_set, ctx.executable._lint] 
        inputs.extend(proto_info.direct_sources)
        ctx.actions.run(
            outputs = [out],
            inputs = inputs,
            executable = ctx.executable._protoc, 
            arguments = [args],
        )
        return [
            DefaultInfo(
                files = depset([out])
            ),
            OutputGroupInfo(
            lint_out = depset([out]),
        )]

    return []

buf_lint_aspect = aspect(
    implementation = _buf_lint_aspect_impl,
    attrs = {
        "_protoc": attr.label(
            default = "@protobuf//:protoc",
            executable = True,
            cfg = "exec"
        ),
        "_lint": attr.label(
            default = "@protoc_gen_buf_lint//file",
            executable = True,
            cfg = "exec"
        )
    },
)
