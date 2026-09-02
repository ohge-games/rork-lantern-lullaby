import Foundation

/// Interprets an enemy's authored `AttackPattern` one turn at a time.
///
/// The brain plans a move at the start of the player's turn (so the intent
/// chip shows exactly what will happen), then executes that same move on the
/// enemy's turn. Buffs are stateful: `enrage` raises every later attack,
/// `windUp` multiplies only the next one.
nonisolated struct EnemyBrain: Hashable, Sendable {
    let pattern: AttackPattern

    /// How many moves this enemy has taken; drives scripted cycles.
    private(set) var actionsTaken: Int = 0

    /// Permanent bonus damage accumulated from `.enrage` buffs.
    private(set) var enrage: Int = 0

    /// Multiplier applied to the next attack only (from `.windUp`).
    private(set) var pendingMultiplier: Int = 1

    /// The move planned for the coming enemy turn (before buffs are applied).
    private(set) var plannedMove: EnemyMove

    init(pattern: AttackPattern, turn: Int, healthFraction: Double) {
        self.pattern = pattern
        self.plannedMove = Self.rawMove(
            for: pattern, actionsTaken: 0, turn: turn, healthFraction: healthFraction
        )
    }

    /// Re-plans for a new turn. Skirmish patterns roll their damage here, so
    /// the telegraphed number is the number that lands.
    mutating func plan(turn: Int, healthFraction: Double) {
        plannedMove = Self.rawMove(
            for: pattern, actionsTaken: actionsTaken, turn: turn, healthFraction: healthFraction
        )
    }

    /// What the intent chip should show for the planned move, buffs included.
    var intent: EnemyIntent {
        switch plannedMove {
        case .attack(let base):
            return .attack(Self.resolvedDamage(base, enrage: enrage, multiplier: pendingMultiplier))
        case .brace(let shield):
            return .brace(shield)
        case .buff(let buff):
            return .buff(Self.label(for: buff))
        }
    }

    /// Consumes the planned move and returns the resolved move to execute.
    /// Attack damage comes back with enrage and wind-up already applied.
    mutating func execute() -> EnemyMove {
        let move = plannedMove
        actionsTaken += 1
        switch move {
        case .attack(let base):
            let amount = Self.resolvedDamage(base, enrage: enrage, multiplier: pendingMultiplier)
            pendingMultiplier = 1
            return .attack(amount)
        case .brace:
            return move
        case .buff(let buff):
            switch buff {
            case .enrage(let amount):
                enrage += amount
            case .windUp(let multiplier):
                pendingMultiplier = max(1, multiplier)
            }
            return move
        }
    }

    static func label(for buff: EnemyBuff) -> String {
        switch buff {
        case .enrage(let amount): return "Enrage +\(amount)"
        case .windUp(let multiplier): return "Wind-up ×\(multiplier)"
        }
    }

    private static func resolvedDamage(_ base: Int, enrage: Int, multiplier: Int) -> Int {
        max(0, (base + enrage) * max(1, multiplier))
    }

    /// The unbuffed move a pattern produces for this point in the fight.
    private static func rawMove(
        for pattern: AttackPattern,
        actionsTaken: Int,
        turn: Int,
        healthFraction: Double
    ) -> EnemyMove {
        switch pattern {
        case .skirmish(let range, let heavyEvery, let heavyDamage):
            if heavyEvery > 0, turn % heavyEvery == 0 {
                return .attack(heavyDamage)
            }
            return .attack(Int.random(in: range))

        case .scripted(let cycle):
            guard !cycle.isEmpty else { return .attack(0) }
            return cycle[actionsTaken % cycle.count]

        case .phased(let phases):
            // The active phase is the lowest threshold the boss has fallen
            // to; e.g. thresholds [1.0, 0.5] switch to phase two at 50%.
            let eligible = phases.filter { healthFraction <= $0.healthThreshold }
            let active = eligible.min { $0.healthThreshold < $1.healthThreshold } ?? phases.first
            guard let active, !active.cycle.isEmpty else { return .attack(0) }
            return active.cycle[actionsTaken % active.cycle.count]
        }
    }
}
