import Foundation

/// Static hero definition (content, not runtime state).
///
/// Note: `currentHealth` deliberately does NOT live here — a hero is a
/// reusable content template, while health changes per battle. Runtime
/// values live in `CombatantState`.
nonisolated struct Hero: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let maxHealth: Int
    let passive: PassiveAbility

    /// Class cards associated with this hero (used for deck building).
    let cardIDs: [Card.ID]
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
}
