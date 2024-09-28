run: dev
add:
    fish -c 'python3 main.py add "/home/evil/.config/helix/" -c (pwd)"/config"'

dev:
    fish -c 'python3 main.py -c (pwd)"/config"'
