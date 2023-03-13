# mimalloc for zig

Copy of source code of mimalloc is bundled.

Usage:

```zig
@import("mimalloc-zig/build.zig").link(exe);
```

## API

- [x] link static (use musl target)
- [x] global (malloc/free)
- [ ] heap
- [ ] option
