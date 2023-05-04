const std = @import("std");
const mem = std.mem;
const math = std.math;
const debug = std.debug;

const Allocator = mem.Allocator;

const c = @cImport(@cInclude("mimalloc.h"));

pub const global_allocator = Allocator{
    .ptr = undefined,
    .vtable = &Allocator.VTable{
        .alloc = alloc,
        .resize = resize,
        .free = free,
    },
};

fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
    _ = ctx;
    _ = ret_addr;

    return @ptrCast(?[*]u8, c.mi_malloc_aligned(len, @as(u32, 1) << @intCast(u5, ptr_align)));
}

fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
    _ = ctx;
    _ = ret_addr;
    _ = buf_align;
    return new_len <= c.mi_usable_size(buf.ptr);
}

fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
    _ = ctx;
    _ = ret_addr;
    c.mi_free_size_aligned(buf.ptr, buf.len, @as(u32, 1) << @intCast(u5, buf_align));
}

/// mimalloc Heap
///
/// Should only allocate/resize from the thread this heap is created
/// Can free from other threads
pub const Heap = struct {
    p: *c.mi_heap_t,

    /// create heap
    pub fn init() !@This() {
        if (c.mi_heap_new()) |heap| {
            return .{ .p = heap };
        } else {
            return error.OutOfMemory;
        }
    }

    /// delete heap, return allocated memory to the backing heap, or abandon if no backing heap
    /// allocated memory still need to be freed later by the user
    pub fn deinit(this: @This()) void {
        c.mi_heap_delete(this.p);
    }

    /// delete heap, and free all allocated memory
    pub fn destroy(this: @This()) void {
        c.mi_heap_destroy(this.p);
    }

    pub fn collect(this: @This(), force: bool) void {
        c.mi_heap_collect(this.p, force);
    }

    pub fn allocator(this: @This()) Allocator {
        return Allocator{
            .ptr = this.p,
            .vtable = &Allocator.VTable{
                .alloc = heap_alloc,
                .resize = resize,
                .free = free,
            },
        };
    }
};

fn heap_alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
    const heap = @ptrCast(*c.mi_heap_t, ctx);
    _ = ret_addr;

    return @ptrCast(?[*]u8, c.mi_heap_malloc_aligned(heap, len, @as(u32, 1) << @intCast(u5, ptr_align)));
}
