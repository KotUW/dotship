run: build
    -@rm test/help.txt
    DOTSHIP_CONF=./test ./dotship

build:
    go build
