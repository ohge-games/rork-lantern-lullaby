import Foundation

/// A hero slot on the player's team row.
///
/// The Dreamer slot mirrors live engine state; teammates keep local health
/// so switching and taking hits feel real until per-hero decks land.
nonisolated struct AllyMember: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let iconName: String
    /// Bundled storybook portrait asset name.
    let artName: String
    /// Bundled full-body battlefield illustration asset name.
    let fullBodyArtName: String
    var health: Int
    let maxHealth: Int
    var shield: Int
    let passiveName: String
    let passiveText: String
    var isActive: Bool
}
