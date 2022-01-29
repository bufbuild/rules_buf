package buf

import (
	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/language"
)

type Config struct {
	// Partial `buf.yaml` config
	Module *BufModule
	// The image target to check against. Typically a label pointing to a file
	BreakingImageTarget string
	// Controls exclude_imports attribute on buf_breaking_test
	BreakingExcludeImports bool
	// Controls if buf_breaking_test should be generated for each bazel package
	// or should it be generared corresponding to each buf module (default)
	BreakingLimitToInputFiles bool
	// ModuleRoot indicates whether the current directory is the root of buf module
	ModuleRoot bool
	// ConfigFile is for the nearest buf.yaml
	ConfigFile label.Label
}

type BufModule struct {
	Version string       `json:"version,omitempty" yaml:"version,omitempty"`
	Name    string       `json:"name,omitempty" yaml:"name,omitempty"`
	Build   *BuildConfig `json:"build,omitempty" yaml:"build,omitempty"`
}

type BuildConfig struct {
	Excludes []string `json:"excludes,omitempty" yaml:"excludes,omitempty"`
}

func GetConfigForGazelleConfig(c *config.Config) *Config {
	return getConfigForGazelleConfig(c)
}

func SetConfigForGazelleConfig(c *config.Config, cfg *Config) {
	setConfigForGazelleConfig(c, cfg)
}

// NewLanguage is called by Gazelle to install this language extension in a binary.
func NewLanguage() language.Language {
	return newBufLang()
}
