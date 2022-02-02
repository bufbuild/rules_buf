package buf

type bufLang struct{}

func newBufLang() *bufLang {
	return &bufLang{}
}

func (*bufLang) Name() string { return lang }
