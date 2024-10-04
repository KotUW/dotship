package main

import (
	"os"
	"path"
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

func encodePath(plainPath string) string {
	plainPath = strings.ReplaceAll(plainPath, "/", "@")
	plainPath = strings.ReplaceAll(plainPath, ".", "=")

	return plainPath
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
				log.Infof("File %s already linked or Exists", newPath)
				continue
			}
			log.Fatal("Error when trying to symlink", err.Error())
		}

		log.Infof("Symlinked to %s", newPath)
	}
}

func add() {
	if len(os.Args) < 3 {
		log.Errorf("Usage: %s add [filepath]", os.Args[0])
		os.Exit(1)
	}

	addPath := path.Clean(os.Args[2])
	if !path.IsAbs(addPath) {
		wd, err := os.Getwd()
		if err != nil {
			log.Fatal("Can't get Working Dir.", "err", err)
		}
		log.Debug("Detected Relative path")
		addPath = path.Join(wd, addPath)
	}
	log.Debug("Resolved file path", "file", addPath)

	encPath := path.Join(getConfDir(), encodePath(addPath))

	err := os.Rename(addPath, encPath)
	if err != nil {
		log.Fatal("Failed to create file", "err", err)
	}
	log.Info("Created", "file", encPath)

	// _, err := os.Stat(encPath)
	// if os.IsNotExist(err) {
	// 	file, err := os.Create(encPath)
	// 	if err != nil {
	// 		log.Fatal("Failed to create ", "file", err)
	// 	}
	// 	defer file.Close()

	// 	log.Infof("Created new file at %s", encPath)
	// } else if err != nil {
	// 	log.Fatal("Accessing", "file", err)
	// }

}

func main() {
	if len(os.Args) < 2 {
		log.Errorf("Usage: %s <add/sync> [filepath]", os.Args[0])
		os.Exit(1)
	}

	log.SetLevel(log.DebugLevel)

	switch os.Args[1] {
	case "sync":
		sync()
	case "add":
		add()
	default:
		{
			log.Fatal("Invalid sub-command. Only Add and Sync supported.", "cmd", os.Args[1])
		}
	}

}
