import Foundation
import SwiftUI

final class GoogleCalendarService: ObservableObject {
    static let shared = GoogleCalendarService()

    @Published var isAuthenticated = false
    @Published var isLoading = false

    private let clientId: String = {
        Bundle.main.object(forInfoDictionaryKey: "GoogleClientID") as? String ?? ""
    }()
    private let clientSecret: String = {
        Bundle.main.object(forInfoDictionaryKey: "GoogleClientSecret") as? String ?? ""
    }()
    private let scopes = "https://www.googleapis.com/auth/calendar.readonly"
    private let tokenURL = "https://oauth2.googleapis.com/token"
    private let authURL = "https://accounts.google.com/o/oauth2/auth"
    private let calendarBaseURL = "https://www.googleapis.com/calendar/v3"

    private let accessTokenKey = "google_access_token"
    private let refreshTokenKey = "google_refresh_token"
    private let tokenExpiryKey = "google_token_expiry"

    private var httpServer: LoopbackHTTPServer?
    private var cachedCalendars: [GoogleCalendarInfo]?
    private var calendarCacheTime: Date?

    private init() {
        migrateKeychainIfNeeded()
        isAuthenticated = KeychainHelper.loadString(key: refreshTokenKey) != nil
    }

    // Re-save tokens with kSecAttrAccessibleWhenUnlocked to stop password popups
    private func migrateKeychainIfNeeded() {
        let migrated = UserDefaults.standard.bool(forKey: "keychain_migrated_v1")
        guard !migrated else { return }

        for key in [accessTokenKey, refreshTokenKey, tokenExpiryKey] {
            if let value = KeychainHelper.loadString(key: key) {
                _ = KeychainHelper.saveString(key: key, value: value)
            }
        }
        UserDefaults.standard.set(true, forKey: "keychain_migrated_v1")
    }

    // MARK: - OAuth Flow

    func authenticate() {
        let port = findAvailablePort()
        let redirectURI = "http://127.0.0.1:\(port)"

        httpServer = LoopbackHTTPServer(port: port) { [weak self] code in
            self?.httpServer?.stop()
            self?.httpServer = nil
            Task { @MainActor in
                await self?.exchangeCodeForTokens(code: code, redirectURI: redirectURI)
            }
        }

        httpServer?.start()

        var components = URLComponents(string: authURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent"),
        ]

        if let url = components.url {
            NSWorkspace.shared.open(url)
        }
    }

    func signOut() {
        KeychainHelper.delete(key: accessTokenKey)
        KeychainHelper.delete(key: refreshTokenKey)
        KeychainHelper.delete(key: tokenExpiryKey)
        cachedCalendars = nil
        calendarCacheTime = nil
        isAuthenticated = false
    }

    private func exchangeCodeForTokens(code: String, redirectURI: String) async {
        let params = [
            "code": code,
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
        ]

        guard let tokenResponse = await postTokenRequest(params: params) else { return }
        saveTokens(from: tokenResponse)
    }

    private func refreshAccessToken() async -> Bool {
        guard let refreshToken = KeychainHelper.loadString(key: refreshTokenKey) else {
            return false
        }

        let params = [
            "refresh_token": refreshToken,
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "refresh_token",
        ]

        guard let tokenResponse = await postTokenRequest(params: params) else {
            return false
        }

        _ = KeychainHelper.saveString(key: accessTokenKey, value: tokenResponse.accessToken)
        let expiry = Date.now.addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        _ = KeychainHelper.saveString(key: tokenExpiryKey, value: "\(expiry.timeIntervalSince1970)")

        return true
    }

