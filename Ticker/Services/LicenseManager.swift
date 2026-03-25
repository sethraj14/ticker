import Foundation

// MARK: - Stored License (private persistence model)

private struct StoredLicense: Codable {
    let key: String
    let email: String
    let instanceId: String
    let activatedAt: Date
    let productName: String
}

// MARK: - Lemon Squeezy API response shapes

private struct LSActivateResponse: Decodable {
    let activated: Bool
    let error: String?
    let licenseKey: LSLicenseKey?
    let instance: LSInstance?
    let meta: LSMeta?

    enum CodingKeys: String, CodingKey {
        case activated, error
        case licenseKey = "license_key"
        case instance, meta
    }
}

private struct LSDeactivateResponse: Decodable {
    let deactivated: Bool
    let error: String?
}

private struct LSLicenseKey: Decodable {
    let key: String
    let status: String?
}

private struct LSInstance: Decodable {
    let id: String
    let name: String?
}

private struct LSMeta: Decodable {
    let customerEmail: String?
    let productName: String?

    enum CodingKeys: String, CodingKey {
        case customerEmail = "customer_email"
        case productName = "product_name"
    }
}

// MARK: - LicenseManager

@MainActor
final class LicenseManager: ObservableObject {
    static let shared = LicenseManager()

    // MARK: Published state

    @Published private(set) var isPro: Bool = false
    @Published private(set) var licenseEmail: String?
    @Published var isValidating: Bool = false
    @Published var validationError: String?

    // MARK: Private constants

    private let storageKey = "ticker_license"
    private let activateURL = URL(string: "https://api.lemonsqueezy.com/v1/licenses/activate")!
    private let deactivateURL = URL(string: "https://api.lemonsqueezy.com/v1/licenses/deactivate")!

    private var storedInstanceId: String?

    // MARK: Init

    private init() {
        if let license = loadStoredLicense() {
            isPro = true
            licenseEmail = license.email.isEmpty ? nil : license.email
            storedInstanceId = license.instanceId
        }
    }

    // MARK: Activate

    func activate(key: String) async {
        isValidating = true
        validationError = nil
        defer { isValidating = false }

        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            validationError = "Please enter a license key."
            return
        }

        let hostname = ProcessInfo.processInfo.hostName
        let encodedKey = trimmedKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmedKey
        let encodedHost = hostname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? hostname
        let body = "license_key=\(encodedKey)&instance_name=\(encodedHost)"

        var request = URLRequest(url: activateURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                if let parsed = try? JSONDecoder().decode(LSActivateResponse.self, from: data),
                   let msg = parsed.error {
                    validationError = msg
                } else {
                    validationError = http.statusCode == 404 ? "Invalid license key." : "Server error (\(http.statusCode)). Try again later."
                }
                return
            }

            let decoded = try JSONDecoder().decode(LSActivateResponse.self, from: data)

            guard decoded.activated else {
                validationError = decoded.error ?? "Activation failed. Please check your key and try again."
                return
            }

            guard let id = decoded.instance?.id else {
                validationError = "Activation failed — no instance ID returned. Contact support."
                return
            }
            let email = decoded.meta?.customerEmail ?? ""
            let product = decoded.meta?.productName ?? "Ticker Pro"

            let license = StoredLicense(
                key: trimmedKey,
                email: email,
                instanceId: id,
                activatedAt: Date(),
                productName: product
            )

            guard let encoded = try? JSONEncoder().encode(license),
                  KeychainHelper.save(key: storageKey, data: encoded) else {
                validationError = "Activation succeeded but could not save license locally."
                return
            }

            isPro = true
            licenseEmail = email.isEmpty ? nil : email
            storedInstanceId = id

        } catch {
            validationError = "Network error: \(error.localizedDescription)"
        }
    }

    // MARK: Deactivate

    func deactivate() async {
        guard let license = loadStoredLicense() else {
            clearLocalLicense()
            return
        }

        // Best-effort remote deactivation — clear locally regardless of outcome
        let encodedKey = license.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? license.key
        let encodedId = license.instanceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? license.instanceId
        let body = "license_key=\(encodedKey)&instance_id=\(encodedId)"

        var request = URLRequest(url: deactivateURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        _ = try? await URLSession.shared.data(for: request)

        clearLocalLicense()
    }

    // MARK: Private helpers

    @discardableResult
    private func loadStoredLicense() -> StoredLicense? {
        guard let data = KeychainHelper.load(key: storageKey),
              let license = try? JSONDecoder().decode(StoredLicense.self, from: data)
        else { return nil }
        return license
    }

    private func clearLocalLicense() {
        KeychainHelper.delete(key: storageKey)
        isPro = false
        licenseEmail = nil
        storedInstanceId = nil
    }
}
