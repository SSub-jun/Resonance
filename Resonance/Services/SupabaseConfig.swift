import Foundation

enum SupabaseConfig {
    static let baseURL = URL(string: "https://pjbrvkzyxnjhhifqkdyz.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYnJ2a3p5eG5qaGhpZnFrZHl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4NjM1MjYsImV4cCI6MjA4ODQzOTUyNn0.Hxhx27c0ZnqXp82FwfJxNq8_sbb12pCK7rIJL7XcqbQ"

    enum Table {
        static let users = "kyomei_users"
        static let events = "kyomei_resonance_events"
    }

    static var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0.0.0"
    }

    static func restURL(_ table: String) -> URL {
        baseURL.appendingPathComponent("rest/v1").appendingPathComponent(table)
    }

    static func applyDefaultHeaders(_ request: inout URLRequest) {
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
