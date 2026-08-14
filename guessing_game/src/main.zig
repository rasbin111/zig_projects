const std = @import("std");
const Io = std.Io;

const guessing_game = @import("guessing_game");

fn generateRandomNumber(io: Io) u32 {
    const now = std.Io.Timestamp.now(io, .real);
    var prng = std.Random.DefaultPrng.init(@intCast(now.toNanoseconds()));
    const random = prng.random();
    const num: u32 = random.intRangeAtMost(u32, 1, 100);
    return num;
}

pub fn main(init: std.process.Init) !void {
    var inBuffer: [1024]u8 = undefined;
    var outBuffer: [1024]u8 = undefined;

    var stdin = Io.File.stdin();
    var stdout = Io.File.stdout();

    var writer_file = stdout.writer(init.io, &inBuffer);
    var reader_file = stdin.reader(init.io, &outBuffer);

    const writer = &writer_file.interface;
    const reader = &reader_file.interface;

    try writer.print("**Welcome to the guessing game**\n", .{});
    try writer.flush();

    const randomNumber: u32 = generateRandomNumber(init.io);
    while (true) {
        try writer.print("Please enter a number(guess) between 1 and 100: ", .{});
        try writer.flush();

        const num_str = try reader.takeDelimiterExclusive('\n');
        reader.toss(1);
        const num: u32 = try std.fmt.parseInt(u32, num_str, 10);

        if (num == randomNumber) {
            try writer.print("You made the correct gues\n", .{});
            try writer.flush();
            break;
        } else if (num > randomNumber) {
            try writer.print("You guess is greater than the actual number.\n", .{});
            try writer.flush();
        } else if (num < randomNumber) {
            try writer.print("Your guess is smaller than the actual number.\n", .{});
            try writer.flush();
        }
    }
}
