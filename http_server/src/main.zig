const std = @import("std");
const Request = @import("request.zig");
const Method = Request.Method;
const Response = @import("response.zig");
const Server = @import("server.zig").Server;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const server = try Server.init(io);
    var listening = try server.listen();
    const connection = try listening.accept(io);
    defer connection.close(io);

    var request_buffer: [1000]u8 = undefined;
    @memset(request_buffer[0..], 0);

    try Request.read_request(io, connection, request_buffer[0..]);
    std.debug.print("{s}\n", .{request_buffer});

    const request = Request.parse_request(request_buffer[0..]);
    std.debug.print("URI: {s}\n", .{request.uri});
    std.debug.print("VERSION: {s}\n", .{request.version});

    if (request.method == Method.GET) {
        if (std.mem.eql(u8, request.uri, "/")) {
            try Response.send_200(connection, io);
        } else {
            try Response.send_400(connection, io);
        }
    }
}
