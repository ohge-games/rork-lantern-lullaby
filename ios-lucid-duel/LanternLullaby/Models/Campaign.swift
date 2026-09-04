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

/// A single wave within a multi-stage battle.
/// Each wave has its own encounter and optional narrative beats.
nonisolated struct BattleWave: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let encounter: Encounter

    /// Narrative text shown before this wave begins.
    /// Example: "More wolves emerge from the shadows..."
    let introText: String?

    /// Narrative text shown after clearing this wave (before next wave or victory).
    /// Example: "The pack leader howls — reinforcements are coming!"
    let outroText: String?

    /// A hero who rides in when this wave starts and fights beside the
    /// party for the rest of the battle. Used where the story says help
    /// arrives — Lancelot at Chapter 1 Stage 5, Kay at Stage 8 — so the
    /// promised ally is actually on the field.
    let allyReinforcementID: Hero.ID?

    init(
        id: UUID,
        encounter: Encounter,
        introText: String?,
        outroText: String?,
        allyReinforcementID: Hero.ID? = nil
    ) {
        self.id = id
        self.encounter = encounter
        self.introText = introText
        self.outroText = outroText
        self.allyReinforcementID = allyReinforcementID
    }
}

/// A complete battle consisting of 1-3 waves with narrative flow.
nonisolated struct MultistageBattle: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let waves: [BattleWave]

    /// Text shown at the very start of the battle.
    let openingNarrative: String?

    /// Text shown after all waves are cleared.
    let victoryNarrative: String?

    /// Optional hero-specific dialogue triggered by party composition.
    /// Key: heroID, Value: dialogue line when that hero is in party.
    let heroDialogue: [UUID: String]?

    var waveCount: Int { waves.count }
    var isBossBattle: Bool { waves.count >= 2 }
}

/// One battle node within a chapter.
nonisolated struct Stage: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    /// Order within the parent chapter, starting at 0.
    let index: Int
    let name: String

    /// Legacy single-encounter for simple battles.
    let encounter: Encounter?

    /// Multi-stage battle with narrative (preferred for story content).
    let battle: MultistageBattle?

    /// Convenience flag for UI/rewards; the boss is also derivable from the
    /// primary enemy's `tier`.
    let isBoss: Bool

    /// Returns the primary enemy ID for this stage (from either format).
    var primaryEnemyID: Enemy.ID? {
        if let battle = battle {
            return battle.waves.first?.encounter.primaryEnemyID
        }
        return encounter?.primaryEnemyID
    }
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
    /// Chapters whose waking-world interlude has already been read, so it
    /// plays once and is afterwards only in the journal.
    var seenInterludeChapters: Set<Int>

    init(
        selectedHeroIDs: [Hero.ID],
        currentChapterID: Chapter.ID,
        currentStageID: Stage.ID,
        clearedStageIDs: Set<Stage.ID>,
        unlockedHeroIDs: Set<Hero.ID>,
        seenInterludeChapters: Set<Int> = []
    ) {
        self.selectedHeroIDs = selectedHeroIDs
        self.currentChapterID = currentChapterID
        self.currentStageID = currentStageID
        self.clearedStageIDs = clearedStageIDs
        self.unlockedHeroIDs = unlockedHeroIDs
        self.seenInterludeChapters = seenInterludeChapters
    }

    /// Decoded field by field with defaults, so adding a field to this
    /// struct never throws away a player's book: a save written by an
    /// older build simply lacks the fields it never had.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedHeroIDs = try container.decodeIfPresent([Hero.ID].self, forKey: .selectedHeroIDs) ?? []
        currentChapterID = try container.decodeIfPresent(Chapter.ID.self, forKey: .currentChapterID) ?? UUID()
        currentStageID = try container.decodeIfPresent(Stage.ID.self, forKey: .currentStageID) ?? UUID()
        clearedStageIDs = try container.decodeIfPresent(Set<Stage.ID>.self, forKey: .clearedStageIDs) ?? []
        unlockedHeroIDs = try container.decodeIfPresent(Set<Hero.ID>.self, forKey: .unlockedHeroIDs) ?? []
        seenInterludeChapters = try container.decodeIfPresent(Set<Int>.self, forKey: .seenInterludeChapters) ?? []
    }

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
nonisolated enum HeroUnlocks {
    /// Returns hero IDs that unlock when clearing the specified stage.
    /// Chapter and stage indices are 0-based.
    static func heroesUnlockedAt(chapter: Int, stage: Int) -> [Hero.ID] {
        switch (chapter, stage) {
        // Chapter 1: The Sword in the Stone
        case (0, 4):  // Ch1-S5 (index 4)
            return [CardCatalog.HeroIDs.lancelot]
        case (0, 7):  // Ch1-S8 (index 7)
            return [CardCatalog.HeroIDs.kay]

        // Chapter 2: The Queen of Air and Darkness
        case (1, 2):  // Ch2-S3 (index 2)
            return [CardCatalog.HeroIDs.bedivere]
        case (1, 7):  // Ch2-S8 (index 7)
            return [CardCatalog.HeroIDs.morgana]

        // Chapter 3: The Ill-Made Knight
        case (2, 4):  // Ch3-S5 (index 4)
            return [CardCatalog.HeroIDs.escanor]
        case (2, 7):  // Ch3-S8 (index 7)
            return [CardCatalog.HeroIDs.galahad]

        // Chapter 4: The Candle in the Wind
        case (3, 0):  // Ch4-S1 (index 0) - Merlin joins at chapter start
            return [CardCatalog.HeroIDs.merlin]

        default:
            return []
        }
    }

    /// Starting heroes available before any progression.
    static var starterHeroIDs: Set<Hero.ID> {
        [CardCatalog.StarterIDs.wart, CardCatalog.StarterIDs.archimedes]
    }
}
