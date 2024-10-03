package main

import (
	"os"

	"github.com/charmbracelet/log"
)

func getXdgHome() string {
	dir := os.Getenv("XDG_CONFIG_HOME")
	if dir == "" {
		log.Info("Couldn't get XDG_CONFIG_HOME")
		dir = os.Getenv("HOME") + "/.config"
	}
	dir = dir + "/dotship"
	return dir

}

func main() {
	log.Print(getXdgHome())
}
