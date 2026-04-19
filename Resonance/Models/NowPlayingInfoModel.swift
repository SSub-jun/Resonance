import Foundation

struct NowPlayingInfoModel: Codable, Equatable, Hashable {
    let rawTitle: String
    let normalizedTitle: String
    let rawArtist: String
    let normalizedArtist: String
    let artworkURL: URL?
    let updatedAt: Date

    init(
        rawTitle: String,
        normalizedTitle: String,
        rawArtist: String,
        normalizedArtist: String,
        artworkURL: URL? = nil,
        updatedAt: Date
    ) {
        self.rawTitle = rawTitle
        self.normalizedTitle = normalizedTitle
        self.rawArtist = rawArtist
        self.normalizedArtist = normalizedArtist
        self.artworkURL = artworkURL
        self.updatedAt = updatedAt
    }

    static let empty = NowPlayingInfoModel(
        rawTitle: "",
        normalizedTitle: "",
        rawArtist: "",
        normalizedArtist: "",
        updatedAt: .distantPast
    )
}
