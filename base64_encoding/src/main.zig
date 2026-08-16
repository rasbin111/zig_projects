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

    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const n_out = try _calc_encode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (input, 0..) |_, i| {
            buf[count] = input[i];
            count += 1;

            if (count == 3) {
                out[iout] = self._char_at(buf[0] >> 2);
                out[iout + 1] = self._char_at(((buf[0] & 0x03) << 4) + (buf[1] >> 4));
                out[iout + 2] = self._char_at(((buf[1] & 0x0f) << 2) + (buf[2] >> 6));
                out[iout + 3] = self._char_at(buf[2] & 0x3f);
            }

            iout += 4;
            count = 0;
        }
        if (count == 1) {
            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = self._char_at((buf[0] & 0x03) << 4);
            out[iout + 2] = '=';
            out[iout + 3] = '=';
        }
        if (count == 2) {
            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = self._char_at(((buf[0] & 0x03) << 4) + (buf[1] >> 4));
            out[iout + 2] = self._char_at((buf[1] & 0x0f) << 2);
            iout += 4;
        }
        return out;
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};

pub fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }

    const n_groups: usize = try std.math.divCeil(usize, input.len, 3);

    return n_groups * 4;
}

pub fn _calc_decode_length(input: []const u8) !usize {
    if (input.len == 4) {
        return 3;
    }
    const n_groups: usize = try std.math.divCeil(
        usize,
        input.len,
    );

    var multiple_groups: usize = n_groups * 3;
    var i: usize = input.len - 1;

    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            multiple_groups -= 1;
        } else {
            break;
        }
    }
    return multiple_groups;
}

pub fn main(init: std.process.Init) !void {
    var writer_buffer: [1024]u8 = undefined;
    var stdout_writer = Io.File.stdout().writer(init.io, &writer_buffer);
    var stdout = &stdout_writer.interface;

    const base64 = Base64.init();

    try stdout.print("Character at index 28: {c}\n", .{base64._char_at(28)});
    try stdout.flush();

    const str = "Hi";

    try stdout.print("Hex value after shift: {d} : {c}\n", .{ str[0] >> 2, str[0] >> 2 });
    try stdout.flush();

    const bits = 0b1011;
    try stdout.print("{d}\n", .{bits & 0b0011});
    try stdout.flush();
}
