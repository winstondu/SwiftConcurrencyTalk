# 07 - Actor Reentrancy

This example shows that an actor method can be reentered while it is suspended at an `await`.

`reserveWithSuspension(customer:)` checks the ticket count, suspends, and then checks again before mutating. Another task can enter the same actor while the first task is sleeping. The second check is the important part: assumptions made before an `await` may be stale after the method resumes.

`reserveWithoutSuspension(customer:)` keeps the check and mutation together with no suspension point between them.

Run it with:

```sh
swiftc *.swift -o /tmp/actor-reentrancy-example
/tmp/actor-reentrancy-example
```

Edit the `selectedScenarios` array in `main.swift` to choose which scenarios run.
