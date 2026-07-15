import Foundation

actor BankAccount {
    private var balance: Int
    private var transactions: [String] = []

    init(openingBalance: Int) {
        self.balance = openingBalance
        transactions.append("Opened account with $\(openingBalance)")
    }

    func deposit(_ amount: Int, from source: String) {
        balance += amount
        transactions.append("\(source) deposited $\(amount); balance is $\(balance)")
    }

    func withdraw(_ amount: Int, for reason: String) -> Bool {
        guard balance >= amount else {
            transactions.append("Declined $\(amount) for \(reason); balance is $\(balance)")
            return false
        }

        balance -= amount
        transactions.append("Withdrew $\(amount) for \(reason); balance is $\(balance)")
        return true
    }

    func snapshot() -> (balance: Int, transactions: [String]) {
        (balance, transactions)
    }
}

func runBankAccountActorExample() async {
    let account = BankAccount(openingBalance: 100)

    await withTaskGroup(of: Void.self) { group in
        group.addTask {
            await account.deposit(35, from: "paycheck")
        }

        group.addTask {
            let approved = await account.withdraw(80, for: "groceries")
            print("Groceries withdrawal approved:", approved)
        }

        group.addTask {
            let approved = await account.withdraw(70, for: "books")
            print("Books withdrawal approved:", approved)
        }
    }

    let snapshot = await account.snapshot()

    print("\nFinal balance: $\(snapshot.balance)")
    print("Transaction log:")
    for entry in snapshot.transactions {
        print("-", entry)
    }
}
