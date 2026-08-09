import Foundation

/// The enemies that fill a single battle's slots.
///
/// The `primary` enemy mirrors live engine state (it decides the duel); the
/// `support` enemies fill the remaining top-row slots — matching today's
/// primary/support split in `EnemyMember`.
nonisolated struct Encounter: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let primaryEnemyID: Enemy.ID
    let supportEnemyIDs: [Enemy.ID]
}

/// One battle node within a chapter.
nonisolated struct Stage: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    /// Order within the parent chapter, starting at 0.
    let index: Int
    let name: String
    let encounter: Encounter
    /// Convenience flag for UI/rewards; the boss is also derivable from the
    /// primary enemy's `tier`.
    let isBoss: Bool
}

/// An ordered group of stages, typically ending in a boss.
nonisolated struct Chapter: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    /// Order within the campaign, starting at 0.
    let index: Int
    let title: String
    let stages: [Stage]
}

/// The player's campaign save data. Deliberately separate from `GameState`,
/// which stays battle-scoped: a coordinator reads the selected `Stage`,
/// builds a `GameState` via `newGame`, and writes progress back here on
/// victory. Nothing here contradicts a battle snapshot.
nonisolated struct CampaignProgress: Codable, Sendable {
    var selectedHeroID: Hero.ID
    var currentChapterID: Chapter.ID
    var currentStageID: Stage.ID
    var clearedStageIDs: Set<Stage.ID>

    /// A stage is playable if it's the first in its chapter or the previous
    /// stage in that chapter has been cleared.
    func isUnlocked(_ stage: Stage, in chapter: Chapter) -> Bool {
        if stage.index == 0 { return true }
        guard let previous = chapter.stages.first(where: { $0.index == stage.index - 1 })
        else { return false }
        return clearedStageIDs.contains(previous.id)
    }

    /// Marks a stage cleared and advances the cursor to the next stage in the
    /// chapter, if any.
    mutating func markCleared(_ stage: Stage, in chapter: Chapter) {
        clearedStageIDs.insert(stage.id)
        if let next = chapter.stages.first(where: { $0.index == stage.index + 1 }) {
            currentStageID = next.id
        }
    }
}
