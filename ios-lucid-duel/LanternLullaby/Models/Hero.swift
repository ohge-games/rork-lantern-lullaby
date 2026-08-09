import Foundation

/// Static hero definition (content, not runtime state).
///
/// Note: `currentHealth` deliberately does NOT live here — a hero is a
/// reusable content template, while health changes per battle. Runtime
/// values live in `CombatantState`.
nonisolated struct Hero: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    /// Epithet shown below the name (e.g., "The Lion of Benwick").
    let title: String
    let maxHealth: Int
    let passive: PassiveAbility
    /// One or two sentences of flavor text for the hero detail panel.
    let storyText: String

    /// Class cards associated with this hero (used for deck building).
    let cardIDs: [Card.ID]
    
    /// Convenience initializer with default empty title/story for backwards compatibility.
    init(
        id: UUID,
        name: String,
        title: String = "",
        maxHealth: Int,
        passive: PassiveAbility,
        storyText: String = "",
        cardIDs: [Card.ID]
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.maxHealth = maxHealth
        self.passive = passive
        self.storyText = storyText
        self.cardIDs = cardIDs
    }
}

/// A hero's always-on rule-bending ability.
nonisolated struct PassiveAbility: Codable, Hashable, Sendable {
    let name: String

    /// Player-facing description of what the passive does.
    let text: String

    /// Machine-readable hook so the battle engine can apply the passive
    /// without string matching.
    let kind: PassiveKind
}

/// The rule hook a passive plugs into. Each case carries its tuning value
/// so new heroes are data, not code.
nonisolated enum PassiveKind: Codable, Hashable, Sendable {
    /// All lucidity increases from card costs are reduced by `amount`.
    case cheaperLucidityCosts(amount: Int)
    /// At the start of each turn, lucidity drifts toward 50 by `amount`.
    case lucidityDrift(amount: Int)
    /// Damage effects deal `amount` extra while in the Vivid zone.
    case vividFury(amount: Int)
    /// Shield effects grant `amount` extra while in the Drifting zone.
    case driftingBulwark(amount: Int)
    /// Heals the hero by `amount` whenever a Relax effect resolves.
    case restfulRecovery(amount: Int)
    /// Damage effects gain `perTurn * (turnNumber - 1)` bonus, so the hero
    /// hits harder the longer the battle runs (Escanor's "The One").
    case growingMight(perTurn: Int)
    /// The first card played each turn costs `amount` less Lucidity (Kay).
    case firstCardDiscount(amount: Int)
    /// Whenever this hero applies a debuff, heal `amount` HP (Morgana).
    case debuffHealing(amount: Int)
    /// While this hero has no debuffs, heal `amount` HP at turn start (Galahad).
    case purityHealing(amount: Int)
    /// While in Balanced zone, take `percent`% reduced damage (Bedivere alternate).
    case balancedResilience(percent: Int)
    /// Draw `amount` extra card(s) at turn start (Archimedes).
    case bonusCardDraw(amount: Int)
    /// No special effect — for tutorial heroes (Wart).
    case none
}
