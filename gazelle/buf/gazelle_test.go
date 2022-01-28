package buf

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/bazelbuild/bazel-gazelle/testtools"
	"github.com/bazelbuild/rules_go/go/tools/bazel"
)

var gazellePath = findGazelle()

const testDataPath = "gazelle/buf/testdata/"

// TestGazelleExtension runs gazelle binary with buf langugae extension installed
// alongside the default ones. It runs in eacg directory in testdata
func TestGazelleExtension(t *testing.T) {
	files, err := bazel.ListRunfiles()
	if err != nil {
		t.Fatalf("bazel.ListRunfiles() error: %v", err)
	}

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

	if len(tests) == 0 {
		t.Fatal("no tests found")
	}

	for name, files := range tests {
		testCase(t, name, files)
	}
}

func testCase(t *testing.T, name string, files []bazel.RunfileEntry) {
	t.Run(name, func(t *testing.T) {
		var inputs []testtools.FileSpec
		var goldens []testtools.FileSpec

		for _, f := range files {
			path := f.Path
			trim := testDataPath + name + "/"
			shortPath := strings.TrimPrefix(f.ShortPath, trim)
			info, err := os.Stat(path)
			if err != nil {
				t.Fatalf("os.Stat(%q) error: %v", path, err)
			}

			// Skip dirs.
			if info.IsDir() {
				continue
			}

			content, err := os.ReadFile(path)
			if err != nil {
				t.Errorf("ioutil.ReadFile(%q) error: %v", path, err)
			}

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
		if err := cmd.Run(); err != nil {
			t.Fatal(err)
		}

		testtools.CheckFiles(t, dir, goldens)
		if t.Failed() {
			filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
				if err != nil {
					return err
				}

				if info.IsDir() {
					return nil
				}

				t.Logf("%q exists", path)
				return nil
			})
		}
	})
}

func findGazelle() string {
	gazellePath, ok := bazel.FindBinary("gazelle/buf", "gazelle-buf")
	if !ok {
		panic("could not find gazelle binary")
	}
	return gazellePath
}
