# mimalloc for zig

Copy of source code of mimalloc is bundled.

## Usage

`build.zig`
```zig
const mod_mi = b.dependency("mimalloc", .{});

exe.addModule("mimalloc", mod_mi.module("mimalloc"));
exe.linkLibrary(mod_mi.artifact("mimalloc"));
```

> Warning:
> Github archive download is not working with git submodules
> The following method is not working as of now
> Please clone this repo locally and use `exe.addDependency*`.

`build.zig.zon`
```
.{
    .name = "mimalloc-zig-test",
    .version = "0.0.1",
    .dependencies = .{
        .mimalloc = .{
            .url = "https://github.com/locriacyber/mimalloc-zig/archive/refs/heads/main.tar.gz",
        }
    }
}
```

## API

The bound API is primitive. For more control over the mimalloc heaps, please contribute.

- [x] link static (use musl target)
- [x] global (malloc/free)
- [x] heap
- [ ] option
