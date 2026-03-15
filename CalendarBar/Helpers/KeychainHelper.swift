import Foundation

/// Simple file-based secure storage in Application Support directory.
/// Avoids all macOS Keychain password popup issues with unsigned debug builds.
enum KeychainHelper {
    private static let storageDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("CalendarBar", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private static func fileURL(for key: String) -> URL {
        storageDir.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
    }

    static func save(key: String, data: Data) -> Bool {
        let url = fileURL(for: key)
        do {
            try data.write(to: url, options: .atomic)
            // Set file permissions to owner-only (600)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: url.path
            )
            return true
        } catch {
            return false
        }
    }

    static func load(key: String) -> Data? {
        let url = fileURL(for: key)
        return try? Data(contentsOf: url)
    }

    @discardableResult
    static func delete(key: String) -> Bool {
        let url = fileURL(for: key)
        try? FileManager.default.removeItem(at: url)
        return true
    }

    static func saveString(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return save(key: key, data: data)
    }

    static func loadString(key: String) -> String? {
        guard let data = load(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
