import Foundation

/// An enemy slot on the top row.
///
/// Layout-mockup type: the primary slot mirrors live engine state (it
/// decides the duel), while support enemies keep local placeholder health
/// so targeting them still feels real.
nonisolated struct EnemyMember: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let iconName: String
    /// Bundled storybook portrait asset name.
    let artName: String
    /// Bundled full-body battlefield illustration asset name.
    let fullBodyArtName: String
    let maxHealth: Int
    var health: Int
    var shield: Int
    var intent: EnemyIntent
    /// The move after next, shown only while the player is Drifting and
    /// only when the pattern makes it knowable.
    var nextIntent: EnemyIntent?
    let isPrimary: Bool
}
