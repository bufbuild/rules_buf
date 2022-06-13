package buf

import "os"

type bufWork struct {
	Version     string   `yaml:"version,omitempty" json:"version,omitempty"`
	Directories []string `yaml:"directories,omitempty" json:"directories,omitempty"`
}

func readBufWork(file string) (*bufWork, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}
	var bufWork bufWork
	return &bufWork, parseJsonOrYaml(data, &bufWork)
}