    private func postTokenRequest(params: [String: String]) async -> TokenResponse? {
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let allowedChars = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: allowedChars) ?? $0.value)" }
            .joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(TokenResponse.self, from: data)
            return response
        } catch {
            return nil
        }
    }

    private func saveTokens(from response: TokenResponse) {
        _ = KeychainHelper.saveString(key: accessTokenKey, value: response.accessToken)
        if let refresh = response.refreshToken {
            _ = KeychainHelper.saveString(key: refreshTokenKey, value: refresh)
        }
        let expiry = Date.now.addingTimeInterval(TimeInterval(response.expiresIn))
        _ = KeychainHelper.saveString(key: tokenExpiryKey, value: "\(expiry.timeIntervalSince1970)")
        isAuthenticated = true
    }

    // MARK: - Calendar API

    func fetchEvents(for date: Date) async -> [CalendarEvent] {
        guard let accessToken = await getValidAccessToken() else { return [] }

        // Use cached calendar list (refreshes every 30 minutes)
        let calendars = await getCachedCalendarList(accessToken: accessToken)
        if calendars.isEmpty { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let timeMin = formatter.string(from: startOfDay)
        let timeMax = formatter.string(from: endOfDay)
        let tz = TimeZone.current.identifier

        // Fetch events from ALL calendars concurrently
        return await withTaskGroup(of: [CalendarEvent].self) { group in
            for cal in calendars {
                group.addTask {
                    await self.fetchEventsFromCalendar(
                        calendarId: cal.id,
                        calendarColor: cal.color,
                        accessToken: accessToken,
                        timeMin: timeMin,
                        timeMax: timeMax,
                        timeZone: tz
                    )
                }
            }

            var allEvents: [CalendarEvent] = []
            for await events in group {
                allEvents.append(contentsOf: events)
            }
            return allEvents.sorted { $0.startDate < $1.startDate }
        }
    }

    private func getCachedCalendarList(accessToken: String) async -> [GoogleCalendarInfo] {
        // Return cached if less than 30 minutes old
        if let cached = cachedCalendars, let cacheTime = calendarCacheTime,
           Date.now.timeIntervalSince(cacheTime) < 1800 {
            return cached
        }
        let list = await fetchCalendarList(accessToken: accessToken)
        cachedCalendars = list
        calendarCacheTime = .now
        return list
    }

    private func fetchCalendarList(accessToken: String) async -> [GoogleCalendarInfo] {
        var request = URLRequest(url: URL(string: "\(calendarBaseURL)/users/me/calendarList")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            let listResponse = try JSONDecoder().decode(GoogleCalendarListResponse.self, from: data)
            // Include all non-hidden calendars: primary, holidays, subscribed, etc.
            return listResponse.items
                .filter { !($0.hidden ?? false) && !($0.deleted ?? false) }
                .map { GoogleCalendarInfo(from: $0) }
        } catch {
            return []
        }
    }

    private func fetchEventsFromCalendar(
        calendarId: String,
        calendarColor: Color,
        accessToken: String,
        timeMin: String,
        timeMax: String,
        timeZone: String
    ) async -> [CalendarEvent] {
        // Calendar IDs like "en.indian#holiday@group.v.calendar.google.com" need full encoding
        let safeChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-_~"))
        let encodedId = calendarId.addingPercentEncoding(withAllowedCharacters: safeChars) ?? calendarId
        var components = URLComponents(string: "\(calendarBaseURL)/calendars/\(encodedId)/events")!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: timeMin),
            URLQueryItem(name: "timeMax", value: timeMax),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "timeZone", value: timeZone),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            let eventsResponse = try JSONDecoder().decode(GoogleEventsResponse.self, from: data)
            return eventsResponse.items.compactMap { item in
                parseGoogleEvent(item, calendarColor: calendarColor)
            }
        } catch {
            return []
        }
    }

    private func getValidAccessToken() async -> String? {
        guard let accessToken = KeychainHelper.loadString(key: accessTokenKey) else {
            return nil
        }

        if let expiryString = KeychainHelper.loadString(key: tokenExpiryKey),
           let expiryTimestamp = Double(expiryString) {
            let expiry = Date(timeIntervalSince1970: expiryTimestamp)
            if expiry > Date.now.addingTimeInterval(60) {
                return accessToken
            }
        }

        let refreshed = await refreshAccessToken()
        return refreshed ? KeychainHelper.loadString(key: accessTokenKey) : nil
    }

    private func parseGoogleEvent(_ item: GoogleEventItem, calendarColor: Color = .blue) -> CalendarEvent? {
        guard let startDate = parseGoogleDateTime(item.start),
              let endDate = parseGoogleDateTime(item.end) else {
            return nil
        }

        // All-day events use "date" instead of "dateTime"
        let isAllDay = item.start.dateTime == nil && item.start.date != nil
        // Skip all-day events from timeline
        guard !isAllDay else { return nil }

        let meetingURL = extractMeetingURL(from: item)
        let attendees = item.attendees?.compactMap { $0.displayName ?? $0.email } ?? []

        return CalendarEvent(
            id: item.id,
            title: item.summary ?? "(No title)",
            startDate: startDate,
            endDate: endDate,
            meetingURL: meetingURL,
            source: .google,
            calendarColor: calendarColor,
            attendees: attendees,
            location: item.location,
            notes: item.description
        )
    }

    private func parseGoogleDateTime(_ dateTime: GoogleDateTime) -> Date? {
        if let dateTimeString = dateTime.dateTime {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: dateTimeString)
        }
        if let dateString = dateTime.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: dateString)
        }
        return nil
    }

    private func extractMeetingURL(from item: GoogleEventItem) -> URL? {
        if let hangoutLink = item.hangoutLink {
            return URL(string: hangoutLink)
        }
        if let location = item.location, location.contains("zoom.us") || location.contains("meet.google") {
            return URL(string: location)
        }
        if let desc = item.description {
            let patterns = ["https://meet.google.com/[a-z-]+", "https://[a-z]+\\.zoom\\.us/j/[0-9]+"]
            for pattern in patterns {
                if let range = desc.range(of: pattern, options: .regularExpression) {
                    return URL(string: String(desc[range]))
                }
            }
        }
        return nil
    }

    private func findAvailablePort() -> UInt16 {
        let socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        defer { close(socket) }

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = 0
        addr.sin_addr.s_addr = INADDR_LOOPBACK.bigEndian

        withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                bind(socket, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        var boundAddr = sockaddr_in()
        var addrLen = socklen_t(MemoryLayout<sockaddr_in>.size)
        withUnsafeMutablePointer(to: &boundAddr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                getsockname(socket, sockaddrPtr, &addrLen)
            }
        }

        return UInt16(bigEndian: boundAddr.sin_port)
    }
}

