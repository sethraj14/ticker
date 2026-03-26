import Foundation
import SwiftUI

final class GoogleCalendarService: ObservableObject {
    static let shared = GoogleCalendarService()

    @Published var accounts: [GoogleAccount] = []
    @Published var isLoading = false

    private let clientId: String = {
        Bundle.main.object(forInfoDictionaryKey: "GoogleClientID") as? String ?? ""
    }()
    private let clientSecret: String = {
        Bundle.main.object(forInfoDictionaryKey: "GoogleClientSecret") as? String ?? ""
    }()
    private let scopes = "https://www.googleapis.com/auth/calendar.events email"
    private let tokenURL = "https://oauth2.googleapis.com/token"
    private let authURL = "https://accounts.google.com/o/oauth2/auth"
    private let calendarBaseURL = "https://www.googleapis.com/calendar/v3"
    private let userinfoURL = "https://www.googleapis.com/oauth2/v2/userinfo"

    private var httpServer: LoopbackHTTPServer?
    private var calendarCacheByAccount: [String: (calendars: [GoogleCalendarInfo], time: Date)] = [:]

    var isAuthenticated: Bool {
        !accounts.isEmpty
    }

    private init() {
        accounts = AccountStorage.loadAccounts()
    }

    // MARK: - Multi-Account OAuth

