import Foundation

/// Cards that answer what the enemy is about to do. The intent chip tells
/// you the plan; these are how you argue with it. Two live in the shared
/// lantern set so every party has an answer, and the rest belong to heroes.
nonisolated extension CardCatalog {
    /// Lantern: the target loses its next action but keeps its plan queued.
    static let hush = Card(
        id: stableID("A1000000-0000-4000-8000-000000000011"),
        name: "Hush",
        text: "The enemy skips its next action. Its plan waits.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [Effect(type: .stun, value: 1)],
        heroID: nil
    )

    /// Lantern: a Relax card that also blows out a wind-up or enrage.
    static let snuffedWick = Card(
        id: stableID("A1000000-0000-4000-8000-000000000012"),
        name: "Snuffed Wick",
        text: "−6 Lucidity. Cancel the enemy's wind-up and enrage.",
        lucidityCost: 0,
        cardType: .utility,
        effects: [
            Effect(type: .lucidityModify, value: -6),
            Effect(type: .calm, value: 1),
        ],
        heroID: nil
    )

    /// Wart: a cheap poke that takes the sting out of the next blow.
    static let woodenFeint = Card(
        id: stableID("A1000000-0000-4000-8000-000000000013"),
        name: "Wooden Feint",
        text: "Deal 6. The enemy's next attack deals 6 less.",
        lucidityCost: 3,
        cardType: .offensive,
        effects: [
            Effect(type: .damage, value: 6),
            Effect(type: .weaken, value: 6),
        ],
        heroID: HeroIDs.wart
    )

    /// Kay: the practical answer to a braced enemy.
    static let cutTheStraps = Card(
        id: stableID("A1000000-0000-4000-8000-000000000014"),
        name: "Cut the Straps",
        text: "Destroy the enemy's shield, then deal 8.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [
            Effect(type: .shieldBreak, value: 1),
            Effect(type: .damage, value: 8),
        ],
        heroID: HeroIDs.kay
    )

    static let answerCards: [Card] = [hush, snuffedWick, woodenFeint, cutTheStraps]
}
