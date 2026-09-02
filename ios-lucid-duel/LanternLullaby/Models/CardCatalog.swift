import Foundation

/// Static card and hero content for the starter set.
///
/// IDs are fixed (not random per launch) so content references — hero to
/// cards, saved games to definitions — stay stable across sessions.
nonisolated enum CardCatalog {
    private static func stableID(_ uuidString: String) -> UUID {
        UUID(uuidString: uuidString) ?? UUID()
    }

    // MARK: - Offensive

    static let strike = Card(
        id: stableID("A1000000-0000-4000-8000-000000000001"),
        name: "Strike",
        text: "Deal 12 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12)],
        heroID: nil
    )

    static let focusStrike = Card(
        id: stableID("A1000000-0000-4000-8000-000000000002"),
        name: "Focus Strike",
        text: "Deal 18 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: nil
    )

    static let concentratedBlow = Card(
        id: stableID("A1000000-0000-4000-8000-000000000003"),
        name: "Concentrated Blow",
        text: "Deal 15 damage. Draw 1 card.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [
            Effect(type: .damage, value: 15),
            Effect(type: .drawCards, value: 1),
        ],
        heroID: nil
    )

    // MARK: - Defensive

    static let shieldWall = Card(
        id: stableID("A1000000-0000-4000-8000-000000000004"),
        name: "Shield",
        text: "Gain 10 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10)],
        heroID: nil
    )

    static let meditate = Card(
        id: stableID("A1000000-0000-4000-8000-000000000005"),
        name: "Meditate",
        text: "Heal 10 health.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 10)],
        heroID: nil
    )

    static let deepBreath = Card(
        id: stableID("A1000000-0000-4000-8000-000000000006"),
        name: "Deep Breath",
        text: "Relax: reduce Lucidity by 12.",
        lucidityCost: 0,
        cardType: .defensive,
        effects: [Effect(type: .lucidityModify, value: -12)],
        heroID: nil
    )

    // MARK: - Utility

    static let dreamWalk = Card(
        id: stableID("A1000000-0000-4000-8000-000000000007"),
        name: "Dream Walk",
        text: "Draw 2 cards.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: nil
    )

    static let focusedMind = Card(
        id: stableID("A1000000-0000-4000-8000-000000000009"),
        name: "Focused Mind",
        text: "Choose: Concentrate or Relax.",
        lucidityCost: 0,
        cardType: .utility,
        effects: [],
        heroID: nil,
        choices: [
            CardChoiceOption(
                id: "concentrate",
                name: "Concentrate",
                text: "+12 Lucidity · Deal 16 damage",
                iconName: "bolt.fill",
                effects: [
                    Effect(type: .lucidityModify, value: 12),
                    Effect(type: .damage, value: 16),
                ]
            ),
            CardChoiceOption(
                id: "relax",
                name: "Relax",
                text: "−10 Lucidity · Heal 12",
                iconName: "leaf.fill",
                effects: [
                    Effect(type: .lucidityModify, value: -10),
                    Effect(type: .heal, value: 12),
                ]
            ),
        ]
    )

    static let mentalShift = Card(
        id: stableID("A1000000-0000-4000-8000-000000000008"),
        name: "Mental Shift",
        text: "Move Lucidity 8 toward Balanced.",
        lucidityCost: 2,
        cardType: .utility,
        effects: [Effect(type: .lucidityCenter, value: 8)],
        heroID: nil
    )

    /// Neutral cards usable by any deck (the original starter set).
    static let neutralCards: [Card] = [
        strike, focusStrike, concentratedBlow,
        shieldWall, meditate, deepBreath,
        dreamWalk, mentalShift, focusedMind, stepForward,
    ]

    /// Every card definition in the game: neutrals, starters, and each hero's pool.
    /// Lookups (`card(withID:)`, `pool(for:)`) read from this master list.
    static let allCards: [Card] =
        neutralCards +
        starterHeroCards +
        lancelotCards + bedivereCards + escanorCards + merlinCards +
        kayCards + morganaCards + galahadCards

    static func card(withID id: Card.ID) -> Card? {
        allCards.first { $0.id == id }
    }

    // MARK: - Heroes

    static let dreamer = Hero(
        id: stableID("B1000000-0000-4000-8000-000000000001"),
        name: "The Dreamer",
        maxHealth: 55,
        passive: PassiveAbility(
            name: "Slow Wave",
            text: "At the start of your turn, Lucidity drifts 2 toward Balanced.",
            kind: .lucidityDrift(amount: 2)
        ),
        cardIDs: neutralCards.map(\.id)
    )

    static let nightmare = Hero(
        id: stableID("B1000000-0000-4000-8000-000000000002"),
        name: "The Nightmare",
        maxHealth: 100,
        passive: PassiveAbility(
            name: "Vivid Fury",
            text: "Deals 2 extra damage while Vivid.",
            kind: .vividFury(amount: 2)
        ),
        cardIDs: []
    )

    /// Fresh 18-card starter deck as unique instances (unshuffled).
    static func starterDeck() -> [CardInstance] {
        let composition: [(card: Card, copies: Int)] = [
            (strike, 3), (focusStrike, 2), (concentratedBlow, 1),
            (shieldWall, 2), (meditate, 2), (deepBreath, 3),
            (dreamWalk, 2), (mentalShift, 1), (focusedMind, 2),
        ]
        return composition.flatMap { entry in
            (0..<entry.copies).map { _ in CardInstance(cardID: entry.card.id) }
        }
    }
}
