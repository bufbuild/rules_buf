# Dependencies

## WORKSPACE

In the workspace file, at the very end there is a `buf_dependencies` rule.

```skylark
buf_dependencies(
    name = "buf_build_acme_petapis",
    deps = [
        "buf.build/acme/paymentapis:6e230f46113f498392c82d12b1a07b70",
        "buf.build/googleapis/googleapis:a1ffc9a9fa3e4ce0917108cf27576b2f",
    ],
)
```

- The name is the name of the buf module after replacing '.' and '/' with '\_'. In this case "buf.build/acme/petapis".
- deps are the dependecies of this module pinned to an exact revision.

## BUILD

Run the following from examples/repo directory:

```bazel build //pet/v1:pet_v1_cpp_proto```

This should successfully build the cc_library rule in pet/v1/BUILD.bazel. 

The rule depends on `proto_library` rule `pet_v1_proto` whch in turn depends on `@buf_build_acme_petapis//payment/v1alpha1:payment_v1alpha1_proto` which comes from the `buf_dependencies` rule.