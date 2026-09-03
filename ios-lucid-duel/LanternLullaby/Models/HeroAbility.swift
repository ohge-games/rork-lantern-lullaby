import Foundation

/// A hero's active ability: the thing they do when the dream finally
/// listens to them.
///
/// Passives are always-on and invisible. An ability is the opposite — it
/// charges as you play that hero's own cards, waits, and then fires for
/// free. It costs no Lucidity, which is the point: it is the answer to a
/// turn where the lantern is too bright to play anything else.
nonisolated struct HeroAbility: Codable, Hashable, Sendable {
    let name: String
    /// Player-facing rules text.
    let text: String
    /// How many of this hero's cards must be played to charge it.
    let chargeRequired: Int
    /// Resolved exactly like a card's effects, minus the cost.
    let effects: [Effect]
}

/// One ability per playable hero, kept out of `Hero` so the catalogs stay
/// pure data — the same arrangement `ArtCatalog` uses for paintings.
///
/// Charge comes from playing cards that belong to the hero, whether they
/// are leading or waiting at the back, so a deck built around someone pays
/// off even while another hero holds the front.
nonisolated enum HeroAbilities {

    static func ability(for hero: Hero) -> HeroAbility? {
        abilities[hero.id]
    }

    static func ability(forHeroID id: UUID) -> HeroAbility? {
        abilities[id]
    }

    private static let abilities: [UUID: HeroAbility] = [
        CardCatalog.HeroIDs.wart: HeroAbility(
            name: "Beginner's Luck",
            text: "Draw 2 cards and gain 8 shield.",
            chargeRequired: 4,
            effects: [
                Effect(type: .drawCards, value: 2),
                Effect(type: .shield, value: 8),
            ]
        ),
        CardCatalog.HeroIDs.archimedes: HeroAbility(
            name: "Wise Counsel",
            text: "Draw 3 cards and settle the lantern 10 toward Balanced.",
            chargeRequired: 4,
            effects: [
                Effect(type: .drawCards, value: 3),
                Effect(type: .lucidityCenter, value: 10),
            ]
        ),
        CardCatalog.HeroIDs.lancelot: HeroAbility(
            name: "Peerless Charge",
            text: "Deal 30 damage to the targeted enemy.",
            chargeRequired: 5,
            effects: [Effect(type: .damage, value: 30)]
        ),
        CardCatalog.HeroIDs.kay: HeroAbility(
            name: "Seneschal's Stores",
            text: "Draw 2 cards, heal 12, and lower Lucidity 6.",
            chargeRequired: 4,
            effects: [
                Effect(type: .drawCards, value: 2),
                Effect(type: .heal, value: 12),
                Effect(type: .lucidityModify, value: -6),
            ]
        ),
        CardCatalog.HeroIDs.bedivere: HeroAbility(
            name: "Hold the Line",
            text: "Gain 26 shield and heal 10.",
            chargeRequired: 4,
            effects: [
                Effect(type: .shield, value: 26),
                Effect(type: .heal, value: 10),
            ]
        ),
        CardCatalog.HeroIDs.morgana: HeroAbility(
            name: "Fey Bargain",
            text: "Deal 22 damage and heal 10.",
            chargeRequired: 5,
            effects: [
                Effect(type: .damage, value: 22),
                Effect(type: .heal, value: 10),
            ]
        ),
        CardCatalog.HeroIDs.escanor: HeroAbility(
            name: "The One",
            text: "Deal 40 damage to the targeted enemy.",
            chargeRequired: 6,
            effects: [Effect(type: .damage, value: 40)]
        ),
        CardCatalog.HeroIDs.galahad: HeroAbility(
            name: "Grail's Light",
            text: "Heal 25 and lower Lucidity 8.",
            chargeRequired: 5,
            effects: [
                Effect(type: .heal, value: 25),
                Effect(type: .lucidityModify, value: -8),
            ]
        ),
        CardCatalog.HeroIDs.merlin: HeroAbility(
            name: "Living Backwards",
            text: "Settle the lantern all the way to Balanced and draw 3 cards.",
            chargeRequired: 5,
            effects: [
                Effect(type: .lucidityCenter, value: 50),
                Effect(type: .drawCards, value: 3),
            ]
        ),
    ]
}
