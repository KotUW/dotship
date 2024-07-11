dev:
    zig build run
test-release: clean build
    ./zig-out/bin/dotman
test-debug: clean dev
build:
    zig build --release=safe --summary new

clean:
    rm -fdr config
