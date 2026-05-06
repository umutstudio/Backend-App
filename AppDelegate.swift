import Cocoa
import Network

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var listener: NWListener?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Menü bar ikonu
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "⚙️"
        }

        // Basit HTTP server
        do {
            listener = try NWListener(using: .tcp, on: 8080)
            listener?.newConnectionHandler = { connection in
                connection.start(queue: .main)
                connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, _ in
                    if let data = data, let request = String(data: data, encoding: .utf8) {
                        print("İstek geldi:\n\(request)")

                        // Basit cevap
                        let responseBody = "winget install Chrome\nwinget install Spotify\n"
                        let response = """
                        HTTP/1.1 200 OK\r
                        Content-Type: text/plain\r
                        Content-Length: \(responseBody.count)\r
                        \r
                        \(responseBody)
                        """
                        connection.send(content: response.data(using: .utf8), completion: .contentProcessed({ _ in
                            connection.cancel()
                        }))
                    }
                }
            }
            listener?.start(queue: .main)
            print("Backend çalışıyor: http://localhost:8080")
        } catch {
            print("Sunucu başlatılamadı: \(error)")
        }
    }
}
