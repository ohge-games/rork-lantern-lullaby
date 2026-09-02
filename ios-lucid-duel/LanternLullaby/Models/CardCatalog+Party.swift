import Foundation

/// Deck building for a campaign party.
nonisolated extension CardCatalog {

    /// The Dreamer's own lantern cards ride along in every campaign deck.
    /// They carry the Relax effects that keep the meter from running away,
    /// which the hero pools mostly lack on purpose — the lantern is the
    /// player's, not any one companion's.
    static let lanternCards: [(card: Card, copies: Int)] = [
        (strike, 2),
        (focusStrike, 1),
        (deepBreath, 3),
        (mentalShift, 2),
        (focusedMind, 1),
        (dreamWalk, 1),
        (stepForward, 1),
    ]

    /// The one card that changes the party's order mid-battle: drag it onto
    /// a hero and they step to the front (and take the hits) from then on.
    static let stepForward = Card(
        id: UUID(uuidString: "A1000000-0000-4000-8000-000000000010")!,
        name: "Step Forward",
        text: "Chosen hero leads. Gain 5 shield.",
        lucidityCost: 1,
        cardType: .utility,
        effects: [
            Effect(type: .swapLead, value: 0),
            Effect(type: .shield, value: 5),
        ],
        heroID: nil
    )

    /// Card IDs (one per copy) for a party deck.
    ///
    /// Attacks are what actually end a fight, so each hero brings three
    /// copies of their cheapest attacks, two of their cheapest defensive
    /// cards and one each of a little utility — then the shared lantern
    /// cards (which carry the Relax effects and two plain Strikes) go on
    /// top. That lands a two-hero deck at roughly 45% attacks.
    static func partyDeckCardIDs(for heroes: [Hero]) -> [Card.ID] {
        var ids: [Card.ID] = []
        for hero in heroes {
            let pool = pool(for: hero).sorted { $0.lucidityCost < $1.lucidityCost }
            let offensive = pool.filter { $0.cardType == .offensive }.prefix(4)
            let defensive = pool.filter { $0.cardType == .defensive }.prefix(2)
            let utility = pool.filter { $0.cardType == .utility }.prefix(2)

            for card in offensive {
                ids.append(contentsOf: Array(repeating: card.id, count: 3))
            }
            for card in defensive {
                ids.append(contentsOf: Array(repeating: card.id, count: 2))
            }
            for card in utility {
                ids.append(card.id)
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
