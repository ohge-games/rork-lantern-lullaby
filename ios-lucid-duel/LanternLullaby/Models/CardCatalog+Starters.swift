import Foundation

/// Starter heroes available before any unlocks: Wart (young Arthur) and
/// Archimedes (Merlyn's owl). These two carry the player through stages 1-4
/// until Lancelot unlocks at Chapter 1, Stage 5.
nonisolated extension CardCatalog {

    // MARK: - Starter Hero IDs

    nonisolated enum StarterIDs {
        static let wart       = UUID(uuidString: "B0000000-0000-4000-8000-000000000001")!
        static let archimedes = UUID(uuidString: "B0000000-0000-4000-8000-000000000002")!
    }

    private static func starterCardID(_ uuidString: String) -> UUID {
        UUID(uuidString: uuidString) ?? UUID()
    }

    // MARK: - Wart — The Boy Who Will Be King

    // A young squire with no special powers yet—just courage and heart.
    // Simple, learnable cards that teach the basics.

    static let wartSwing = Card(
        id: starterCardID("A0100000-0000-4000-8000-000000000001"),
        name: "Practice Swing",
        text: "Deal 10 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 10)],
        heroID: StarterIDs.wart
    )

    static let wartBlock = Card(
        id: starterCardID("A0100000-0000-4000-8000-000000000002"),
        name: "Wooden Shield",
        text: "Gain 8 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 8)],
        heroID: StarterIDs.wart
    )

    static let wartCourage = Card(
        id: starterCardID("A0100000-0000-4000-8000-000000000003"),
        name: "Squire's Courage",
        text: "Deal 8 damage. Gain 4 shield.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 8), Effect(type: .shield, value: 4)],
        heroID: StarterIDs.wart
    )

    static let wartRest = Card(
        id: starterCardID("A0100000-0000-4000-8000-000000000004"),
        name: "Catch Breath",
        text: "Heal 8 HP.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 8)],
        heroID: StarterIDs.wart
    )

    static let wartWatch = Card(
        id: starterCardID("A0100000-0000-4000-8000-000000000005"),
        name: "Watch and Learn",
        text: "Draw 1 card. Gain 3 shield.",
        lucidityCost: 2,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 1), Effect(type: .shield, value: 3)],
        heroID: StarterIDs.wart
    )

    static let wartDestiny = Card(
        id: starterCardID("A0100000-0000-4000-8000-000000000006"),
        name: "Hidden Destiny",
        text: "Deal 14 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14)],
        heroID: StarterIDs.wart
    )

    static let wartCards: [Card] = [
        wartSwing, wartBlock, wartCourage, wartRest, wartWatch, wartDestiny,
    ]

    // MARK: - Archimedes — Merlyn's Owl

    // A wise owl who sees what others miss. Focuses on card draw and utility.

    static let owlPeck = Card(
        id: starterCardID("A0200000-0000-4000-8000-000000000001"),
        name: "Talon Strike",
        text: "Deal 9 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 9)],
        heroID: StarterIDs.archimedes
    )

    static let owlInsight = Card(
        id: starterCardID("A0200000-0000-4000-8000-000000000002"),
        name: "Owl's Insight",
        text: "Draw 2 cards.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: StarterIDs.archimedes
    )

    static let owlFeathers = Card(
        id: starterCardID("A0200000-0000-4000-8000-000000000003"),
        name: "Downy Feathers",
        text: "Gain 10 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10)],
        heroID: StarterIDs.archimedes
    )

    static let owlWisdom = Card(
        id: starterCardID("A0200000-0000-4000-8000-000000000004"),
        name: "Owl's Advice",
        text: "Heal 6 HP. Draw 1 card.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .heal, value: 6), Effect(type: .drawCards, value: 1)],
        heroID: StarterIDs.archimedes
    )

    static let owlSwoop = Card(
        id: starterCardID("A0200000-0000-4000-8000-000000000005"),
        name: "Silent Swoop",
        text: "Deal 12 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12)],
        heroID: StarterIDs.archimedes
    )

    static let owlForesight = Card(
        id: starterCardID("A0200000-0000-4000-8000-000000000006"),
        name: "Foresight",
        text: "Draw 1 card. Move Lucidity 4 toward Balanced.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 1), Effect(type: .lucidityCenter, value: 4)],
        heroID: StarterIDs.archimedes
    )

    static let archimedesCards: [Card] = [
        owlPeck, owlInsight, owlFeathers, owlWisdom, owlSwoop, owlForesight,
    ]

    // MARK: - Starter Heroes

    static let wart = Hero(
        id: StarterIDs.wart,
        name: "Wart",
        title: "The Boy Who Will Be King",
        maxHealth: 50,
        passive: PassiveAbility(
            name: "Innocent Sleep",
            text: "No special ability — Wart is still learning.",
            kind: .none
        ),
        storyText: "A young squire who doesn't yet know his destiny. In dreams, even the smallest can become legend.",
        cardIDs: wartCards.map(\.id)
    )

    static let archimedes = Hero(
        id: StarterIDs.archimedes,
        name: "Archimedes",
        title: "Merlyn's Owl",
        maxHealth: 40,
        passive: PassiveAbility(
            name: "Night Eyes",
            text: "Draw 1 extra card at the start of each turn.",
            kind: .bonusCardDraw(amount: 1)
        ),
        storyText: "A highly educated owl who has seen centuries pass. His feathers ruffle with impatience at foolishness.",
        cardIDs: archimedesCards.map(\.id)
    )

    /// The two starter heroes, used before any unlocks.
    static let starterHeroes: [Hero] = [wart, archimedes]

    /// All starter cards combined.
    static let starterHeroCards: [Card] = wartCards + archimedesCards
}
