init:
    zig build run -- init
sync:
    zig build run -- sync
debug:
    zig build -freference-trace

clean:
    rm -fdr config
