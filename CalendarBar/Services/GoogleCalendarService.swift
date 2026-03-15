import Foundation
import SwiftUI

final class GoogleCalendarService: ObservableObject {
    static let shared = GoogleCalendarService()

    @Published var isAuthenticated = false
    @Published var isLoading = false

    private let clientId = "YOUR_CLIENT_ID.apps.googleusercontent.com"
    private let clientSecret = "YOUR_CLIENT_SECRET_HERE"
    private let scopes = "https://www.googleapis.com/auth/calendar.readonly"
    private let tokenURL = "https://oauth2.googleapis.com/token"
    private let authURL = "https://accounts.google.com/o/oauth2/auth"
    private let calendarBaseURL = "https://www.googleapis.com/calendar/v3"

    private let accessTokenKey = "google_access_token"
    private let refreshTokenKey = "google_refresh_token"
    private let tokenExpiryKey = "google_token_expiry"

    private var httpServer: LoopbackHTTPServer?

    private init() {
        isAuthenticated = KeychainHelper.loadString(key: refreshTokenKey) != nil
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

        KeychainHelper.saveString(key: accessTokenKey, value: tokenResponse.accessToken)
        let expiry = Date.now.addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        KeychainHelper.saveString(key: tokenExpiryKey, value: "\(expiry.timeIntervalSince1970)")

        return true
    }

    private func postTokenRequest(params: [String: String]) async -> TokenResponse? {
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
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
        KeychainHelper.saveString(key: accessTokenKey, value: response.accessToken)
        if let refresh = response.refreshToken {
            KeychainHelper.saveString(key: refreshTokenKey, value: refresh)
        }
        let expiry = Date.now.addingTimeInterval(TimeInterval(response.expiresIn))
        KeychainHelper.saveString(key: tokenExpiryKey, value: "\(expiry.timeIntervalSince1970)")
        isAuthenticated = true
    }

    // MARK: - Calendar API

    func fetchEvents(for date: Date) async -> [CalendarEvent] {
        guard let accessToken = await getValidAccessToken() else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        var components = URLComponents(string: "\(calendarBaseURL)/calendars/primary/events")!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: formatter.string(from: startOfDay)),
            URLQueryItem(name: "timeMax", value: formatter.string(from: endOfDay)),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
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
                parseGoogleEvent(item)
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

    private func parseGoogleEvent(_ item: GoogleEventItem) -> CalendarEvent? {
        guard let startDate = parseGoogleDateTime(item.start),
              let endDate = parseGoogleDateTime(item.end) else {
            return nil
        }

        let meetingURL = extractMeetingURL(from: item)
        let attendees = item.attendees?.compactMap { $0.displayName ?? $0.email } ?? []

        return CalendarEvent(
            id: item.id,
            title: item.summary ?? "(No title)",
            startDate: startDate,
            endDate: endDate,
            meetingURL: meetingURL,
            source: .google,
            calendarColor: .blue,
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
