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
    lib.addIncludePath("mimalloc/include");
    // note: on upgrading mimalloc, some files might change.
    // see mimalloc/CMakeLists.txt for the list of C files
    lib.addCSourceFiles(&.{
        "mimalloc/src/alloc.c",
        "mimalloc/src/alloc-aligned.c",
        "mimalloc/src/alloc-posix.c",
        "mimalloc/src/arena.c",
        "mimalloc/src/bitmap.c",
        "mimalloc/src/heap.c",
        "mimalloc/src/init.c",
        "mimalloc/src/options.c",
        "mimalloc/src/os.c",
        "mimalloc/src/page.c",
        "mimalloc/src/random.c",
        "mimalloc/src/segment.c",
        "mimalloc/src/segment-map.c",
        "mimalloc/src/stats.c",
        "mimalloc/src/prim/prim.c",
    }, &.{});

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

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
