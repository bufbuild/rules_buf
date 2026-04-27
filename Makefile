# See https://tech.davis-hansson.com/p/make/
SHELL := bash
.DELETE_ON_ERROR:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-print-directory
BIN := .tmp/bin
COPYRIGHT_YEARS := 2021-2025
LICENSE_IGNORE := -e /testdata/
LICENSE_HEADER_VERSION := v1.68.4
# Set to use a different compiler. For example, `GO=go1.18rc1 make test`.
GO ?= go
BAZEL ?= bazelisk
# Pin Bazel to .bazelversion so a newer Bazel on PATH doesn't rewrite
# MODULE.bazel.lock to a higher lockFileVersion. tests.yaml's matrix overrides
# this via env to exercise multiple Bazel versions.
USE_BAZEL_VERSION ?= $(shell cat .bazelversion)
export USE_BAZEL_VERSION

.PHONY: help
help: ## Describe useful make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

.PHONY: all
all: ## Test
	$(MAKE) test

.PHONY: clean
clean: ## Delete intermediate build artifacts
	@# -X only removes untracked files, -d recurses into directories, -f actually removes files/dirs
	git clean -Xdf

.PHONY: test
test: ## Run unit tests
	$(BAZEL) test //...

.PHONY: format
format: ## Format Starlark files with buildifier
	$(BAZEL) run //:buildifier

.PHONY: lint
lint: ## Lint Starlark files with buildifier
	$(BAZEL) test //:buildifier_check

.PHONY: generate
generate: $(BIN)/license-header ## Regenerate BUILD files, repositories.bzl, license headers, and format
	@# Tidy first so gazelle_update_repos regenerates repositories.bzl from
	@# a clean go.mod.
	$(GO) mod tidy
	(cd examples/echo && $(GO) mod tidy)
	$(BAZEL) run //:gazelle_update_repos
	$(BAZEL) run //:gazelle
	@# Each example is its own Bazel workspace. Refresh its MODULE.bazel.lock,
	@# regenerate its BUILD files via gazelle, and format its proto files via
	@# buf_format -- but only when the corresponding target exists, since not
	@# every example has all three.
	@for dir in examples/*/; do \
		if [[ -f "$${dir}MODULE.bazel" ]]; then \
			echo "$(BAZEL) mod deps in $${dir}"; \
			(cd "$${dir}" && $(BAZEL) mod deps >/dev/null); \
		fi; \
		if (cd "$${dir}" && $(BAZEL) query //:gazelle >/dev/null 2>&1); then \
			echo "$(BAZEL) run //:gazelle in $${dir}"; \
			(cd "$${dir}" && $(BAZEL) run //:gazelle); \
		fi; \
		if (cd "$${dir}" && $(BAZEL) query //:buf_format >/dev/null 2>&1); then \
			echo "$(BAZEL) run //:buf_format in $${dir}"; \
			(cd "$${dir}" && $(BAZEL) run //:buf_format); \
		fi; \
	done
	@# We want to operate on a list of modified and new files, excluding
	@# deleted and ignored files. git-ls-files can't do this alone. comm -23 takes
	@# two files and prints the union, dropping lines common to both (-3) and
	@# those only in the second file (-2). We make one git-ls-files call for
	@# the modified, cached, and new (--others) files, and a second for the
	@# deleted files.
	comm -23 \
		<(git ls-files --cached --modified --others --no-empty-directory --exclude-standard | sort -u | grep -v $(LICENSE_IGNORE) ) \
		<(git ls-files --deleted | sort -u) | \
		xargs $(BIN)/license-header \
			--license-type apache \
			--copyright-holder "Buf Technologies, Inc." \
			--year-range "$(COPYRIGHT_YEARS)"
	$(MAKE) format

.PHONY: checkgenerate
checkgenerate: generate ## Run generate and fail if anything changed
	git diff --exit-code --stat

$(BIN)/license-header: Makefile
	@mkdir -p $(@D)
	GOBIN=$(abspath $(@D)) $(GO) install \
		  github.com/bufbuild/buf/private/pkg/licenseheader/cmd/license-header@$(LICENSE_HEADER_VERSION)
