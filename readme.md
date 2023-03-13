# mimalloc for zig

source code of mimalloc is bundled as git submodule

Usage:

```zig
@import("mimalloc-zig/build.zig").link(exe);
```

## API

- [x] link static (use musl target)
- [x] global (malloc/free)
- [ ] heap
- [ ] option
