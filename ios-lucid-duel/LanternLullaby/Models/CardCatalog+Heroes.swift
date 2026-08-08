import Foundation

/// Playable roster (Lancelot, Bedivere, Escanor, Merlin) and their fully
/// dedicated card pools.
///
/// Kept in its own file so the starter-set content in `CardCatalog.swift`
/// stays readable. Each hero owns a standalone pool — no neutral sharing —
/// so class identity comes through in the deck itself. Every card here sets
/// `heroID`, which is how `pool(for:)` and `starterDeck(for:)` find them
/// without hardcoding membership lists.
extension CardCatalog {

    /// Stable hero identities. Fixed UUIDs (see `CardCatalog.stableID` for
    /// the rationale) keep hero→card and save→definition references stable
    /// across launches.
    enum HeroIDs {
        static let lancelot = UUID(uuidString: "B2000000-0000-4000-8000-000000000001")!
        static let bedivere = UUID(uuidString: "B3000000-0000-4000-8000-000000000001")!
        static let escanor  = UUID(uuidString: "B4000000-0000-4000-8000-000000000001")!
        static let merlin   = UUID(uuidString: "B5000000-0000-4000-8000-000000000001")!
    }

    private static func classID(_ uuidString: String) -> UUID {
        UUID(uuidString: uuidString) ?? UUID()
    }

    // MARK: - Lancelot — burst aggression (offensive, high lucidity risk)

