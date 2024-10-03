package main

import (
	"os"
	"strings"

	"github.com/charmbracelet/log"
)

// XDG HOME
func getConfDir() string {
	var dir string

	dir = os.Getenv("DOTSHIP_CONF")
	if dir != "" {
		return dir
	}

	dir, err := os.UserConfigDir()
	if err != nil {
		log.Fatal("Can't find the user Directory\nAs $HOME is not found.")
	}

	dir = dir + "/dotship"
	return dir
}

// Get Files from Directory
func getAllFiles(cDir string) []string {
	entries, err := os.ReadDir(cDir)
	if err != nil {
		log.Fatal("Unable to read dir %s", err)
	}

	// Make slice and append files only.
	var files []string

	for _, file := range entries {
		log.Debug("File Found: %s", file.Name())
		if file.IsDir() != true {
			files = append(files, file.Name())
		}
	}

	return files
}

// Decode file path
func decodePath(pathStr string) string {
	path := getConfDir()

	tmp := strings.ReplaceAll(pathStr, "@", "/")
	tmp = strings.ReplaceAll(tmp, "=", ".")
	log.Info(tmp)

	return path + "/" + tmp
}

// TODO: make it so force and custom dir can be set using env vars.
func sync(path string) {
	//Get dirs
	//path := getConfDir()
	//get list of files.
	encFilePaths := getAllFiles(path)
	//Decode paths
	for i, encPath := range encFilePaths {
		encFilePaths[i] = decodePath(encPath)
	}
	//symlinked them.
}

func main() {
	sync("/home/evil/.config/home-manager/confiles")
}
