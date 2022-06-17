// buf_test runs gazelle binary with buf langugae extension installed
// alongside the default ones. It runs in each directory in testdata
package buf_test

import (
	"os"
	"os/exec"
	"path"
	"runtime"
	"strings"
	"testing"

	"github.com/bazelbuild/bazel-gazelle/testtools"
	"github.com/bazelbuild/rules_go/go/tools/bazel"
	"github.com/stretchr/testify/require"
)

func TestLint(t *testing.T) {
	t.Parallel()
	testRunGazelle(t, "lint")
}

func TestBreaking(t *testing.T) {
	t.Parallel()
	testRunGazelle(t, "breaking_module")
	testRunGazelle(t, "breaking_package")
	testRunGazelle(t, "breaking_package_to_module")
}

func TestExcludes(t *testing.T) {
	t.Parallel()
	testRunGazelle(t, "excludes_module")
	testRunGazelle(t, "excludes_package")
}

func TestWorkspaces(t *testing.T) {
	t.Parallel()
	testRunGazelle(t, "workspace")
}

func TestCrossResolve(t *testing.T) {
	t.Parallel()
	testRunGazelle(t, "cross_resolve")
}

func TestImportResolve(t *testing.T) {
	t.Parallel()
	testRunGazelle(t, "imports", "update-repos", "--from_file=buf.work.yaml", "-to_macro=buf_deps.bzl%buf_deps", "-prune")
	testRunGazelle(t, "imports_toolchain_name", "update-repos", "--from_file=buf.work.yaml", "-to_macro=buf_deps.bzl%buf_deps", "-prune")
}

func testRunGazelle(t *testing.T, name string, gazelleArgs ...string) {
	t.Run(name, func(t *testing.T) {
		t.Parallel()
		gazellePath, ok := bazel.FindBinary("gazelle/buf", "gazelle-buf")
		require.True(t, ok, "could not find gazelle binary")
		inputs, goldens := getTestData(t, path.Join("gazelle/buf/testdata", name))
		dir, cleanup := testtools.CreateFiles(t, inputs)
		defer cleanup()
		cmd := exec.Command(gazellePath, append(gazelleArgs, "-build_file_name=BUILD")...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Dir = dir
		err := cmd.Run()
		require.NoErrorf(t, err, "cmd: %q", gazellePath)
		testtools.CheckFiles(t, dir, goldens)
	})
}

func getTestData(t *testing.T, dir string) (inputs []testtools.FileSpec, goldens []testtools.FileSpec) {
	allFiles, err := bazel.ListRunfiles()
	require.NoError(t, err, "bazel.ListRunfiles()")
	require.True(t, len(allFiles) > 0, "0 runfiles")
	var hasWorkspace bool
	for _, f := range allFiles {
		if !strings.HasPrefix(f.ShortPath, dir+"/") {
			continue
		}
		shortPath := strings.TrimPrefix(f.ShortPath, dir+"/")
		info, err := os.Stat(f.Path)
		require.NoErrorf(t, err, "os.Stat(%q)", f.Path)
		// Skip dirs.
		if info.IsDir() {
			continue
		}
		content, err := os.ReadFile(f.Path)
		require.NoErrorf(t, err, "ioutil.ReadFile(%q)", f.Path)
		// Now trim the common prefix off.
		filePath := shortPath
		v := path.Ext(shortPath)
		if v == ".in" || v == ".out" {
			filePath = strings.TrimSuffix(shortPath, v)
		}
		if filePath == "WORKSPACE" {
			hasWorkspace = true
		}
		fileSpec := testtools.FileSpec{
			Path:    filePath,
			Content: string(content),
		}
		if runtime.GOOS == "windows" {
			fileSpec.Content = strings.ReplaceAll(fileSpec.Content, "\r\n", "\n")
		}
		if v != ".out" {
			inputs = append(inputs, fileSpec)
		}
		if v != ".in" {
			goldens = append(goldens, fileSpec)
		}
	}
	require.True(t, len(inputs) > 0, "0 inputs read")
	// Add workspace for gazelle to work
	if !hasWorkspace {
		inputs = append(inputs, testtools.FileSpec{
			Path:    "WORKSPACE",
			Content: "",
		})
		goldens = append(goldens, testtools.FileSpec{
			Path:    "WORKSPACE",
			Content: "",
		})
	}
	return inputs, goldens
}
