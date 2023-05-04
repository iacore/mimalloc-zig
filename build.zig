const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("mimalloc", .{
        .source_file = .{ .path = "src/mimalloc.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "mimalloc",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath("mimalloc-archive/include");
    lib.addCSourceFiles(&.{
        "mimalloc-archive/src/stats.c",
        "mimalloc-archive/src/random.c",
        "mimalloc-archive/src/os.c",
        "mimalloc-archive/src/bitmap.c",
        "mimalloc-archive/src/arena.c",
        "mimalloc-archive/src/segment-cache.c",
        "mimalloc-archive/src/segment.c",
        "mimalloc-archive/src/page.c",
        "mimalloc-archive/src/alloc.c",
        "mimalloc-archive/src/alloc-aligned.c",
        "mimalloc-archive/src/alloc-posix.c",
        "mimalloc-archive/src/heap.c",
        "mimalloc-archive/src/options.c",
        "mimalloc-archive/src/init.c",
    }, &.{});

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    lib.install();

    // Creates a step for unit testing.
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.addModule("mimalloc", mod);
    tests.linkLibrary(lib);

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build test`
    // This will evaluate the `test` step rather than the default, which is "install".
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&tests.step);
}
