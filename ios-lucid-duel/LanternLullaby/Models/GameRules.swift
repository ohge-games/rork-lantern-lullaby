import Foundation

/// Central tuning knobs for the battle engine. One place to balance from.
nonisolated enum GameRules {
    /// Both combatants start at the center of the Balanced zone.
    static let startingLucidity: Int = 50

    static let lucidityMin: Int = 0
    static let lucidityMax: Int = 100

    static let startingHandSize: Int = 7
    static let cardsDrawnPerTurn: Int = 1
    static let maxHandSize: Int = 10

    /// After the turn's draw, the hand is topped up to at least this many
    /// cards so a thin hand never leaves the player with nothing to do
    /// while the enemy keeps swinging. Draw passives raise it.
    static let minimumHandSize: Int = 4

    /// Focus Strain: leaning on one kind of card wears the dream thin.
    /// Each card of a type already played this turn adds this much to the
    /// next one's Lucidity cost, so the second attack in a turn costs +1,
    /// the third +2, and so on. Attacks, defense and utility strain
    /// separately, which makes a varied turn cheaper than a mono turn and
    /// puts a soft ceiling on burst without hiding damage numbers.
    static let focusStrainPerRepeat: Int = 1

    /// Normal enemy attacks roll within this range each turn.
    static let enemyAttackRange: ClosedRange<Int> = 8...15

    /// Every `enemyHeavyTurnInterval`th turn the enemy lands a heavy blow.
    static let enemyHeavyAttackDamage: Int = 20
    static let enemyHeavyTurnInterval: Int = 3

    /// Clamps a lucidity value onto the meter. The game-over check reads
    /// the clamped value, so overshooting past 0 or 100 still lands in a
    /// lose-condition zone rather than escaping the spectrum.
    static func clampLucidity(_ value: Int) -> Int {
        min(max(value, lucidityMin), lucidityMax)
    }
}
