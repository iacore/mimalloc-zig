const std = @import("std");
const mimalloc = @import("mimalloc");

test "global allocator" {
    const a = mimalloc.global_allocator;

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

test "heap" {
    const heap = try mimalloc.Heap.init();
    defer heap.deinit();

    const a = heap.allocator();
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
    heap.collect(true);
}
