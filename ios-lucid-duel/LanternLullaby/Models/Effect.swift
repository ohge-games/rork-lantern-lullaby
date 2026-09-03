import Foundation

/// Every mechanical thing a card can do when resolved.
nonisolated enum EffectType: String, Codable, CaseIterable, Sendable {
    /// Reduce target health (absorbed by shield first).
    case damage
    /// Restore health, capped at the hero's `maxHealth`.
    case heal
    /// Add temporary shield that absorbs damage before health.
    case shield
    /// Shift the caster's lucidity meter. Negative value = Relax effect.
    case lucidityModify
    /// Move the caster's lucidity toward 50 (Balanced) by up to `value`,
    /// never overshooting the center. Direction depends on current meter.
    case lucidityCenter
    /// Draw cards from deck into hand.
    case drawCards
    /// The targeted ally steps to the front of the party and leads.
    case swapLead
}

/// A single atomic card effect: what happens and by how much.
///
/// A `Card` carries an *array* of effects so hybrid cards ("deal 4 damage,
/// then reduce Lucidity by 3") are one card, not a special case.
nonisolated struct Effect: Codable, Hashable, Sendable {
    let type: EffectType

    /// Magnitude of the effect. For `lucidityModify` a negative value
    /// lowers the meter (Relax) and a positive value raises it.
    let value: Int

    /// The effect's value after zone bonuses are applied.
    ///
    /// - Vivid zone: offensive cards get +20% effect. It is the only zone
    ///   that scales anything; Drifting pays out in cost and draw instead.
    /// - `lucidityModify` and `drawCards` are never scaled — scaling meter
    ///   movement or draw counts would make zone bonuses self-referential.
    func resolvedValue(cardType: CardType, zone: LucidityZone) -> Int {
        switch type {
        case .lucidityModify, .lucidityCenter, .drawCards, .swapLead:
            return value
        case .damage, .heal, .shield:
            let multiplier: Double
            switch cardType {
            case .offensive: multiplier = zone.offensiveMultiplier
            case .defensive, .utility: multiplier = 1.0
            }
            return Int((Double(value) * multiplier).rounded())
        }
    }
}
