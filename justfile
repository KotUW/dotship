add:
    zig build run -- add
init: clean
    zig build run -- init
sync:
    zig build run -- sync
debug:
    zig build -freference-trace
build:
    zig build --release=fast --summary new

clean:
    rm -fdr config