    func addAccount() {
        let port = findAvailablePort()
        let redirectURI = "http://127.0.0.1:\(port)"

        httpServer = LoopbackHTTPServer(port: port) { [weak self] code in
            self?.httpServer?.stop()
            self?.httpServer = nil
            Task { @MainActor in
                await self?.exchangeCodeForNewAccount(code: code, redirectURI: redirectURI)
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

    func removeAccount(_ account: GoogleAccount) {
        AccountStorage.remove(id: account.id)
        calendarCacheByAccount.removeValue(forKey: account.id)
        accounts = AccountStorage.loadAccounts()
    }

    func signOutAll() {
        for account in accounts {
            AccountStorage.remove(id: account.id)
        }
        calendarCacheByAccount.removeAll()
        accounts = []
    }

    // MARK: - Token Exchange

    private func exchangeCodeForNewAccount(code: String, redirectURI: String) async {
        let params = [
            "code": code,
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
        ]

        guard let tokenResponse = await postTokenRequest(params: params) else { return }

        // Fetch user email to identify this account
        let email = await fetchUserEmail(accessToken: tokenResponse.accessToken) ?? "account-\(accounts.count + 1)"

        let expiry = Date.now.addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        let account = GoogleAccount(
            id: email,
            email: email,
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken ?? "",
            tokenExpiry: expiry.timeIntervalSince1970
        )

        AccountStorage.addOrUpdate(account)
        accounts = AccountStorage.loadAccounts()
    }

    private func fetchUserEmail(accessToken: String) async -> String? {
        var request = URLRequest(url: URL(string: userinfoURL)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            let info = try JSONDecoder().decode(GoogleUserInfo.self, from: data)
            return info.email
        } catch {
            return nil
        }
    }

    // MARK: - Token Refresh (per account)

    private func getValidAccessToken(for account: GoogleAccount) async -> String? {
        if !account.isTokenExpired {
            return account.accessToken
        }

        // Refresh
        let params = [
            "refresh_token": account.refreshToken,
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "refresh_token",
        ]

        guard let tokenResponse = await postTokenRequest(params: params) else { return nil }

        let expiry = Date.now.addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        AccountStorage.updateTokens(id: account.id, accessToken: tokenResponse.accessToken, expiry: expiry.timeIntervalSince1970)

        // Update in-memory
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index].accessToken = tokenResponse.accessToken
            accounts[index].tokenExpiry = expiry.timeIntervalSince1970
        }

        return tokenResponse.accessToken
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
            return try JSONDecoder().decode(TokenResponse.self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Create Event

    /// Create a new event on the user's primary Google Calendar.
    /// Uses the first connected account unless accountId is specified.
    /// Result of creating an event — success or a user-friendly error message.
    enum CreateResult {
        case success
        case error(String)
    }

    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        description: String? = nil,
        accountId: String? = nil
    ) async -> CreateResult {
        let account = accountId.flatMap({ id in accounts.first { $0.id == id } }) ?? accounts.first
        guard let account else { return .error("No Google account connected.") }
        guard let token = await getValidAccessToken(for: account) else {
            return .error("Could not refresh token. Try removing and re-adding your account.")
        }

        let url = URL(string: "\(calendarBaseURL)/calendars/primary/events")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        var body: [String: Any] = [
            "summary": title,
            "start": ["dateTime": formatter.string(from: startDate), "timeZone": TimeZone.current.identifier],
            "end": ["dateTime": formatter.string(from: endDate), "timeZone": TimeZone.current.identifier]
        ]
        if let description { body["description"] = description }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return .error("Failed to build request.")
        }
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                if (200...299).contains(http.statusCode) {
                    return .success
                }
                if http.statusCode == 403 {
                    return .error("Permission denied. Remove and re-add your Google account to grant calendar write access.")
                }
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                return .error("Google API error (\(http.statusCode)): \(errorBody.prefix(100))")
            }
            return .error("No response from Google.")
        } catch {
            return .error("Network error: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Events (all accounts merged)

    func fetchEvents(for date: Date) async -> [CalendarEvent] {
        guard !accounts.isEmpty else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let timeMin = formatter.string(from: startOfDay)
        let timeMax = formatter.string(from: endOfDay)
        let tz = TimeZone.current.identifier

        // Fetch from ALL accounts concurrently
        return await withTaskGroup(of: [CalendarEvent].self) { group in
            for account in accounts {
                group.addTask {
                    await self.fetchEventsForAccount(account, timeMin: timeMin, timeMax: timeMax, timeZone: tz)
                }
            }

            var allEvents: [CalendarEvent] = []
            for await events in group {
                allEvents.append(contentsOf: events)
            }
            return allEvents.sorted { $0.startDate < $1.startDate }
        }
    }

    private func fetchEventsForAccount(_ account: GoogleAccount, timeMin: String, timeMax: String, timeZone: String) async -> [CalendarEvent] {
        guard let accessToken = await getValidAccessToken(for: account) else { return [] }

        let calendars = await getCachedCalendarList(accountId: account.id, accessToken: accessToken)
        if calendars.isEmpty { return [] }

        return await withTaskGroup(of: [CalendarEvent].self) { group in
            for cal in calendars {
                group.addTask {
                    await self.fetchEventsFromCalendar(
                        calendarId: cal.id,
                        calendarColor: cal.color,
                        accessToken: accessToken,
                        timeMin: timeMin,
                        timeMax: timeMax,
                        timeZone: timeZone
                    )
                }
            }

            var allEvents: [CalendarEvent] = []
            for await events in group {
                allEvents.append(contentsOf: events)
            }
            return allEvents
        }
    }

    // MARK: - Calendar List (cached per account)

    private func getCachedCalendarList(accountId: String, accessToken: String) async -> [GoogleCalendarInfo] {
        if let cached = calendarCacheByAccount[accountId],
           Date.now.timeIntervalSince(cached.time) < 1800 {
            return cached.calendars
        }
        let list = await fetchCalendarList(accessToken: accessToken)
        calendarCacheByAccount[accountId] = (calendars: list, time: .now)
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
            return listResponse.items
                .filter { !($0.hidden ?? false) && !($0.deleted ?? false) }
                .map { GoogleCalendarInfo(from: $0) }
        } catch {
            return []
        }
    }

    // MARK: - Fetch Events from Single Calendar

    private func fetchEventsFromCalendar(
        calendarId: String,
        calendarColor: Color,
        accessToken: String,
        timeMin: String,
        timeMax: String,
        timeZone: String
    ) async -> [CalendarEvent] {
        let safeChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-_~"))
        let encodedId = calendarId.addingPercentEncoding(withAllowedCharacters: safeChars) ?? calendarId

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.percentEncodedPath = "/calendar/v3/calendars/\(encodedId)/events"
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: timeMin),
            URLQueryItem(name: "timeMax", value: timeMax),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "timeZone", value: timeZone),
        ]

        guard let url = components.url else { return [] }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            let eventsResponse = try JSONDecoder().decode(GoogleEventsResponse.self, from: data)
            return (eventsResponse.items ?? []).compactMap { item in
                parseGoogleEvent(item, calendarColor: calendarColor)
            }
        } catch {
            return []
        }
    }

    // MARK: - Parse

    private func parseGoogleEvent(_ item: GoogleEventItem, calendarColor: Color = .blue) -> CalendarEvent? {
        guard let startDate = parseGoogleDateTime(item.start),
              let endDate = parseGoogleDateTime(item.end) else {
            return nil
        }

        let isAllDay = item.start.dateTime == nil && item.start.date != nil

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
            notes: item.description,
            isAllDay: isAllDay
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
        let sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        defer { close(sock) }

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = 0
        addr.sin_addr.s_addr = INADDR_LOOPBACK.bigEndian

        _ = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                bind(sock, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        var boundAddr = sockaddr_in()
        var addrLen = socklen_t(MemoryLayout<sockaddr_in>.size)
        _ = withUnsafeMutablePointer(to: &boundAddr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                getsockname(sock, sockaddrPtr, &addrLen)
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

// MARK: - Google User Info

private struct GoogleUserInfo: Decodable {
    let email: String
}

// MARK: - Google Calendar API Types

struct GoogleEventsResponse: Decodable {
    let items: [GoogleEventItem]?
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
