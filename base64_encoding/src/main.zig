const std = @import("std");
const Io = std.Io;

const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";

        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};

pub fn main(init: std.process.Init) !void {
    var writer_buffer: [1024]u8 = undefined;
    var stdout_writer = Io.File.stdout().writer(init.io, &writer_buffer);
    var stdout = &stdout_writer.interface;

    const base64 = Base64.init();

    try stdout.print("Character at index 28: {c}\n", .{base64._char_at(28)});
    try stdout.flush();
}
