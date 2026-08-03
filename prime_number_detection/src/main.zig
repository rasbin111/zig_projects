const std = @import("std");
const Io = std.Io;

const io_utils = @import("io_utils.zig");

pub fn check_prime(num: u32) bool {
    // return true if prime, else return false
    if (num == 1) {
        return true;
    }
    var isPrime = true;
    for (2..num) |i| {
        if (num % i == 0) {
            isPrime = false;
            break;
        }
    }
    return isPrime;
}

pub fn main(init: std.process.Init) !void {
    var stdin_reader: io_utils.StdinReader = .{};
    var stdout_writer: io_utils.StdoutWriter = .{};

    const reader = stdin_reader.init(init.io);
    const writer = stdout_writer.init(init.io);

    try writer.print("**Welcome to Prime Number Detection System** \n\n", .{});
    try writer.flush();

    var num_str: []u8 = undefined;
    var num: u32 = undefined;

    while (true) {
        try writer.print("Please enter a number: ", .{});
        try writer.flush();

        num_str = try reader.takeDelimiterExclusive('\n');
        reader.toss(1);

        try writer.print("\n", .{});
        try writer.flush();

        num = try std.fmt.parseInt(u32, num_str, 10);

        const isPrime = check_prime(num);

        if (isPrime) {
            try writer.print("Is a prime number\n\n", .{});
            try writer.flush();
        } else {
            try writer.print("Not a prime number\n\n", .{});
            try writer.flush();
        }

        var pdChar: []u8 = undefined;

        while (true) {
            try writer.print("Do you want to continue(y/n): ", .{});
            try writer.flush();

            pdChar = try reader.takeDelimiterExclusive('\n');
            reader.toss(1);

            if (std.mem.eql(u8, pdChar, "y") or std.mem.eql(u8, pdChar, "Y") or std.mem.eql(u8, pdChar, "n") or std.mem.eql(u8, pdChar, "N")) {
                break;
            }
        }

        if (std.mem.eql(u8, pdChar, "y") or std.mem.eql(u8, pdChar, "Y")) {
            continue;
        } else {
            break;
        }
    }
}
