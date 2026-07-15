# 06 - Actors

This command-line example uses a `BankAccount` actor to protect shared mutable state.

Multiple tasks deposit and withdraw at the same time, but all reads and writes to `balance` and `transactions` go through the actor. The final balance stays consistent because actor-isolated state is accessed one operation at a time.

Run it with:

```sh
swiftc *.swift -o /tmp/actors-example
/tmp/actors-example
```

Edit the `selectedScenarios` array in `main.swift` to choose which scenarios run.
