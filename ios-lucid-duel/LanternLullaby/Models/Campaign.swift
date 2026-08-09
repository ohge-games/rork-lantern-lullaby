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
    var selectedHeroIDs: [Hero.ID]  // The 3-hero party
    var currentChapterID: Chapter.ID
    var currentStageID: Stage.ID
    var clearedStageIDs: Set<Stage.ID>
    var unlockedHeroIDs: Set<Hero.ID>  // Heroes unlocked through progression

    /// A stage is playable if it's the first in its chapter or the previous
    /// stage in that chapter has been cleared.
    func isUnlocked(_ stage: Stage, in chapter: Chapter) -> Bool {
        if stage.index == 0 { return true }
        guard let previous = chapter.stages.first(where: { $0.index == stage.index - 1 })
        else { return false }
        return clearedStageIDs.contains(previous.id)
    }
    
    /// Returns true if a hero is available for selection.
    func isHeroUnlocked(_ heroID: Hero.ID) -> Bool {
        unlockedHeroIDs.contains(heroID)
    }

    /// Marks a stage cleared, unlocks any heroes tied to this stage,
    /// and advances the cursor to the next stage in the chapter.
    mutating func markCleared(_ stage: Stage, in chapter: Chapter) {
        clearedStageIDs.insert(stage.id)
        
        // Check for hero unlocks at this stage
        let newHeroes = HeroUnlocks.heroesUnlockedAt(chapter: chapter.index, stage: stage.index)
        for heroID in newHeroes {
            unlockedHeroIDs.insert(heroID)
        }
        
        if let next = chapter.stages.first(where: { $0.index == stage.index + 1 }) {
            currentStageID = next.id
        }
    }
}

/// Defines which heroes unlock at which campaign milestones.
enum HeroUnlocks {
    /// Returns hero IDs that unlock when clearing the specified stage.
    /// Chapter and stage indices are 0-based.
    static func heroesUnlockedAt(chapter: Int, stage: Int) -> [Hero.ID] {
        switch (chapter, stage) {
        // Chapter 1: The Sword in the Stone
        case (0, 4):  // Ch1-S5 (index 4)
            return [CardCatalogHeroes.HeroIDs.lancelot]
        case (0, 7):  // Ch1-S8 (index 7)
            return [CardCatalogHeroes.HeroIDs.kay]
            
        // Chapter 2: The Queen of Air and Darkness
        case (1, 2):  // Ch2-S3 (index 2)
            return [CardCatalogHeroes.HeroIDs.bedivere]
        case (1, 7):  // Ch2-S8 (index 7)
            return [CardCatalogHeroes.HeroIDs.morgana]
            
        // Chapter 3: The Ill-Made Knight
        case (2, 4):  // Ch3-S5 (index 4)
            return [CardCatalogHeroes.HeroIDs.escanor]
        case (2, 7):  // Ch3-S8 (index 7)
            return [CardCatalogHeroes.HeroIDs.galahad]
            
        // Chapter 4: The Candle in the Wind
        case (3, 0):  // Ch4-S1 (index 0) - Merlin joins at chapter start
            return [CardCatalogHeroes.HeroIDs.merlin]
            
        default:
            return []
        }
    }
    
    /// Starting heroes available before any progression.
    static var starterHeroIDs: Set<Hero.ID> {
        [CardCatalog.dreamer.id]  // Wart + Archimedes handled as starters
    }
}
