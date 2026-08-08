import Foundation

/// Runtime battle state for one side (player or enemy).
///
/// Symmetric by design: the enemy runs the same lucidity/deck rules as the
/// player, which keeps the engine simple and leaves the door open for PvP.
nonisolated struct CombatantState: Codable, Hashable, Sendable {
    /// Which static `Hero` definition this combatant is playing.
    let heroID: Hero.ID

    var currentHealth: Int

    /// Temporary shield absorbed before health; cleared per engine rules.
    var shield: Int

    /// Position on the 0–100 Lucidity spectrum. Starts at 50 (Balanced).
    var lucidity: Int

    /// Card zones, ordered. `deck.last` is the top card to draw next.
    /// Zones hold `CardInstance`s so duplicate copies of the same card
    /// keep stable identity for selection and animation.
    var hand: [CardInstance]
    var deck: [CardInstance]
    var discardPile: [CardInstance]

    /// Current zone derived from `lucidity` — never stored, so it can't
    /// drift out of sync with the meter.
    var zone: LucidityZone {
        LucidityZone.zone(for: lucidity)
    }

    var hasLostByLucidity: Bool {
        zone.isLoseCondition
    }

    var isDefeated: Bool {
        currentHealth <= 0
    }
}
