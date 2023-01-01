const std = @import("std");
const mem = std.mem;
const math = std.math;
const debug = std.debug;

const Allocator = mem.Allocator;

const mi = @cImport(@cInclude("mimalloc.h"));

pub const global_allocator = Allocator{
    .ptr = undefined,
    .vtable = &vtable,
};

const vtable = Allocator.VTable{
    .alloc = alloc,
    .resize = resize,
    .free = free,
};

fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
    _ = ctx;
    _ = ret_addr;

    return @ptrCast(?[*]u8, mi.mi_malloc_aligned(len, @as(u32, 1) << @intCast(u5, ptr_align)));
}

fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
    _ = ctx;
    _ = ret_addr;
    _ = buf_align;
    return new_len <= mi.mi_usable_size(buf.ptr);
}

fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
    _ = ctx;
    _ = ret_addr;
    mi.mi_free_size_aligned(buf.ptr, buf.len, @as(u32, 1) << @intCast(u5, buf_align));
}
