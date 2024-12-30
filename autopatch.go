package main

import (
	"os"

	"github.com/darklab8/fl-data-discovery/autopatcher"
)

func main() {
	os.Chdir("./freelancer_folder")
	println(os.Getwd())
	autopatcher.RunAutopatcher()
}
