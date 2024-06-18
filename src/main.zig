const std = @import("std");
//TODO: Make a function to calculate the value. but it will need alloc and shit.
const State = struct {
    pub const configDirPath = "/home/evil/work/proj/dotman/config";
    pub const lockFileName = "lock.json";
    pub const configFileName = "dotman.toml";
};

pub fn usage(p_name: []const u8) !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("Usage: {s} <subcommand> [args]\n", .{p_name});
    try stdout.writeAll("\nadd <file path>    : Adds a new file to track.\n");
    try stdout.writeAll("sync                 : Fetches and updates all the fetched files.\n");
    try stdout.writeAll("init                 : Initilizes the files and stores. Run this first.\n");
    try stdout.writeAll("help                 : Shows this help.\n");
}

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
        try stdout.print("[ERROR] Invalid Subcommand\n", .{});
        try usage(prog_name);
        return;
    }

    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "sync") == 0) {
        std.debug.print("cmd = sync\n", .{});
        unreachable; // sync();
    }

    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "add") == 0) {
        std.debug.print("cmd = add\n", .{});

        const file_path = args.next();
        if (file_path == null) {
            std.log.err("Can't find file path. add expects an argument", .{});
            try usage(prog_name);
            return;
        } else {
            add(file_path.?);
        }
    }
    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "init") == 0) {
        std.debug.print("cmd = init\n", .{});
        try init();
    }

    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "help") == 0) {
        std.debug.print("cmd = help\n", .{});
        try usage(prog_name);
    }

    try stdout.writeAll("Bye.\n");
}

fn add(file_path: []const u8) void {
    _ = file_path;
    return;
}

fn init() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Initlizing \"{s}\" dir as the config directory.", .{State.configDirPath});
    try stdout.writeAll("\nWill Create Dir. Continue? (y/n) ");
    _ = switch (choice()) {
        'y' => {},
        'n' => return,
        else => return ChoiceError.Invalid,
    };

    std.fs.makeDirAbsolute(State.configDirPath) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    std.log.debug("Done with Directory", .{});

    const configD = try std.fs.openDirAbsolute(State.configDirPath, .{});
    const confFD = try configD.createFile(State.lockFileName, .{ .truncate = false });
    defer confFD.close();
    const lockFD = try configD.createFile(State.lockFileName, .{ .truncate = false });
    defer lockFD.close();

    //Checking if there is data in them.
    const lsize = try lockFD.stat();
    if (lsize.size == 0) try lockFD.writeAll("{}");

    try stdout.writeAll("Project Initlized. Now you just need to find a way to sync it.\n Git is recomended. ");
    //TODO[optional]: Maybe make a empty git repo.
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
