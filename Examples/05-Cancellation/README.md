# 05 - Cancellation

This example demonstrates cooperative cancellation.

Run it directly:

```bash
swiftc *.swift -o /tmp/cancellation-example
/tmp/cancellation-example
```

Edit the `selectedScenarios` array in `main.swift` to choose which scenarios run.

The timeout task finishes first, the task group cancels the worker, and the program exits normally. The worker checks cancellation between steps with `Task.checkCancellation()`, which is the important pattern: cancellation is cooperative, not a force-stop.
