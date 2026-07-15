# 04 - Task Groups

This example uses `withTaskGroup` for dynamic parallel work.

Run it from this folder:

```bash
swiftc *.swift -o /tmp/04_TaskGroups && /tmp/04_TaskGroups
```

Edit `selectedScenarios` in `main.swift` when you want to focus on one scenario.

Task groups are useful when the number of child tasks comes from data. Results may arrive in completion order, so the example sorts them before printing the final list to keep the teaching output deterministic.

## Scenarios

| File | Original source | Course mapping |
| --- | --- | --- |
| `DynamicParallelWorkExample.swift` | New course example | Minimal task group where every data item becomes one child task. |
| `BoundedRequestLoadingExample.swift` | `OriginalSamples/LoadRequests.swift` | Preserves the bounded task group pattern: start up to `batchSize` requests, then enqueue one more each time a child finishes. Real network calls are replaced with simulated request latency and data so the example is deterministic. |
| `FBViewTraversalExample.swift` | `OriginalSamples/FBView.swift` | Adapts the original `FBView(label:subviews:)` hierarchy into a runnable dynamic tree traversal. Each node's children are rendered through a task group, then sorted by path so the printed hierarchy is stable. |
