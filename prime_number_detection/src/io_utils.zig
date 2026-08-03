const std = @import("std");

const Io = std.Io;

pub const StdinReader = struct {
    buffer: [1024]u8 = undefined,
    file_reader: Io.File.Reader = undefined,

    pub fn init(self: *StdinReader, io: Io) *Io.Reader {
        var stdin = Io.File.stdin();
        self.file_reader = stdin.reader(io, &self.buffer);
        return &self.file_reader.interface;
    }
};

pub const StdoutWriter = struct {
    buffer: [1024]u8 = undefined,
    file_writer: Io.File.Writer = undefined,

    pub fn init(self: *StdoutWriter, io: Io) *Io.Writer {
        var stdout = Io.File.stdout();
        self.file_writer = stdout.writer(io, &self.buffer);
        return &self.file_writer.interface;
    }
};
