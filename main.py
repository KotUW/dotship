from os.path import isdir
import sys
import os
import re
import logging as log
from typing import List
from pathlib import Path

def get_config_dir_name()-> str:
    try:
        is_argv = sys.argv.index('-c')
        user_path = sys.argv[is_argv+1]
        user_path = Path(user_path)
        if not user_path.is_absolute():
            log.error("Only support absolute dir paths")
            sys.exit(2)
        elif not user_path.is_dir():
            log.error("Only support dir\n try removing trailin `/`")
            sys.exit(3)

        # assert not Path(user_path).is_absolute(), "Only support absolute dir paths"
        return str(user_path)
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

def decode_file_path(name:  str)-> str:
    out_name = re.sub(r"^=", ".", name)# Hidden files start with $
    out_name = out_name.replace('@', '/') # Seprator
    log.debug("Will create file at: '{}'".format(out_name))
    return out_name

def link_files(file_list: List[str], CONFIG_DIR: str, forced=False):
    file_paths = [decode_file_path(files_path) for files_path in file_list]
    home = str(Path.home())
    for index, file_path in enumerate(file_paths):
        file_dst = home+'/'+file_path
        file_src = CONFIG_DIR+"/"+file_list[index]
        try:
            os.symlink(file_src, file_dst)
            log.info(f"Symlinked file {file_dst} <- {file_src}")
        except FileExistsError:
            #check if file is symlinked correctly.
            fd = Path(file_dst)
            if fd.is_symlink():
                if fd.readlink().name == file_list[index]:
                    log.info(f"File {file_dst} is symlinked correctly")
                    continue
                else:
                    log.error("File is symlinked incorrectly")
            if forced:
                #Remove it! Not sure about this!! Will it deleete the file or the directory containg it.
                # fd.rmdir()
                #try again
                os.symlink(file_src, file_dst)
                log.info(f"Symlinked file {file_dst} <- {file_src}")
            log.error(f"File exist in destination {file_dst}")

def encode_file_path(fp: str)-> str:
    fp = re.sub(r'^/', '', fp)
    fp = fp.replace('/', '@')
    fp = re.sub(r'^\.', '=', fp)
    log.debug(f"Encoded file to {fp}")
    return fp

def add_cmd(file_path: Path, CD: str):
    newpath = CD+"/"+encode_file_path(str(file_path).replace(str(file_path.home()), ''))
    file_path.rename(newpath)
    log.info(f"Moved file to {newpath}")

def main():
    CONFIG_DIR = get_config_dir_name()
    log.debug(CONFIG_DIR)
    makedir(CONFIG_DIR)


    isForced: bool = '-f' in sys.argv
    assert not isForced, "Not Implemented!!"

    isAdd: bool = 'add' in sys.argv
    if isAdd:
        add_file_path = Path(sys.argv[sys.argv.index('add')+1])
        log.debug(f"File path recieved is {add_file_path.is_file()} ")
        if not add_file_path.is_absolute(): log.error("File path has to be absolute!"); exit(5)
        if not add_file_path.is_file(): log.error("File path must be a file!"); exit(6)
        add_cmd(Path(add_file_path), CONFIG_DIR)

    #with open(CONFIG_DIR+'/dotman.lock')
    #TODO: Use file to improve perf.

    link_files(scan_dir(CONFIG_DIR), CONFIG_DIR, isForced)


if __name__ == "__main__":
    log.basicConfig()
    main()
