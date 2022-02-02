package buf

import (
	"fmt"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/language"
)

const (
	// BreakingModeModule will generate a buf_breaking_test rule for each `buf.yaml`
	// This is the recommended and default strategy.
	BreakingModeModule BreakingMode = iota + 1
	// BreakingModePackage
	BreakingModePackage
)

const lang = "buf"

var (
	stringToBreakingMode = map[string]BreakingMode{
		"module":  BreakingModeModule,
		"package": BreakingModePackage,
	}
)

// BreakingMode is generation strategy for buf_breaking_test
//
// See BreakingModeModule and BreakingModePackage
type BreakingMode int

// ParseBreakingMode parses the BreakingMode.
//
// The empty strings defaults to BreakingModeModule.
func ParseBreakingMode(s string) (BreakingMode, error) {
	s = strings.ToLower(strings.TrimSpace(s))
	if s == "" {
		return BreakingModeModule, nil
	}
	f, ok := stringToBreakingMode[s]
	if ok {
		return f, nil
	}
	return 0, fmt.Errorf("unknown breaking mode: %q", s)
}

// Config holds the configuration if the buf gazelle extension
type Config struct {
	// Partial `buf.yaml` config applicable to the current directory.
	Module *BufModule
	// The image target to check against. Typically a label pointing to a file.
	BreakingImageTarget string
	// Controls exclude_imports attribute on buf_breaking_test.
	BreakingExcludeImports bool
	// Controls if buf_breaking_test should be generated for each bazel package
	// or should it be generared corresponding to each buf module (default)
	BreakingLimitToInputFiles bool
	// BreakingMode controls the generation of buf_breaking_test.
	// See BreakingModeModule and BreakingModePackage.
	//
	// Defaults to BreakingModeModule.
	BreakingMode BreakingMode
	// ModuleRoot indicates whether the current directory is the root of buf module
	ModuleRoot bool
	// BufConfigFile is for the nearest buf.yaml
	BufConfigFile label.Label
}

// BufModule is the parsed buf.yaml. It currently only supports version, name, and build
// top-level attributes.
type BufModule struct {
	Version string      `json:"version,omitempty" yaml:"version,omitempty"`
	Name    string      `json:"name,omitempty" yaml:"name,omitempty"`
	Build   BuildConfig `json:"build,omitempty" yaml:"build,omitempty"`
}

// BuildConfig is the build section of the buf.yaml
type BuildConfig struct {
	Excludes []string `json:"excludes,omitempty" yaml:"excludes,omitempty"`
}

// GetConfigForGazelleConfig extracts a Config from gazelle config.
// It will return `nil` if one is not found.
//
// See `SetConfigForGazelleConfig` for setting a Config.
func GetConfigForGazelleConfig(gazelleConfig *config.Config) *Config {
	config := gazelleConfig.Exts[lang]
	if config != nil {
		// This is set by us, see: `SetConfigForGazelleConfig`.
		// If a value is present it will be of type *Config
		//
		// Theoretically another plugin can use the same key ("buf") to set a different value
		// but the odds of that happening are next to none.
		return config.(*Config)
	}
	return nil
}

// SetConfigForGazelleConfig is used to associate Config with a gazelle config.
//
// It can be retreived using `GetConfigForGazelleConfig`
func SetConfigForGazelleConfig(gazelleConfig *config.Config, config *Config) {
	gazelleConfig.Exts[lang] = config
}

// NewLanguage is called by Gazelle to install this language extension in a binary.
func NewLanguage() language.Language {
	return newBufLang()
}
