const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var stdin_buffer: [1024]u8 = undefined;
    var stdin = Io.File.stdin();
    var stdin_file_reader = stdin.reader(init.io, &stdin_buffer);
    var reader = &stdin_file_reader.interface;

    try stdout_writer.print("**Welcome to Voter Detection System** \n\n", .{});
    try stdout_writer.flush();

    var age_str: []u8 = undefined;
    var age: u8 = undefined;
    while (true) {
        try stdout_writer.print("Please enter your age: ", .{});
        try stdout_writer.flush();

        age_str = try reader.takeDelimiterExclusive('\n');
        reader.toss(1); // store \n
        age = try std.fmt.parseInt(u8, age_str, 10);

        if (age < 18) {
            try stdout_writer.print("Sorry you have to wait {d} more years to vote \n", .{18 - age});
            try stdout_writer.flush();
        } else {
            try stdout_writer.print("Yay! you can vote. \n", .{});
            try stdout_writer.flush();
        }

        try stdout_writer.print("Do you want to continue? (y/n)", .{});
        try stdout_writer.flush();

        const pdChar = try reader.takeDelimiterExclusive('\n');
        reader.toss(1); // store extra \n from previous read

        try stdout_writer.print("\n", .{});
        try stdout_writer.flush();

        if (std.mem.eql(u8, pdChar, "N") or std.mem.eql(u8, pdChar, "n")) {
            break;
        }
    }

    try stdout_writer.flush();
}
