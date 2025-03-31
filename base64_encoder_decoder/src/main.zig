const std = @import("std");
const base64 = @import("base64.zig");
const stdout = std.io.getStdOut().writer();
pub fn main() !void {
    const b64 = base64.Base64.init();
    try stdout.print("Characters at index 28: {c} \n", .{b64._char_at(28)});
}
