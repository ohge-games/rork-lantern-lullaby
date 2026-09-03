import Foundation

/// The five zones of the 0–100 Lucidity spectrum.
///
/// Lucidity is the core resource-inversion mechanic: playing cards *raises*
/// the meter instead of spending a resource. Both extremes are lose
/// conditions, so the player constantly balances aggression (pushing up)
/// against Relax effects (pulling down).
nonisolated enum LucidityZone: String, Codable, CaseIterable, Sendable {
    case deepSleep
    case drifting
    case balanced
    case vivid
    case awakening

    /// Inclusive lucidity range covered by this zone.
    var range: ClosedRange<Int> {
        switch self {
        case .deepSleep: return 0...15
        case .drifting: return 16...35
        case .balanced: return 36...65
        case .vivid: return 66...85
        case .awakening: return 86...100
        }
    }

    /// Resolves the zone for a lucidity value (clamped to 0–100).
    static func zone(for lucidity: Int) -> LucidityZone {
        let clamped = min(max(lucidity, 0), 100)
        return LucidityZone.allCases.first { $0.range.contains(clamped) } ?? .balanced
    }

    /// Entering this zone immediately ends the game as a loss.
    var isLoseCondition: Bool {
        self == .deepSleep || self == .awakening
    }

    /// Multiplier applied to offensive card effects while in this zone.
    ///
    /// Vivid is the *power* zone: a sharp dream hits harder. Drifting is
    /// the *tempo* zone and scales nothing — instead it makes cards cheaper
    /// and hands bigger (see `GameRules.driftingCostReduction` and
    /// `driftingBonusDraw`), so the two ends of the meter offer genuinely
    /// different plans rather than the same bonus pointed two ways.
    var offensiveMultiplier: Double {
        self == .vivid ? 1.2 : 1.0
    }

    /// True while the dream is loose enough to shape: cards cost less, the
    /// hand runs deeper, and enemies telegraph one move further ahead.
    var isDrifting: Bool {
        self == .drifting
    }

    var displayName: String {
        switch self {
        case .deepSleep: return "Deep Sleep"
        case .drifting: return "Drifting"
        case .balanced: return "Balanced"
        case .vivid: return "Vivid"
        case .awakening: return "Awakening"
        }
    }
}
