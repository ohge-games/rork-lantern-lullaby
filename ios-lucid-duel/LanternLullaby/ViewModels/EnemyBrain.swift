import Foundation

/// Interprets an enemy's authored `AttackPattern` one turn at a time.
///
/// The brain plans a move at the start of the player's turn (so the intent
/// chip shows exactly what will happen), then executes that same move on the
/// enemy's turn. Buffs are stateful: `enrage` raises every later attack,
/// `windUp` multiplies only the next one.
///
/// Two copies of the same enemy in one wave are offset by their `slot`, so
/// a pair of skirmishers never lands its heavy blow on the same turn and
/// three sprites do not brace in lockstep. That gives every figure on the
/// field a different intent, which is what makes choosing a target a choice.
nonisolated struct EnemyBrain: Hashable, Sendable {
    let pattern: AttackPattern

    /// Which position in the wave this enemy holds; offsets its rhythm.
    let slot: Int

    /// How many moves this enemy has taken; drives scripted cycles.
    private(set) var actionsTaken: Int = 0

    /// Permanent bonus damage accumulated from `.enrage` buffs.
    private(set) var enrage: Int = 0

    /// Multiplier applied to the next attack only (from `.windUp`).
    private(set) var pendingMultiplier: Int = 1

    /// The move planned for the coming enemy turn (before buffs are applied).
    private(set) var plannedMove: EnemyMove

    init(pattern: AttackPattern, turn: Int, healthFraction: Double, slot: Int = 0) {
        self.pattern = pattern
        self.slot = slot
        self.actionsTaken = slot
        self.plannedMove = Self.rawMove(
            for: pattern, actionsTaken: slot, turn: turn, slot: slot, healthFraction: healthFraction
        )
    }

    /// Re-plans for a new turn. Skirmish patterns roll their damage here, so
    /// the telegraphed number is the number that lands.
    mutating func plan(turn: Int, healthFraction: Double) {
        plannedMove = Self.rawMove(
            for: pattern, actionsTaken: actionsTaken, turn: turn, slot: slot, healthFraction: healthFraction
        )
    }

    /// What the intent chip should show for the planned move, buffs included.
    var intent: EnemyIntent {
        Self.intent(for: plannedMove, enrage: enrage, multiplier: pendingMultiplier)
    }

    /// What this enemy will do the turn *after* the planned one, when that
    /// is knowable. Scripted and phased patterns march through a fixed
    /// cycle, so they can always be read one step further; a skirmisher's
    /// ordinary swing is a dice roll, and only its telegraphed heavy blow
    /// can be seen coming.
    func previewNextIntent(turn: Int, healthFraction: Double) -> EnemyIntent? {
        // Buffs land before the following move, so fold them in.
        var lookaheadEnrage = enrage
        var lookaheadMultiplier = pendingMultiplier
        if case .buff(let buff) = plannedMove {
            switch buff {
            case .enrage(let amount): lookaheadEnrage += amount
            case .windUp(let multiplier): lookaheadMultiplier = max(1, multiplier)
            }
        } else if case .attack = plannedMove {
            lookaheadMultiplier = 1
        }

        switch pattern {
        case .skirmish(_, let heavyEvery, let heavyDamage):
            guard heavyEvery > 0, (turn + 1 + slot) % heavyEvery == 0 else { return nil }
            return .attack(Self.resolvedDamage(heavyDamage, enrage: lookaheadEnrage, multiplier: lookaheadMultiplier))
        case .scripted, .phased:
            let move = Self.rawMove(
                for: pattern,
                actionsTaken: actionsTaken + 1,
                turn: turn + 1,
                slot: slot,
                healthFraction: healthFraction
            )
            return Self.intent(for: move, enrage: lookaheadEnrage, multiplier: lookaheadMultiplier)
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
        case .brace, .lucidityPush:
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

    /// Blows out whatever this enemy has been building: the wind-up and the
    /// enrage are gone, and the planned move is re-read without them.
    mutating func calm() {
        pendingMultiplier = 1
        enrage = 0
    }

    static func label(for buff: EnemyBuff) -> String {
        switch buff {
        case .enrage(let amount): return "Enrage +\(amount)"
        case .windUp(let multiplier): return "Wind-up ×\(multiplier)"
        }
    }

    private static func intent(for move: EnemyMove, enrage: Int, multiplier: Int) -> EnemyIntent {
        switch move {
        case .attack(let base):
            return .attack(resolvedDamage(base, enrage: enrage, multiplier: multiplier))
        case .brace(let shield):
            return .brace(shield)
        case .buff(let buff):
            return .buff(label(for: buff))
        case .lucidityPush(let amount):
            return .push(amount)
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
        slot: Int,
        healthFraction: Double
    ) -> EnemyMove {
        switch pattern {
        case .skirmish(let range, let heavyEvery, let heavyDamage):
            if heavyEvery > 0, (turn + slot) % heavyEvery == 0 {
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
