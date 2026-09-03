import Foundation

/// What the victory card tells the player: where they are in the book,
/// who just joined them, and what the next page is called.
///
/// Built by `CampaignCoordinator` *before* the win is recorded, so it can
/// name the heroes a victory is about to unlock. The battle screen carries
/// it purely as display data.
nonisolated struct VictorySummary: Hashable, Sendable {
    let stageName: String
    let chapterTitle: String
    /// One-based, for reading: "Page 5 of 10".
    let pageNumber: Int
    let pageCount: Int
    /// The stage this victory opens, if the chapter has one left.
    let nextStageName: String?
    /// The next chapter's title, when this win closes the current one.
    let nextChapterTitle: String?
    /// Heroes this victory adds to the roster.
    let unlockedHeroes: [Hero]

    var isChapterFinale: Bool { pageNumber >= pageCount }

    /// Roman numeral for the chapter, since the book pages read that way.
    static func numeral(_ index: Int) -> String {
        let numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
        return numerals.indices.contains(index) ? numerals[index] : "\(index + 1)"
    }
}
