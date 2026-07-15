# 02 - Task Basics

This example introduces basic Swift concurrency syntax:

- `async` functions that suspend with `Task.sleep`.
- `await` for sequential async work.
- `Task { ... }` for creating an async operation and reading its `value`.

Run it from this folder:

```bash
swiftc *.swift -o /tmp/02_TaskBasics && /tmp/02_TaskBasics
```

Edit `selectedScenarios` in `main.swift` when you want to focus on one scenario at a time.

The sleeps are short and fixed, so the program exits on its own with predictable teaching output.
