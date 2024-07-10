const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const configDir = try getConfigDir(allocator);
    defer allocator.free(configDir);

    const lockFile = try openLockFile(configDir);
    defer lockFile.close();

    std.log.info("$XDG_CONFIG_DIR = {s}", .{configDir});
}

fn openLockFile(path: []u8) !std.fs.File {
    const configDir = std.fs.openDirAbsolute(path, .{}) catch |err| cd: {
        if (err == error.FileNotFound) {
            //If Directory not found create it.
            std.log.info("Can't find dir {s}. Want me to create it?(y/N) >", .{path});
            _ = switch (choice()) {
                'y' => {},
                'Y' => {},
                else => return error.FileNotFound,
            };

            try std.fs.makeDirAbsolute(path);
            break :cd try std.fs.openDirAbsolute(path, .{});
        } else {
            return err;
        }
    };
    // defer configDir.close(); //For some reason it's a const ptr.

    return try configDir.createFile("dotman.lock", .{ .truncate = false });
}

fn getConfigDir(alloc: std.mem.Allocator) ![]u8 {
    return std.process.getEnvVarOwned(alloc, "XDG_CONFIG_HOME") catch blk: {
        const user = try std.process.getEnvVarOwned(alloc, "USER");
        defer alloc.free(user);
        const cd = try std.fmt.allocPrint(alloc, "/home/{s}/.config/dotman", .{user});
        break :blk cd;
    };
}

fn choice() u8 {
    const stdin = std.io.getStdIn().reader();
    // var buf: [3]u8 = undefined; //Just going to use single letters for choices atm

    const ans = stdin.readBytesNoEof(1) catch unreachable;
    return ans[0];
}
