package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
)

func main() {
	var (
		bufVersion = flag.String("buf-version", "", "Buf version [required]")
	)

	log.SetFlags(0)
	log.SetOutput(os.Stderr)

	flag.Parse()

	if *bufVersion == "" {
		log.Fatalln("buf-version is missing and is required")
	}

	res, err := http.Get(fmt.Sprintf("https://github.com/bufbuild/buf/releases/download/%s/sha256.txt", *bufVersion))
	if err != nil {
		log.Fatalf("unable to read buf release sum file for version: %s, err: %v", *bufVersion, err)
	}
	defer res.Body.Close()

	sumScanner := bufio.NewScanner(res.Body)

	fmt.Println("buf_toolchains_dependecies = {")
	for sumScanner.Scan() {
		line := sumScanner.Text()
		if strings.HasSuffix(line, ".tar.gz") {
			continue
		}

		var sum, bin string
		fmt.Sscanf(line, "%s %s", &sum, &bin)

		url := fmt.Sprintf("https://github.com/bufbuild/buf/releases/download/%s/%s", *bufVersion, bin)

		bin = strings.ToLower(bin)
		// Bazel defines macOS as osx
		bin = strings.ReplaceAll(bin, "darwin", "osx")
		// Windows binaries are suffixed with .exe. This only effects the targets name and the binary will continue to have the suffix.
		bin = strings.TrimSuffix(bin, ".exe")

		fmt.Printf("\t%q: {\n", bin)
		fmt.Printf("\t\t\"sha256\": %q,\n", sum)
		fmt.Printf("\t\t\"urls\": [%q],\n", url)
		fmt.Printf("\t\t\"executable\": True,\n")
		fmt.Println("\t},")
	}
	fmt.Println("}")
}
