const std = @import("std");
const Io = std.Io;

const guessing_game = @import("guessing_game");

pub fn main(init: std.process.Init) !void {
    var inBuffer: [1024]u8 = undefined;
    var outBuffer: [1024]u8 = undefined;

    var stdin = Io.File.stdin();
    var stdout = Io.File.stdout();

    var writer_file = stdout.writer(init.io, &inBuffer);
    var reader_file = stdin.reader(init.io, &outBuffer);

    const writer = &writer_file.interface;
    const reader = &reader_file.interface;
    _ = reader;
    try writer.print("**Welcome to the guessing game**", .{});
    try writer.flush();
}
