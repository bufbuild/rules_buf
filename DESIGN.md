# Design

The repo follows the directory structure and nomenclature outlined in [bazel docs](https://docs.bazel.build/versions/4.2.2/skylark/deploying.html)

## Goals

- Make bazel a first class citizen as [promised](https://docs.buf.build/roadmap#bazel-rules).
- Supporting all the features of buf (lint, breaking, build, generate)
- Support for BSR
- Incremental adoption of rules. (migrate cockraochdb)
- Independent feature set. Example: can choose to only use linting

## Approach

The community already depends on `rules_proto` for protobuf support. The building block of `rules_proto` is `proto_library`.

`proto_library` is a collection of protocol buffers and their dependencies. It provides `FileDescriptorSets` for it's sources and dependencies. More on this [here](https://docs.bazel.build/versions/4.2.2/skylark/lib/ProtoInfo.html).

### Non-Bazel Dependencies

The only non-bazel dependencies are `buf`, `protoc-gen-buf-lint`, and `protoc-gen-buf-breaking`. They are included as bazel [toolchains](https://docs.bazel.build/versions/4.2.2/toolchains.html). They are pulled from buf's github release page.

There is a small `go` script that can be run using bazel. This outputs `http_file` args for a specific release version of buf. Try and run ` bazel run //buf/internal/generate_deps:generate_deps -- -buf-version v1.0.0-rc8`

### Rules

Linting and breaking change detection are implemented as bazel test rules with the help of their protoc plugins. They depend on `proto_library` targets. They accept all the options that the plugins accept except timeout. Timeout will be pulled from bazel itself (yet to be implemented). More info on these can be found in their documentation,

* [buf_lint_test](/buf#buf_lint_test)
* [buf_breaking_test](/buf#buf_breaking_test)

[Aspects](https://docs.bazel.build/versions/4.2.2/skylark/aspects.html) were also explored but later dropped. Some of the reasons being,
- [Wrapper rules](https://docs.bazel.build/versions/4.2.2/skylark/aspects.html#invoking-an-aspect-through-a-target-rule) had be created in order for them to configured.
- The aspect would fail in case of an error and stop propagation defeating the purpose.
- Output could not be acquired inside bazel making it useless for analysis tools (IDEs)

[Gazelle extension](/gazelle/buf) is available to generate lint and breaking rules in a repo.

### Repo rules

**buf_image**

The `buf_image` rule can be used to fetch an image from module hosted on BSR. It is reproducible for a version of buf and module pin. It uses `sha256` to ensure byte-to-byte reproducibility. It uses `buf` to generate the image file.

This will be deprecated in favor of `buf_repository` and `buf_library` (yet to be implemented)

**buf_repository**

The `buf_repository` rule can be used to fetch a module on BSR. It exploits the `BUF_CACHE_DIR` environment variable to download the module to a known location and generates a single `proto_library` target.

This is akin to [`go_repository`](https://github.com/bazelbuild/bazel-gazelle/blob/master/repository.md#go_repository) rule.

Gazelle can be used to import modules from a `buf.lock` file. Preliminary version is already [implemented](/examples/gazelle_single/BUILD).

## Future

### Additions

- Add a `buf_library` rule inter-changeable `proto_library` replacing `FileDescriptorSets` with images. (This is especially needed for dependency resolution with gazelle as it cannot edit `proto_library` rules directly)
- Replace the `proto_library` in `buf_repository` with `buf_library`
- Use gazelle to generate `buf_library` rules.
- Tests for everything
- Examples
- Migrate major repos as tests (ex: cockroachdb)

### Minor improvements

- Pass bazel's timeout to lint and breaking tests
- Male gazelle understand `buf.work.yaml` for dependency resolution. It already supports multiple `buf.yaml` in a workspace.
- Make `buf_repository` use bazel's cache. (HINT: `go_repository` already does something similar)

### Grey Areas

- `buf generate`
- Managed mode
- Should modules loaded with `buf_repository` be granular? It is treated as a single `proto_library` target.
