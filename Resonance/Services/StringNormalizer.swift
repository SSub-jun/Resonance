import Foundation

enum StringNormalizer {
    static func normalizeTitle(_ input: String) -> String {
        var s = baseNormalize(input)
        s = stripParenVersionTags(s)
        s = stripPunctuation(s)
        s = collapseWhitespace(s)
        return s
    }

    static func normalizeArtist(_ input: String) -> String {
        var s = baseNormalize(input)
        s = stripFeat(s)
        s = stripPunctuation(s)
        s = collapseWhitespace(s)
        return s
    }

    // MARK: - Steps

    private static func baseNormalize(_ input: String) -> String {
        input
            .precomposedStringWithCompatibilityMapping
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let parenVersionPattern: NSRegularExpression = {
        let pattern = #"\s*[\(\[（【]\s*(live|remaster(ed)?(\s*\d{2,4})?|remix|edit|version|ver\.?|deluxe|extended|acoustic|demo|mono|stereo|instrumental|inst\.?|radio edit|single version|bonus track|explicit|clean)[^\)\]）】]*[\)\]）】]"#
        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    private static func stripParenVersionTags(_ input: String) -> String {
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        return parenVersionPattern.stringByReplacingMatches(
            in: input,
            options: [],
            range: range,
            withTemplate: ""
        )
    }

    private static let featPattern: NSRegularExpression = {
        let pattern = #"\s*[\(\[（【]?\s*(feat\.?|ft\.?|featuring|with)\b[^\)\]）】]*[\)\]）】]?.*$"#
        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    private static func stripFeat(_ input: String) -> String {
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        return featPattern.stringByReplacingMatches(
            in: input,
            options: [],
            range: range,
            withTemplate: ""
        )
    }

    private static let punctuationToStrip = CharacterSet(charactersIn: "!?.,;:\"'`~/\\|*_=+<>{}^&#@$%")

    private static func stripPunctuation(_ input: String) -> String {
        input.unicodeScalars
            .filter { !punctuationToStrip.contains($0) }
            .reduce(into: "") { $0.unicodeScalars.append($1) }
    }

    private static func collapseWhitespace(_ input: String) -> String {
        input
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
