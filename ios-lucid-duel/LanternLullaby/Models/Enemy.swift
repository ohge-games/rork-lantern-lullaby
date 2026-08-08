import Foundation

/// How dangerous an enemy is, driving stat budgets, art scale, and rewards.
nonisolated enum EnemyTier: String, Codable, CaseIterable, Sendable {
    case minion
    case elite
    case boss
}

/// A single telegraphed enemy action. Superset of the view-layer
/// `EnemyIntent` (`.attack`/`.brace`): patterns are authored in these terms
/// and the engine maps the chosen move onto an `EnemyIntent` to display.
nonisolated enum EnemyMove: Codable, Hashable, Sendable {
    /// Deal `Int` damage to the player.
    case attack(Int)
    /// Gain `shield` for the enemy this turn.
    case brace(shield: Int)
    /// Apply a self-buff instead of acting on the player.
    case buff(EnemyBuff)
}

/// Persistent enemy self-buffs a move can apply. Machine-readable with
/// tuning values, mirroring `PassiveKind` — new behaviors are data, not code.
nonisolated enum EnemyBuff: Codable, Hashable, Sendable {
    /// All future attacks deal `amount` extra damage.
    case enrage(amount: Int)
    /// The next attack only deals `multiplier`× damage (wind-up telegraph).
    case windUp(multiplier: Int)
}

/// Machine-readable attack behavior. The engine interprets the pattern each
/// turn to produce the next `EnemyMove`; authoring new enemies means writing
/// data, not branching code.
nonisolated enum AttackPattern: Codable, Hashable, Sendable {
    /// Current MVP behavior: a random attack in `range`, replaced by a
    /// `heavyDamage` blow every `heavyEvery` turns. A literal port of the
    /// existing `intent(forTurn:)` constants so minions play as they do now.
    case skirmish(range: ClosedRange<Int>, heavyEvery: Int, heavyDamage: Int)

    /// A fixed cycle of moves, repeated (`turn % cycle.count`). Good for
    /// elites with a readable rhythm.
    case scripted(cycle: [EnemyMove])

    /// Boss behavior: the active phase is the first whose
    /// `healthThreshold` is at or above current health fraction, so the
    /// fight escalates as the boss is worn down.
    case phased(phases: [EnemyPhase])
}

/// One health-gated stage of a boss fight.
nonisolated struct EnemyPhase: Codable, Hashable, Sendable {
    /// Active while `currentHealth / maxHealth <= healthThreshold`.
    /// Phases are evaluated high-to-low; e.g. `[1.0, 0.5]` means the second
    /// phase engages at 50% health.
    let healthThreshold: Double
    let cycle: [EnemyMove]
}

/// Static enemy definition (content, not runtime state) — the enemy-side
/// parallel to `Hero`. Runtime health/shield still live in `CombatantState`
/// (or the mockup `EnemyMember`); this only supplies identity and stats.
nonisolated struct Enemy: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let tier: EnemyTier
    let maxHealth: Int
    let pattern: AttackPattern

    /// SF Symbol used in compact UI.
    let iconName: String
    /// Bundled storybook portrait asset name.
    let artName: String
    /// Bundled full-body battlefield illustration asset name.
    let fullBodyArtName: String

    /// Bosses may carry a passive using the same system as heroes; `nil`
    /// for enemies with no always-on rule.
    let passive: PassiveAbility?
}
