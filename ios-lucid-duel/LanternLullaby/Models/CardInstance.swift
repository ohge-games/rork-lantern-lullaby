import Foundation

/// A physical copy of a card inside a deck, hand, or discard pile.
///
/// Decks legally contain duplicates of the same `Card` definition, but
/// SwiftUI animations and selection need *stable per-copy identity* —
/// two copies of "Strike" must be distinguishable. Each copy therefore
/// gets its own instance `id` while sharing the definition via `cardID`.
nonisolated struct CardInstance: Codable, Identifiable, Hashable, Sendable {
    let id: UUID

    /// The static `Card` definition this copy refers to.
    let cardID: Card.ID

    init(id: UUID = UUID(), cardID: Card.ID) {
        self.id = id
        self.cardID = cardID
    }
}
