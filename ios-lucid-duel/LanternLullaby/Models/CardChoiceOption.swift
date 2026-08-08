import Foundation

/// One branch of a dual-direction card ("Choose: Concentrate OR Relax").
///
/// A card that carries `choices` resolves its base effects first, then the
/// effects of exactly one chosen option. The lucidity movement of a branch
/// is expressed as a `lucidityModify` effect inside the branch, so the same
/// resolution pipeline handles it — no special cases.
nonisolated struct CardChoiceOption: Codable, Identifiable, Hashable, Sendable {
    /// Stable key ("concentrate", "relax") — content ID, not a per-copy ID.
    let id: String

    let name: String

    /// Short rules text shown on the choice button.
    let text: String

    /// SF Symbol name shown next to the choice.
    let iconName: String

    /// Effects resolve in array order after the card's base effects.
    let effects: [Effect]
}