// MARK: - Token Response

private struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

// MARK: - Google Calendar API Types

struct GoogleEventsResponse: Decodable {
    let items: [GoogleEventItem]
}

struct GoogleEventItem: Decodable {
    let id: String
    let summary: String?
    let description: String?
    let location: String?
    let start: GoogleDateTime
    let end: GoogleDateTime
    let hangoutLink: String?
    let attendees: [GoogleAttendee]?
}

struct GoogleDateTime: Decodable {
    let dateTime: String?
    let date: String?
    let timeZone: String?
}

struct GoogleAttendee: Decodable {
    let email: String
    let displayName: String?
    let responseStatus: String?
}

// MARK: - Calendar List Types

struct GoogleCalendarListResponse: Decodable {
    let items: [GoogleCalendarListEntry]
}

struct GoogleCalendarListEntry: Decodable {
    let id: String
    let summary: String?
    let backgroundColor: String?
    let foregroundColor: String?
    let hidden: Bool?
    let deleted: Bool?
    let accessRole: String?
}

struct GoogleCalendarInfo {
    let id: String
    let name: String
    let color: Color

    init(from entry: GoogleCalendarListEntry) {
        self.id = entry.id
        self.name = entry.summary ?? entry.id
        self.color = Self.parseHexColor(entry.backgroundColor) ?? .blue
    }

    private static func parseHexColor(_ hex: String?) -> Color? {
        guard let hex, hex.hasPrefix("#"), hex.count == 7 else { return nil }
        let r = Double(Int(hex.dropFirst(1).prefix(2), radix: 16) ?? 0) / 255.0
        let g = Double(Int(hex.dropFirst(3).prefix(2), radix: 16) ?? 0) / 255.0
        let b = Double(Int(hex.dropFirst(5).prefix(2), radix: 16) ?? 0) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
