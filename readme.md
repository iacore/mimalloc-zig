# mimalloc for zig

Right now, you need to have `mimalloc` installed on your system to use this library.

Usage:

```zig
@import("mimalloc-zig/build.zig").link(exe);
```

## API

- [ ] link static, without libc
- [x] global (malloc/free)
- [ ] heap
- [ ] option
