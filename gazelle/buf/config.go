package buf

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/rule"
	"gopkg.in/yaml.v3"
)

type Config struct {
	configFilePath            string
	Module                    *ModuleConfig
	BreakingImageTarget       string
	BreakingExludeImports     bool
	BreakingLimitToInputFiles bool
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

type LintConfig struct {
	Use    []string `json:"use,omitempty" yaml:"use,omitempty"`
	Except []string `json:"except,omitempty" yaml:"except,omitempty"`

	EnumZeroValueSuffix *string `json:"enum_zero_value_suffix,omitempty" yaml:"enum_zero_value_suffix,omitempty"`
	AllowCommentIgnores *bool   `json:"allow_comment_ignores,omitempty" yaml:"allow_comment_ignores,omitempty"`

	RpcAllowSameRequestResponse          *bool `json:"rpc_allow_same_request_response,omitempty" yaml:"rpc_allow_same_request_response,omitempty"`
	RpcAllowGoogleProtobufEmptyRequests  *bool `json:"rpc_allow_google_protobuf_empty_requests,omitempty" yaml:"rpc_allow_google_protobuf_empty_requests,omitempty"`
	RpcAllowGoogleProtobufEmptyResponses *bool `json:"rpc_allow_google_protobuf_empty_responses,omitempty" yaml:"rpc_allow_google_protobuf_empty_responses,omitempty"`

	ServiceSuffix *string `json:"service_suffix,omitempty" yaml:"service_suffix,omitempty"`
}

type BreakingConfig struct {
	Use                    []string `json:"use,omitempty" yaml:"use,omitempty"`
	Except                 []string `json:"except,omitempty" yaml:"except,omitempty"`
	IgnoreUnstablePackages *bool    `json:"ignore_unstable_packages,omitempty" yaml:"ignore_unstable_packages,omitempty"`
}

func (*bufLang) RegisterFlags(flagSet *flag.FlagSet, cmd string, c *config.Config) {
	var cfg Config
	c.Exts[lang] = &cfg

	flagSet.StringVar(&cfg.configFilePath, "buf_config", "", "path to to buf config file will look for buf.yaml and buf.mod")
	flagSet.StringVar(&cfg.BreakingImageTarget, "buf_breaking_image", "", "buf_image target to check breaking changes")
	flagSet.BoolVar(&cfg.BreakingExludeImports, "buf_breaking_exclude_imports", true, "Exclude imports from breaking change detection")
	flagSet.BoolVar(&cfg.BreakingLimitToInputFiles, "buf_breaking_limit_to_input_files", true, "Limit breaking change detection to input files")
}
func (*bufLang) CheckFlags(flagSet *flag.FlagSet, c *config.Config) error {
	cfg := GetConfig(c)

	if cfg.configFilePath == "" {
		for _, file := range []string{"buf.yaml", "buf.mod"} {
			bc, err := readConfig(filepath.Join(c.RepoRoot, file))
			if errors.Is(err, fs.ErrNotExist) {
				continue
			}
			if err != nil {
				return fmt.Errorf("buf: unable to parse buf config file at %s, err: %w", file, err)
			}

			cfg.Module = bc
			break
		}

		// Reverts to default config on individual rules
		return nil
	}

	bc, err := readConfig(filepath.Join(c.RepoRoot, cfg.configFilePath))
	if err != nil {
		return fmt.Errorf("buf: unable to parse buf config file at %s, err: %w", cfg.configFilePath, err)
	}

	cfg.Module = bc

	return nil
}

func (*bufLang) KnownDirectives() []string { return []string{"buf_config"} }
func (*bufLang) Configure(c *config.Config, rel string, f *rule.File) {
	cfg := GetConfig(c)
	if f == nil {
		return
	}

	for _, d := range f.Directives {
		switch d.Key {
		case "buf_config":
			cfg.configFilePath = d.Value
			bc, err := readConfig(filepath.Join(c.RepoRoot, cfg.configFilePath))
			if err == nil {
				cfg.Module = bc
			}
		}
	}
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

func parseJsonOrYaml(data []byte, v interface{}) error {
	if err := yaml.Unmarshal(data, v); err != nil {
		if err := json.Unmarshal(data, v); err != nil {
			return err
		}
	}

	return nil
}
