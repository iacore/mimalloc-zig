const std = @import("std");

test {
    const a = @import("mimalloc").global_allocator;
    
    var map = std.StringHashMap(i32).init(a);
    defer map.deinit();
    defer {
        var it = map.keyIterator();
        while (it.next()) |key| {
            a.free(key.*);
        }
    }
    var i: i32 = 0;
    while (i < 10000000) : (i += 1) {
        const s = try std.fmt.allocPrint(a, "{}", .{i});
        try map.put(s, i);
    }
}
