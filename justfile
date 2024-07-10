run: clean
    zig build run
debug:
    zig build -freference-trace
build:
    zig build --release=safe --summary new

clean:
    rm -fdr config
