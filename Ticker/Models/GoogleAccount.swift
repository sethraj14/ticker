import Foundation

struct GoogleAccount: Codable, Identifiable, Equatable {
    let id: String          // email address
    var email: String
    var accessToken: String
    var refreshToken: String
    var tokenExpiry: TimeInterval  // seconds since 1970

    var isTokenExpired: Bool {
        Date(timeIntervalSince1970: tokenExpiry) < Date.now.addingTimeInterval(60)
    }

    static func == (lhs: GoogleAccount, rhs: GoogleAccount) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Account Storage

enum AccountStorage {
    private static let storageKey = "google_accounts"

    static func loadAccounts() -> [GoogleAccount] {
        guard let data = KeychainHelper.load(key: storageKey),
              let accounts = try? JSONDecoder().decode([GoogleAccount].self, from: data)
        else { return [] }
        return accounts
    }

    static func saveAccounts(_ accounts: [GoogleAccount]) {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        _ = KeychainHelper.save(key: storageKey, data: data)
    }

    static func addOrUpdate(_ account: GoogleAccount) {
        var accounts = loadAccounts()
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
        saveAccounts(accounts)
    }

    static func remove(id: String) {
        var accounts = loadAccounts()
        accounts.removeAll { $0.id == id }
        saveAccounts(accounts)
    }

    static func updateTokens(id: String, accessToken: String, expiry: TimeInterval) {
        var accounts = loadAccounts()
        if let index = accounts.firstIndex(where: { $0.id == id }) {
            accounts[index].accessToken = accessToken
            accounts[index].tokenExpiry = expiry
            saveAccounts(accounts)
        }
    }
}
