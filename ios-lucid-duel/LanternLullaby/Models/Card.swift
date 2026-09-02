import Foundation

/// Broad category driving zone bonuses and AI/deck-building heuristics.
nonisolated enum CardType: String, Codable, CaseIterable, Sendable {
    case offensive
    case defensive
    case utility
}

/// Static card definition (content, not runtime state).
///
/// Decks, hands, and discard piles reference cards by `Card.ID` so the same
/// definition can appear multiple times without duplicating data.
nonisolated struct Card: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String

    /// Rules text shown on the card face.
    let text: String

    /// How much playing this card *raises* the Lucidity meter (>= 0).
    /// Cards that lower the meter do it through a `lucidityModify` effect
    /// with a negative value — cost and Relax effects can coexist on one
    /// card (net movement = `lucidityCost` + effect deltas).
    let lucidityCost: Int

    let cardType: CardType

    /// Effects resolve in array order when the card is played.
    let effects: [Effect]

    /// Owning hero for class cards; `nil` for neutral cards any deck can use.
    let heroID: Hero.ID?

    /// Dual-direction cards: when non-nil, the player must pick exactly one
    /// option and its effects resolve after `effects`.
    let choices: [CardChoiceOption]?

    init(
        id: UUID,
        name: String,
        text: String,
        lucidityCost: Int,
        cardType: CardType,
        effects: [Effect],
        heroID: Hero.ID?,
        choices: [CardChoiceOption]? = nil
    ) {
        self.id = id
        self.name = name
        self.text = text
        self.lucidityCost = lucidityCost
        self.cardType = cardType
        self.effects = effects
        self.heroID = heroID
        self.choices = choices
    }

    /// Every effect this card can resolve, both branches included.
    private var allEffects: [Effect] {
        effects + (choices?.flatMap(\.effects) ?? [])
    }

    /// True when the card must be aimed at somebody: damage picks an enemy,
    /// heal / shield / lead-change pick one of your heroes. Cards that only
    /// move the meter or draw are global — pull them up to play.
    var needsTarget: Bool {
        allEffects.contains { effect in
            switch effect.type {
            case .damage, .heal, .shield, .swapLead:
                return true
            case .lucidityModify, .lucidityCenter, .drawCards:
                return false
            }
        }
    }

    /// Net lucidity movement for the caster, before passives.
    var netLucidityShift: Int {
        lucidityCost + effects
            .filter { $0.type == .lucidityModify }
            .reduce(0) { $0 + $1.value }
    }
}
