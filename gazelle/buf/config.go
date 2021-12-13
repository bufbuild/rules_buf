package buf

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/rule"
	"gopkg.in/yaml.v3"
)

type Config struct {
	// buf.yaml
	Module *ModuleConfig

	// Global Flags
	LogLevel    string
	LogFormat   string
	ErrorFormat string

	BreakingImageTarget       string
	BreakingExcludeImports    bool
	BreakingLimitToInputFiles bool

	ModuleRoot bool
}

type ModuleConfig struct {
	Version  string          `json:"version,omitempty" yaml:"version,omitempty"`
	Name     string          `json:"name,omitempty" yaml:"name,omitempty"`
	Deps     []string        `json:"deps,omitempty" yaml:"deps,omitempty"`
	Build    *BuildConfig    `json:"build,omitempty" yaml:"build,omitempty"`
	Lint     *LintConfig     `json:"lint,omitempty" yaml:"lint,omitempty"`
	Breaking *BreakingConfig `json:"breaking,omitempty" yaml:"breaking,omitempty"`
}

type BuildConfig struct {
	Excludes []string `json:"excludes,omitempty" yaml:"excludes,omitempty"`
}

func (*bufLang) RegisterFlags(flagSet *flag.FlagSet, cmd string, c *config.Config) {
	SetConfig(c, &Config{
		BreakingExcludeImports:    true,
		BreakingLimitToInputFiles: false,
	})
}

func (*bufLang) CheckFlags(flagSet *flag.FlagSet, c *config.Config) error { return nil }

func (*bufLang) KnownDirectives() []string {
	return []string{
		"buf_config",

		"buf_log_level",
		"buf_log_format",
		"buf_error_format",

		"buf_breaking_against",
		"buf_breaking_exclude_imports",
		"buf_breaking_limit_to_input_files",
	}
}

func (*bufLang) Configure(c *config.Config, rel string, f *rule.File) {
	cfg := loadConfig(c, rel, f)
	SetConfig(c, cfg)
}

func loadConfig(c *config.Config, rel string, f *rule.File) *Config {
	cfg := *GetConfig(c)

	cfg.ModuleRoot = false
	bc, err := loadDefaultConfig(filepath.Join(c.RepoRoot, rel))
	if err != nil {
		log.Println("error trying to load default config", err)
	}
	if bc != nil {
		cfg.Module = bc
		cfg.ModuleRoot = true
	}

	if f == nil {
		return &cfg
	}

	for _, d := range f.Directives {
		switch d.Key {
		case "buf_config":
			configPath := filepath.Join(c.RepoRoot, rel, d.Value)
			bc, err := readConfig(configPath)
			if err != nil {
				log.Fatalf("unable to find buf config file at %s, directive specified in %s", configPath, rel)
			}

			cfg.Module = bc
			cfg.ModuleRoot = true
		// Global Options
		case "buf_log_level":
			cfg.LogLevel = d.Value
		case "buf_log_format":
			cfg.LogFormat = d.Value
		case "buf_error_format":
			cfg.ErrorFormat = d.Value
		// Breaking config
		case "buf_breaking_against":
			cfg.BreakingImageTarget = d.Value
		case "buf_breaking_exclude_imports":
			value, err := strconv.ParseBool(strings.TrimSpace(d.Value))
			if err != nil {
				log.Fatalf("buf_breaking_exclude_imports directive should be a boolean got: %s", d.Value)
			}
			cfg.BreakingExcludeImports = value
		case "breaking_limit_to_input_files":
			value, err := strconv.ParseBool(strings.TrimSpace(d.Value))
			if err != nil {
				log.Fatalf("breaking_limit_to_input_files directive should be a boolean got: %s", d.Value)
			}
			cfg.BreakingLimitToInputFiles = value
		}
	}

	return &cfg
}

func readConfig(file string) (*ModuleConfig, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}

	var cfg ModuleConfig
	return &cfg, parseJsonOrYaml(data, &cfg)
}

func GetConfig(c *config.Config) *Config {
	cfg := c.Exts[lang]
	if cfg != nil {
		return cfg.(*Config)
	}

	return nil
}

func SetConfig(c *config.Config, cfg *Config) {
	c.Exts[lang] = cfg
}

func parseJsonOrYaml(data []byte, v interface{}) error {
	if err := yaml.Unmarshal(data, v); err != nil {
		if err := json.Unmarshal(data, v); err != nil {
			return err
		}
	}

	return nil
}

func loadDefaultConfig(wd string) (*ModuleConfig, error) {
	for _, file := range []string{
		"buf.yaml",
		"buf.mod",
	} {
		bc, err := readConfig(filepath.Join(wd, file))
		if errors.Is(err, fs.ErrNotExist) {
			continue
		}
		if err != nil {
			return nil, fmt.Errorf("buf: unable to parse buf config file at %s, err: %w", file, err)
		}

		return bc, nil
	}

	return nil, nil
}
