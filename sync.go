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
		log.Debugf("File Found: %s", file.Name())
		if file.IsDir() != true {
			files = append(files, file.Name())
		}
	}

	return files
}

// Decode file path
func decodePath(pathStr string) string {
	path, err := os.UserHomeDir()
	if err != nil {
		log.Fatal("[ERROR] Unable to get home dir", err)
	}

	tmp := strings.ReplaceAll(pathStr, "@", "/")
	tmp = strings.ReplaceAll(tmp, "=", ".")

	tmp = path + "/" + tmp
	log.Debug("Decoded", "Path", tmp)

	return tmp
}

// TODO: make it so force deletes all symlinks and re-creates them.
func sync() {
	//Get dirs
	path := getConfDir()
	//get list of files.
	encFilePaths := getAllFiles(path)
	//Decode paths
	var decodedPAths []string
	for _, encPath := range encFilePaths {
		decodedPAths = append(decodedPAths, decodePath(encPath))
	}

	for i, newPath := range decodedPAths {
		oldPath := path + "/" + encFilePaths[i]
		err := os.Symlink(oldPath, newPath)
		if err != nil {
			//Handel file exist error
			if strings.Contains(err.Error(), "file exists") {
				log.Infof("File %s already linked", newPath)
				continue
			}
			log.Fatal("Error when trying to symlink", err.Error())
		}

		log.Infof("Symlinked to %s", newPath)
	}
}

func main() {
	log.SetLevel(log.DebugLevel)
	sync()
	//TODO: ADD
}
