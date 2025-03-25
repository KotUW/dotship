# Figuring out what we want.

## Add *name* *filename*

Given a filename. it should add it to config the name and move the filename to the git reo.

## Remove *name*

Should remove it from config.

## Sync *name*

Should take all the data in the configFile and make sure the things in are true.

## (otional) TUI

Can select things from config to toggle on and off.

## Tech

Need two files.

- One is just a hashma of `<name>:<storePath>:<configPath>`
  + One.a (optional) whatt if multiple file assosciated with a same app? = Nothing changes in files just behaviour changes to all file.
- Secound, just a list of names. which specify for which to create the `storePath`

## Terminology

- storePath => the path in the folder that we will sync
- name => name of the application for which this file is associated.
- configPath => Where the app expect the file.
- configFile => Where the app stores the info. The  DB essentially.
- DotsDir => where all the config path are stored.
