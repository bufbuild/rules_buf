package buf

import (
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/bazelbuild/bazel-gazelle/testtools"
	"github.com/bazelbuild/rules_go/go/tools/bazel"
	"github.com/stretchr/testify/require"
)

const testDataPath = "gazelle/buf/testdata/"

// TestGazelleExtension runs gazelle binary with buf langugae extension installed
// alongside the default ones. It runs in each directory in testdata
func TestGazelleExtension(t *testing.T) {
	gazellePath := findGazelle(t)
	files, err := bazel.ListRunfiles()
	require.NoError(t, err, "bazel.ListRunfiles()")
	tests := map[string][]bazel.RunfileEntry{}
	for _, f := range files {
		if !strings.HasPrefix(f.ShortPath, testDataPath) {
			continue
		}
		relativePath := strings.TrimPrefix(f.ShortPath, testDataPath)
		parts := strings.SplitN(relativePath, "/", 2)
		if len(parts) < 2 {
			// It must be the directory itself
			continue
		}
		tests[parts[0]] = append(tests[parts[0]], f)
	}
	require.True(t, len(tests) > 0, "no tests found")
	for name, files := range tests {
		testCase(t, name, gazellePath, files)
	}
}

func testCase(t *testing.T, name string, gazellePath string, files []bazel.RunfileEntry) {
	t.Run(name, func(t *testing.T) {
		var inputs, goldens []testtools.FileSpec
		for _, f := range files {
			path := f.Path
			trim := testDataPath + name + "/"
			shortPath := strings.TrimPrefix(f.ShortPath, trim)
			info, err := os.Stat(path)
			require.NoErrorf(t, err, "os.Stat(%q)", path)
			// Skip dirs.
			if info.IsDir() {
				continue
			}
			content, err := os.ReadFile(path)
			require.NoErrorf(t, err, "ioutil.ReadFile(%q)", path)
			// Now trim the common prefix off.
			if strings.HasSuffix(shortPath, ".in") {
				inputs = append(inputs, testtools.FileSpec{
					Path:    strings.TrimSuffix(shortPath, ".in"),
					Content: string(content),
				})
			} else if strings.HasSuffix(shortPath, ".out") {
				goldens = append(goldens, testtools.FileSpec{
					Path:    strings.TrimSuffix(shortPath, ".out"),
					Content: string(content),
				})
			} else {
				inputs = append(inputs, testtools.FileSpec{
					Path:    shortPath,
					Content: string(content),
				})
				goldens = append(goldens, testtools.FileSpec{
					Path:    shortPath,
					Content: string(content),
				})
			}
		}
		// Add workspace for gazelle to work
		inputs = append(inputs, testtools.FileSpec{
			Path:    "WORKSPACE",
			Content: "",
		})
		goldens = append(goldens, testtools.FileSpec{
			Path:    "WORKSPACE",
			Content: "",
		})
		dir, cleanup := testtools.CreateFiles(t, inputs)
		defer cleanup()
		cmd := exec.Command(gazellePath, "-build_file_name=BUILD")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Dir = dir
		err := cmd.Run()
		require.NoErrorf(t, err, "cmd: %q", gazellePath)
		testtools.CheckFiles(t, dir, goldens)
	})
}

func findGazelle(t *testing.T) string {
	t.Helper()
	gazellePath, ok := bazel.FindBinary("gazelle/buf", "gazelle-buf")
	require.True(t, ok, "could not find gazelle binary")
	return gazellePath
}
