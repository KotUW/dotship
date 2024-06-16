const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    const prog_name = args.next().?;
    const sub_cmd = args.next();

    if (sub_cmd == null) {
        std.debug.print("[ERROR] Invalid Subcommand\nUsage: {s} Subcommand\n", .{prog_name});
        return;
    }

    if (std.zig.c_builtins.__builtin_strcmp(sub_cmd.?, "sync") == 0) {
        std.debug.print("cmd = sync", .{});
    }
}
