"""Common utilities used across buf rules"""

def protoc_plugin_test(ctx, protoc, plugin, config, files_to_include = []):
    """protoc_plugin_test creates a script file for a generic protoc plugin

    Args:
        ctx: rule context
        protoc: protoc executable
        plugin: plugin executable
        config: plugin option to be passed to protoc
        files_to_include: any additional files to be included as part of runfiles
    Returns:
        Runfiles required to run the test
    """
    proto_info = ctx.attr.target[ProtoInfo]
    deps = proto_info.transitive_descriptor_sets.to_list()
    deps.append(proto_info.direct_descriptor_set)

    script = "{protoc} '--buf-plugin_opt={config}' --plugin=protoc-gen-buf-plugin={protoc_gen_buf_plugin}  --descriptor_set_in {deps} --buf-plugin_out=. {targets}".format(
        protoc = protoc.short_path,
        protoc_gen_buf_plugin = plugin.short_path,
        config = config,
        deps = ":".join([f.short_path for f in deps]),
        targets = " ".join([f.path[len(proto_info.proto_source_root) + 1:] if f.path.startswith(proto_info.proto_source_root) else f.path for f in proto_info.direct_sources]),
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    files = [protoc, plugin] + deps + proto_info.direct_sources + files_to_include
    runfiles = ctx.runfiles(
        files = files,
    )

    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]
