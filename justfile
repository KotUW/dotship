run: build
    -@rm test/help.txt
    -@rm test/@home@evil@work@proj@dotship-go@love=txt
    -@touch love.txt
    DOTSHIP_CONF=./test ./dotship add love.txt

build:
    go build
