const std = @import("std");
//TODO: Make a function to calculate the value. but it will need alloc and shit.
const State = struct {
    pub const configDirPath = "/home/evil/work/proj/dotman/config";
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    const prog_name = args.next().?;
    const sub_cmd = args.next();

    if (sub_cmd == null) {
        try stdout.print("[ERROR] Invalid Subcommand\nUsage: {s} Subcommand\n", .{prog_name});
        return;
    }

    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "sync") == 0) {
        std.debug.print("cmd = sync\n", .{});
        // sync();
    }

    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "init") == 0) {
        std.debug.print("cmd = init\n", .{});
        try init();
    }
}

fn init() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Initlizing {s} dir as the config directory.", .{State.configDirPath});
    try stdout.writeAll("\nWill Create Dir. Continue? (y/n) ");
    switch (choice()) {
        'y' => {},
        'n' => return,
        else => return ChoiceError.Invalid,
    }
    std.fs.makeDirAbsolute(State.configDirPath) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => unreachable,
    };

    // const configD = try std.fs.openDirAbsolute(State.configDirPath, .{});
}

const ChoiceError = error{
    Invalid,
};

fn choice() u8 {
    const stdin = std.io.getStdIn().reader();
    // var buf: [3]u8 = undefined; //Just going to use single letters for choices atm

    const ans = stdin.readBytesNoEof(2) catch unreachable;
    return ans[0];
}

// fn sync() void {

//try to make the Directory. Cach assuming already exist
// const confDir = std.fs.openDirAbsolute(configDir, .{}) catch |err| {
//     std.log.info("Couldn't open config directory (rc) at {s}\n\tYou can initiante new one using init.", .{});
//     return err;
// };
// std.fs.opDirAbsolute(configDir) catch |err| {
//     if (err != error.PathAlreadyExists) return err;
// };

// const lockFilePath = configDir ++ "lock.json";
// const userFilePath = configDir ++ "user.toml";
// const lockFiled = std.fs.openFileAbsolute(lockFilePath, .{}) catch |err| {
//     if (err == error.FileNotFound) std.fs.createFileAbsolute(lockFilePath, .{}) catch unreachable;
//     unreachable;
// };

// const lockFiled = std.fs.openFileAbsolute(lockFilePath, .{}) catch |err| blk: {
//     if (err == error.FileNotFound) break :blk try std.fs.createFileAbsolute(lockFilePath, .{ .truncate = false });
//     return err;
// };
// const userFiled = std.fs.createFileAbsolute(userFilePath, .{ .truncate = false }) catch |err| {
//     if (err != error.PathAlreadyExists) return err;
// };
// _ = userFiled;

// const readBuf = try alloc.alloc(u8, 512);
// defer alloc.free(readBuf);

// const rAmt = try lockFiled.read(readBuf);
// std.log.debug("{s}", .{readBuf});}
