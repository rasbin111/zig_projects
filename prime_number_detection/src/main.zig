const std = @import("std");
const Io = std.Io;

const io_utils = @import("io_utils.zig");

pub fn main(init: std.process.Init) !void {
    var stdin_reader: io_utils.StdinReader = .{};
    var stdout_writer: io_utils.StdoutWriter = .{};

    const reader = stdin_reader.init(init.io);
    _ = reader;
    const writer = stdout_writer.init(init.io);

    try writer.print("**Welcome to Prime Number Detection System** \n\n", .{});
    try writer.flush();
}
