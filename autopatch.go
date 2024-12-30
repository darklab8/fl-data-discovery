package main

import (
	"flag"
	"os"

	"github.com/darklab8/fl-data-discovery/autopatcher"
)

func main() {
	f := flag.String("wd", ".", "...")
	flag.Parse()
	os.Chdir(*f)
	println(os.Getwd())

	autopatcher.RunAutopatcher()
}