    static let lionsCharge = Card(
        id: classID("A2000000-0000-4000-8000-000000000001"),
        name: "Lion's Charge",
        text: "Deal 30 damage.",
        lucidityCost: 18,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 30)],
        heroID: HeroIDs.lancelot
    )

    static let twinSlash = Card(
        id: classID("A2000000-0000-4000-8000-000000000002"),
        name: "Twin Slash",
        text: "Deal 12 damage. Draw 1 card.",
        lucidityCost: 10,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.lancelot
    )

    static let recklessAssault = Card(
        id: classID("A2000000-0000-4000-8000-000000000003"),
        name: "Reckless Assault",
        text: "Deal 22 damage.",
        lucidityCost: 14,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 22)],
        heroID: HeroIDs.lancelot
    )

    static let battleTrance = Card(
        id: classID("A2000000-0000-4000-8000-000000000004"),
        name: "Battle Trance",
        text: "Draw 2 cards.",
        lucidityCost: 6,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: HeroIDs.lancelot
    )

    static let steelGuard = Card(
        id: classID("A2000000-0000-4000-8000-000000000005"),
        name: "Steel Guard",
        text: "Gain 12 shield.",
        lucidityCost: 6,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 12)],
        heroID: HeroIDs.lancelot
    )

    static let finalGambit = Card(
        id: classID("A2000000-0000-4000-8000-000000000006"),
        name: "Final Gambit",
        text: "Deal 40 damage.",
        lucidityCost: 25,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 40)],
        heroID: HeroIDs.lancelot
    )

    static let lancelotCards: [Card] = [
        lionsCharge, twinSlash, recklessAssault, battleTrance, steelGuard, finalGambit,
    ]

    // MARK: - Bedivere — shields and sustain (defensive)

    static let loyalGuard = Card(
        id: classID("A3000000-0000-4000-8000-000000000001"),
        name: "Loyal Guard",
        text: "Gain 18 shield. Draw 1 card.",
        lucidityCost: 7,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 18), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.bedivere
    )

    static let swornOath = Card(
        id: classID("A3000000-0000-4000-8000-000000000002"),
        name: "Sworn Oath",
        text: "Gain 12 shield. Heal 6 health.",
        lucidityCost: 8,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 12), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.bedivere
    )

    static let counterstance = Card(
        id: classID("A3000000-0000-4000-8000-000000000003"),
        name: "Counterstance",
        text: "Deal 10 damage. Gain 10 shield.",
        lucidityCost: 10,
        cardType: .defensive,
        effects: [Effect(type: .damage, value: 10), Effect(type: .shield, value: 10)],
        heroID: HeroIDs.bedivere
    )

    static let steadyBreath = Card(
        id: classID("A3000000-0000-4000-8000-000000000004"),
        name: "Steady Breath",
        text: "Relax: reduce Lucidity by 10.",
        lucidityCost: 0,
        cardType: .defensive,
        effects: [Effect(type: .lucidityModify, value: -10)],
        heroID: HeroIDs.bedivere
    )

    static let aegisWall = Card(
        id: classID("A3000000-0000-4000-8000-000000000005"),
        name: "Aegis Wall",
        text: "Gain 25 shield.",
        lucidityCost: 12,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 25)],
        heroID: HeroIDs.bedivere
    )

    static let vigilStrike = Card(
        id: classID("A3000000-0000-4000-8000-000000000006"),
        name: "Vigil Strike",
        text: "Deal 14 damage.",
        lucidityCost: 9,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14)],
        heroID: HeroIDs.bedivere
    )

    static let bedivereCards: [Card] = [
        loyalGuard, swornOath, counterstance, steadyBreath, aegisWall, vigilStrike,
    ]

    // MARK: - Escanor — scaling payoff (grows stronger each turn)

    static let cruelSun = Card(
        id: classID("A4000000-0000-4000-8000-000000000001"),
        name: "Cruel Sun",
        text: "Deal 20 damage.",
        lucidityCost: 16,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20)],
        heroID: HeroIDs.escanor
    )

    static let risingPride = Card(
        id: classID("A4000000-0000-4000-8000-000000000002"),
        name: "Rising Pride",
        text: "Deal 15 damage. Raises Lucidity.",
        lucidityCost: 10,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 15)],
        heroID: HeroIDs.escanor
    )

    static let noonBlaze = Card(
        id: classID("A4000000-0000-4000-8000-000000000003"),
        name: "Noon Blaze",
        text: "Deal 28 damage.",
        lucidityCost: 20,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 28)],
        heroID: HeroIDs.escanor
    )

    static let sunshine = Card(
        id: classID("A4000000-0000-4000-8000-000000000004"),
        name: "Sunshine",
        text: "Heal 12 health. Gain 12 shield.",
        lucidityCost: 10,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 12), Effect(type: .shield, value: 12)],
        heroID: HeroIDs.escanor
    )

    static let arrogance = Card(
        id: classID("A4000000-0000-4000-8000-000000000005"),
        name: "Arrogance",
        text: "Draw 2 cards.",
        lucidityCost: 6,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: HeroIDs.escanor
    )

    static let divineAxeRhitta = Card(
        id: classID("A4000000-0000-4000-8000-000000000006"),
        name: "Divine Axe Rhitta",
        text: "Deal 45 damage.",
        lucidityCost: 28,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 45)],
        heroID: HeroIDs.escanor
    )

    static let escanorCards: [Card] = [
        cruelSun, risingPride, noonBlaze, sunshine, arrogance, divineAxeRhitta,
    ]

    // MARK: - Merlin — utility and lucidity control (mage)

    static let infinity = Card(
        id: classID("A5000000-0000-4000-8000-000000000001"),
        name: "Infinity",
        text: "Draw 3 cards.",
        lucidityCost: 8,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 3)],
        heroID: HeroIDs.merlin
    )

    static let aldansInsight = Card(
        id: classID("A5000000-0000-4000-8000-000000000002"),
        name: "Aldan's Insight",
        text: "Move Lucidity 10 toward Balanced. Draw 1 card.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .lucidityCenter, value: 10), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.merlin
    )

    static let arcaneBolt = Card(
        id: classID("A5000000-0000-4000-8000-000000000003"),
        name: "Arcane Bolt",
        text: "Deal 18 damage.",
        lucidityCost: 12,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: HeroIDs.merlin
    )

    static let absoluteCancel = Card(
        id: classID("A5000000-0000-4000-8000-000000000004"),
        name: "Absolute Cancel",
        text: "Gain 15 shield. Relax: reduce Lucidity by 8.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 15), Effect(type: .lucidityModify, value: -8)],
        heroID: HeroIDs.merlin
    )

    static let manaWell = Card(
        id: classID("A5000000-0000-4000-8000-000000000005"),
        name: "Mana Well",
        text: "Heal 10 health. Draw 1 card.",
        lucidityCost: 6,
        cardType: .utility,
        effects: [Effect(type: .heal, value: 10), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.merlin
    )

    static let realityShift = Card(
        id: classID("A5000000-0000-4000-8000-000000000006"),
        name: "Reality Shift",
        text: "Choose: Unravel or Ward.",
        lucidityCost: 0,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.merlin,
        choices: [
            CardChoiceOption(
                id: "unravel",
                name: "Unravel",
                text: "+10 Lucidity · Deal 22 damage",
                iconName: "sparkles",
                effects: [
                    Effect(type: .lucidityModify, value: 10),
                    Effect(type: .damage, value: 22),
                ]
            ),
            CardChoiceOption(
                id: "ward",
                name: "Ward",
                text: "−8 Lucidity · Gain 18 shield",
                iconName: "shield.lefthalf.filled",
                effects: [
                    Effect(type: .lucidityModify, value: -8),
                    Effect(type: .shield, value: 18),
                ]
            ),
        ]
    )

    static let merlinCards: [Card] = [
        infinity, aldansInsight, arcaneBolt, absoluteCancel, manaWell, realityShift,
    ]

    // MARK: - Heroes

    static let lancelot = Hero(
        id: HeroIDs.lancelot,
        name: "Lancelot",
        maxHealth: 70,
        passive: PassiveAbility(
            name: "Vivid Fury",
            text: "Offensive cards deal 2 extra damage while Vivid.",
            kind: .vividFury(amount: 2)
        ),
        cardIDs: lancelotCards.map(\.id)
    )

    static let bedivere = Hero(
        id: HeroIDs.bedivere,
        name: "Bedivere",
        maxHealth: 85,
        passive: PassiveAbility(
            name: "Drifting Bulwark",
            text: "Shield effects grant 3 extra while Drifting.",
            kind: .driftingBulwark(amount: 3)
        ),
        cardIDs: bedivereCards.map(\.id)
    )

    static let escanor = Hero(
        id: HeroIDs.escanor,
        name: "Escanor",
        maxHealth: 65,
        passive: PassiveAbility(
            name: "The One",
            text: "Damage grows by 3 each turn the battle continues.",
            kind: .growingMight(perTurn: 3)
        ),
        cardIDs: escanorCards.map(\.id)
    )

    static let merlin = Hero(
        id: HeroIDs.merlin,
        name: "Merlin",
        maxHealth: 60,
        passive: PassiveAbility(
            name: "Infinite Wisdom",
            text: "Lucidity increases from card costs are reduced by 2.",
            kind: .cheaperLucidityCosts(amount: 2)
        ),
        cardIDs: merlinCards.map(\.id)
    )

    /// The four playable heroes, in roster order.
    static let playableHeroes: [Hero] = [lancelot, bedivere, escanor, merlin]

    /// Every hero known to the game (roster + starter-set templates).
    static let allHeroes: [Hero] = playableHeroes + [dreamer, nightmare]

    static func hero(withID id: Hero.ID) -> Hero? {
        allHeroes.first { $0.id == id }
    }

    // MARK: - Pools & decks

    /// This hero's full card pool. Dedicated pools carry no neutral cards, so
    /// this is simply every card tagged with the hero's `id`.
    static func pool(for hero: Hero) -> [Card] {
        allCards.filter { $0.heroID == hero.id }
    }

    /// Class-card lookup usable while `allCards` is being assembled.
    private static func classCards(for id: Hero.ID) -> [Card] {
        switch id {
        case HeroIDs.lancelot: return lancelotCards
        case HeroIDs.bedivere: return bedivereCards
        case HeroIDs.escanor:  return escanorCards
        case HeroIDs.merlin:   return merlinCards
        default:               return []
        }
    }

    /// Fresh starter deck for a playable hero, built from that hero's own
    /// pool. Copy counts lean on cheap staples and limit the expensive
    /// finishers, mirroring the neutral `starterDeck()` composition.
    static func starterDeck(for hero: Hero) -> [CardInstance] {
        let cards = classCards(for: hero.id)
        guard !cards.isEmpty else { return starterDeck() }
        // Two copies of the cheaper half, one of the pricier half.
        let sorted = cards.sorted { $0.lucidityCost < $1.lucidityCost }
        let split = sorted.count / 2
        let composition: [(card: Card, copies: Int)] =
            sorted.enumerated().map { index, card in
                (card, index < split ? 3 : index == sorted.count - 1 ? 1 : 2)
            }
        return composition.flatMap { entry in
            (0..<entry.copies).map { _ in CardInstance(cardID: entry.card.id) }
        }
    }
}
