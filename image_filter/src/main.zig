const std = @import("std");
const Io = std.Io;

const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("spng.h");
});

const image_filter = @import("image_filter");

pub fn main(init: std.process.Init) !void {
    _ = init;
    const path = "pedro_pascal.png";
    const file_descriptor = c.fopen(path, "rb");

    if (file_descriptor == null) {
        @panic("Could not open file!");
    }

    const ctx = c.spng_ctx_new(0) orelse unreachable;

    _ = c.spng_set_png_file(ctx, @ptrCast(file_descriptor));
}
