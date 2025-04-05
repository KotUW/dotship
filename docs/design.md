# New Machine Flow

- Install **Dotship**
- `Dotship clone <git-repo>`
  + Makes a symliked shellscript in `.local/bin` which alias dotship to `DOTSHIP_REPO=<absolute:git-repo> <dotship_exe_path>`
  + Maybe use *libgit* insteadof calling to git.
- Read and parse the config file inside the repo (like `packege.json` or Cargo.toml)

== Now, There are two things to be done ==

## Dotfiles Managment

- For all the given apps.
  + Symlink there conf files to the appropiate directies (using `XDG_USER_DIRS` mayhaps?)
- `Add` / `Remove` / `Sync` commands to manage it.
  + `Remove` only remove the symlinks. `Purge` (-> to find & delete all the files in lock file that doesn't have a corspoding repo path.)

## Program Installer

- Get archtichure, OS, and distro info.
- For every app in the config file:
  + Query the universal DB (AppStore DB) to find the way to install given all the architecture requirments.
  + Download them
  + Symlink them to `.local/bin`

