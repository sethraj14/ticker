import Foundation
import Network

final class LoopbackHTTPServer {
    private let port: UInt16
    private let onCodeReceived: (String) -> Void
    private var listener: NWListener?

    init(port: UInt16, onCodeReceived: @escaping (String) -> Void) {
        self.port = port
        self.onCodeReceived = onCodeReceived
    }

    func start() {
        let params = NWParameters.tcp
        guard let nwPort = NWEndpoint.Port(rawValue: port) else { return }

        do {
            listener = try NWListener(using: params, on: nwPort)
        } catch {
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.start(queue: .global(qos: .userInitiated))
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .userInitiated))
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, _, _ in
            guard let self, let data, let requestString = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }

            if let code = self.extractAuthCode(from: requestString) {
                let successHTML = """
                HTTP/1.1 200 OK\r
                Content-Type: text/html\r
                Connection: close\r
                \r
                <html><body style="font-family: -apple-system, system-ui; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f7;">
                <div style="text-align: center;">
                <h1 style="font-size: 48px; margin-bottom: 8px;">&#x2705;</h1>
                <h2 style="color: #1d1d1f;">Ticker Connected</h2>
                <p style="color: #86868b;">You can close this tab and return to the app.</p>
                </div></body></html>
                """

                connection.send(content: successHTML.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })

                DispatchQueue.main.async {
                    self.onCodeReceived(code)
                }
            } else {
                let errorResponse = "HTTP/1.1 400 Bad Request\r\nConnection: close\r\n\r\nNo auth code found"
                connection.send(content: errorResponse.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })
            }
        }
    }

    private func extractAuthCode(from request: String) -> String? {
        guard let urlLine = request.split(separator: "\r\n").first,
              let pathPart = urlLine.split(separator: " ").dropFirst().first,
              let components = URLComponents(string: String(pathPart)),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return nil
        }
        return code
    }
}
