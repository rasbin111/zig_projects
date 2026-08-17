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

    pub fn _char_index(self: Base64, char: u8) u8 {
        if (char == '=') {
            return 64;
        }

        var i: u8 = 0;
        var output_index: u8 = 0;

        while (i < 64) : (i += 1) {
            if (self._char_at(i) == char)
                break;
            output_index += 1;
        }
        return output_index;
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

                iout += 4;
                count = 0;
            }
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
            out[iout + 3] = '=';
        }
        return out;
    }

    pub fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const input_len = try _calc_decode_length(input);
        var out = try allocator.alloc(u8, input_len);
        @memset(out[0..], 0);

        var buf = [4]u8{ 0, 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (0..input.len) |i| {
            buf[count] = self._char_index(input[i]);
            count += 1;

            if (count == 4) {
                out[iout] = (buf[0] << 2) + (buf[1] >> 4);
                if (buf[2] != 64) {
                    out[iout + 1] = (buf[1] << 4) + (buf[2] >> 2);
                }
                if (buf[3] != 64) {
                    out[iout + 2] = (buf[2] << 6) + buf[3];
                }
                iout += 3;
                count = 0;
            }
        }
        return out;
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
    const n_groups: usize = try std.math.divCeil(usize, input.len, 4);

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

    try stdout.print("Character at index 18: {c}\n", .{base64._char_at(18)});
    try stdout.flush();

    const str = "Hi";

    try stdout.print("Decimal value of char: {d} \n", .{str[0]});
    try stdout.flush();

    try stdout.print("Hex value after shift: {d} : {c}\n", .{ str[0] >> 2, str[0] >> 2 });
    try stdout.flush();

    const bits = 0b1011;
    try stdout.print("{d}\n", .{bits & 0b0011});
    try stdout.flush();

    const inputStr = "Hello";

    var debugAllocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator = debugAllocator.allocator();

    const encodedString = try base64.encode(allocator, inputStr);
    defer allocator.free(encodedString);

    try stdout.print("Encoded: {s}\n", .{encodedString});
    try stdout.flush();

    const decodedString = try base64.decode(allocator, encodedString);
    defer allocator.free(decodedString);

    try stdout.print("Decoded: {s} \n", .{decodedString});
    try stdout.flush();
}
