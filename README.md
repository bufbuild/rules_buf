# rules_buf


## Lint POC 

Uses `bazel aspects` to lint proto files. 

Depends on `rules_proto` for `FileDescriptorSet` and invokes using `protoc` and lint plugin, `protoc-gen-buf-lint`.

Aspect is defined in `lint.bzl`

Invoke `lint` aspect from repo root:
```bash
bazel build //example:example_proto --aspects lint.bzl%buf_lint_aspect --output_groups=lint_out
```

Output should contain a single line of lint error starring with `--buf-lint_out` as shown below.

Output:

```
INFO: Analyzed target //example:example_proto (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
ERROR: /Users/srikrsna/Developer/buf/rules_buf/example/BUILD:1:14: Action example/lint.txt failed: (Exit 1): protoc failed: error executing command bazel-out/darwin_arm64-opt-exec-2B5CBBC6/bin/external/protobuf/protoc '--plugin=protoc-gen-buf-lint=external/protoc_gen_buf_lint/file/downloaded' --descriptor_set_in ... (remaining 3 argument(s) skipped)

Use --sandbox_debug to see verbose messages from the sandbox
--buf-lint_out: example/example.proto:1:1:Package name "example" should be suffixed with a correctly formed version, such as "example.v1".
Aspect //:lint.bzl%buf_lint_aspect of //example:example_proto failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 0.199s, Critical Path: 0.08s
INFO: 2 processes: 2 internal.
FAILED: Build did NOT complete successfully
```