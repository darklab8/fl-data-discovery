package main

import (
	"flag"
	"os"

	"github.com/darklab8/fl-data-discovery/autopatcher"
)

func main() {
	f := flag.String("wd", ".", "...")
	flag.Parse()

	err := autopatcher.RunAutopatcher(*f)
	if err != nil {
		os.Exit(1)
	}
}
