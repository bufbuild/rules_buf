"""protoc plugin based test rule"""

def protoc_plugin_test(ctx, proto_infos, protoc, plugin, config, files_to_include = []):
    """protoc_plugin_test creates a script file for a generic protoc plugin

    Args:
        ctx: rule context
        proto_infos: The ProtoInfo providers of `proto_library`
        protoc: protoc executable
        plugin: plugin executable
        config: plugin option to be passed to protoc
        files_to_include: any additional files to be included as part of runfiles
    Returns:
        Runfiles required to run the test
    """
    deps = depset([
        pi.direct_descriptor_set
        for pi in proto_infos
    ], transitive = [
        pi.transitive_descriptor_sets
        for pi in proto_infos
    ]).to_list()

    script = "{protoc} '--buf-plugin_opt={config}' --plugin=protoc-gen-buf-plugin={protoc_gen_buf_plugin}  --descriptor_set_in {deps} --buf-plugin_out=. {targets}".format(
        protoc = protoc.short_path,
        protoc_gen_buf_plugin = plugin.short_path,
        config = config,
        deps = ":".join([f.short_path for f in deps]),
        targets = " ".join([
            f.path[len(pi.proto_source_root) + 1:] if f.path.startswith(pi.proto_source_root) else f.path
            for pi in proto_infos
            for f in pi.direct_sources
        ]),
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    files = [protoc, plugin] + deps + [f for pi in proto_infos for f in pi.direct_sources] + files_to_include
    runfiles = ctx.runfiles(
        files = files,
    )

    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]
