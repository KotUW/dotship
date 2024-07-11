const std = @import("std");
const builtin = @import("builtin");

/// Check if we are in a debug env.
fn debug_mode() bool {
    if (builtin.mode == std.builtin.OptimizeMode.Debug) {
        return true;
    } else {
        return false;
    }
}

const File = struct { name: []const u8, path: []const u8, lastMod: i128 };

pub fn main() !void {
    //TODO: Enscaplate this into/with Arena Allocator with heap allocator as suggested by official (book)[https://ziglang.org/documentation/master/#Choosing-an-Allocator].
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const configDirPath = getConfigDirPath(allocator);
    defer {
        if (!debug_mode()) {
            allocator.free(configDirPath);
        }
    }

    const configDir = std.fs.openDirAbsolute(configDirPath, .{ .iterate = true }) catch |err| cd: {
        if (err == error.FileNotFound) {
            //If Directory not found create it.
            const prompt = try std.fmt.allocPrint(allocator, "Can't find dir {s}. Want me to create it?(y/N) ", .{configDirPath});
            defer allocator.free(prompt);
            _ = switch (choice(prompt)) {
                'y' => {},
                'Y' => {},
                else => return error.FileNotFound,
            };

            try std.fs.makeDirAbsolute(configDirPath);
            break :cd try std.fs.openDirAbsolute(configDirPath, .{});
        } else {
            return err;
        }
    };
    // defer configDir.close(); //For some reason, we don't need to close it.

    const lockFile = try configDir.createFile("dotman.lock", .{ .truncate = false, .read = true });
    defer lockFile.close();

    //scan files in the directory.
    var dirListing = std.ArrayList(File).init(allocator);
    defer dirListing.deinit();

    var cdIter = configDir.iterate();
    while (try cdIter.next()) |entry| {
        // std.log.debug("Iterating throigh entry => {s} of kind => {any}", .{ entry.name, entry.kind });
        if (entry.kind == .file) {
            const entryInfo = try configDir.statFile(entry.name);
            try dirListing.append(File{ .name = entry.name, .lastMod = entryInfo.mtime, .path = "default" });
        }
    }

    // const debug_var = dirListing.getLast();
    // std.log.debug("One of the dirListing entry [ name => {s}, mod => {d}, path => {s} ]", .{ debug_var.name, debug_var.lastMod, debug_var.path });

    const lfcont = try lockFile.readToEndAlloc(allocator, 1024); //TODO: For now. We will assume we read it in one go.
    defer allocator.free(lfcont);

    std.log.info("$XDG_CONFIG_DIR = {s}", .{configDirPath});
}

fn getConfigDirPath(alloc: std.mem.Allocator) []const u8 {
    if (debug_mode()) {
        return "/home/evil/work/proj/dotman/config";
    }

    return std.process.getEnvVarOwned(alloc, "XDG_CONFIG_HOME") catch conPath: {
        const user = std.process.getEnvVarOwned(alloc, "USER") catch @panic("Can't get $USER env var");
        defer alloc.free(user);
        const cd = std.fmt.allocPrint(alloc, "/home/{s}/.config/dotman", .{user}) catch @panic("Can't allocate space for fmt.");
        break :conPath cd;
    };
}

fn choice(prompt: []const u8) u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut();
    // var buf: [3]u8 = undefined; //Just going to use single letters for choices atm

    stdout.writeAll(prompt) catch unreachable;

    const ans = stdin.readBytesNoEof(2) catch |err| {
        std.log.err("Got error while trying to read from stdin {?}", .{err});
        std.process.exit(3);
    };
    return ans[0];
}
