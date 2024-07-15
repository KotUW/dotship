import sys
import os
import re
import logging as log
from typing import List
from pathlib import Path

def get_config_dir_name()-> str:
    try:
        is_argv = sys.argv.index('-c')
        return sys.argv[is_argv+1]
    except ValueError:
        home = str(Path.home())
        return os.getenv("XDG_CONFIG_DIR", default=(home+"/.config/dotman"))

def makedir(PATH: str):
    if (os.path.exists(PATH)):
        log.debug(f"Found the config dir at: '{PATH}'")
    else:
        choice = (input(f"Couldn't find config path at {PATH}\n Want me to create it? [y/N] "))
        match choice:
            case 'y' | 'Y':
                os.makedirs(PATH) #Make dirs recursive
                print(f"Created config dir at {PATH}.")
            case _ :
                print("Exiting....")
                sys.exit(0)

def scan_dir(dir_path: str)-> List[str]:
    scanned_files = os.listdir(dir_path)
    return [files for files in scanned_files if files != 'dotman.lock']

def transform_files_path(list:  List[str])-> List[str]:
    out = []
    for name in list:
        out_name = re.sub(r"^=", ".", name)# Hidden files start with $
        out_name = out_name.replace('@', '/') # Seprator
        log.debug("Will create file at: '{}'".format(out_name))
        out.append(out_name)
    return out

def link_files(file_list: List[str], CONFIG_DIR: str):
    file_paths = transform_files_path(file_list)
    home = str(Path.home())
    for index, file_path in enumerate(file_paths):
        file_to = home+'/'+file_path
        file_from = CONFIG_DIR+"/"+file_list[index]
        try:
            os.symlink(file_from, file_to)
            log.info(f"Symlinked file {file_to} <- {file_from}")
        except FileExistsError:
            log.error(f"File exist in destination {file_to}")


def main():
    CONFIG_DIR = get_config_dir_name()
    log.debug(CONFIG_DIR)

    makedir(CONFIG_DIR)

    #with open(CONFIG_DIR+'/dotman.lock')
    #TODO: Use file to improve perf.

    link_files(scan_dir(CONFIG_DIR), CONFIG_DIR)


if __name__ == "__main__":
    log.basicConfig(level=log.DEBUG)
    main()
