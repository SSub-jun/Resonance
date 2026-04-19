import Foundation

enum SupabaseConfig {
    static let baseURL = URL(string: "https://daxfkooxhwpsgexczfal.supabase.co")!
    static let anonKey = "sb_publishable_fgljBnHxQ_kfiDjc_M-0Bg_kNr_dR0M"

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
