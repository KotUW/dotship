import sys
import os
import logging
from typing import List

def get_config_dir_name()-> str:
    try:
        is_argv = sys.argv.index('-c')
        return sys.argv[is_argv+1]
    except ValueError:
        return os.getenv("XDG_CONFIG_DIR", default="~/.config/dotman")

def scan_dir(dir_path: str)-> List[str]:
    scanned_files = os.listdir(dir_path)
    return [files for files in scanned_files if files != 'dotman.lock']


def main():
    CONFIG_DIR = get_config_dir_name()

    # MAke directory
    try:
        os.makedirs(CONFIG_DIR) #Make dirs recursive
    except FileExistsError:
        logging.debug("Found the config dir at ", CONFIG_DIR)

    #with open(CONFIG_DIR+'/dotman.lock')
    #TODO: Use file to improve perf.

    print(scan_dir(CONFIG_DIR))



if __name__ == "__main__":
    main()
