const std = @import("std");
const base64 = @import("base64.zig");

pub fn encode(self: base64.Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
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
    }
}

pub fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        const n_output: usize = 4;
        return n_output;
    }
    const n_output: usize = try std.math.divCeil(usize, input.len, 3);
    return n_output * 4;
}
