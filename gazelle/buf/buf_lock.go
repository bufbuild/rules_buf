package buf

import "os"

type bufLock struct {
	Version string `yaml:"version,omitempty" json:"version,omitempty"`
	Deps    []struct {
		Remote     string `yaml:"remote,omitempty" json:"remote,omitempty"`
		Owner      string `yaml:"owner,omitempty" json:"owner,omitempty"`
		Repository string `yaml:"repository,omitempty" json:"repository,omitempty"`
		Commit     string `yaml:"commit,omitempty" json:"commit,omitempty"`
	} `yaml:"deps,omitempty" json:"deps,omitempty"`
}

func readBufLock(file string) (*bufLock, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}
	var bufLock bufLock
	return &bufLock, parseJsonOrYaml(data, &bufLock)
}
