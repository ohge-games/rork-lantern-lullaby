import Foundation

/// Deck building for a campaign party.
nonisolated extension CardCatalog {

    /// The Dreamer's own lantern cards ride along in every campaign deck.
    /// They carry the Relax effects that keep the meter from running away,
    /// which the hero pools mostly lack on purpose — the lantern is the
    /// player's, not any one companion's.
    static let lanternCards: [(card: Card, copies: Int)] = [
        (deepBreath, 3),
        (mentalShift, 2),
        (focusedMind, 1),
        (dreamWalk, 1),
    ]

    /// Card IDs (one per copy) for a party deck: each hero contributes up to
    /// eight of their cheapest cards — two copies of the four cheapest, one
    /// of the rest — plus the shared lantern cards.
    static func partyDeckCardIDs(for heroes: [Hero]) -> [Card.ID] {
        var ids: [Card.ID] = []
        for hero in heroes {
            let pool = pool(for: hero).sorted { $0.lucidityCost < $1.lucidityCost }
            for (index, card) in pool.prefix(8).enumerated() {
                let copies = index < 4 ? 2 : 1
                ids.append(contentsOf: Array(repeating: card.id, count: copies))
            }
        }
        for entry in lanternCards {
            ids.append(contentsOf: Array(repeating: entry.card.id, count: entry.copies))
        }
        return ids
    }

    /// Heroes the player can put in a party (starters plus Book 1).
    static let playableHeroes: [Hero] = starterHeroes + book1Heroes
}
