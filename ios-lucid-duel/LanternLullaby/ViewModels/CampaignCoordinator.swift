import Foundation
import Observation

/// Owns campaign progress and turns a chosen stage into a battle.
///
/// This is the seam between the pure campaign data (`Chapter`, `Stage`,
/// `CampaignProgress`) and the battle engine: it reads the selected stage,
/// assembles a `BattleConfiguration` and the stage's narrative, hands the
/// player a `BattleViewModel`, and writes progress back on victory.
/// Progress persists in `UserDefaults` as JSON.
@Observable
final class CampaignCoordinator {
    private(set) var progress: CampaignProgress

    /// Book 1 in chapter order.
    let chapters: [Chapter] = CampaignCatalogBook1.allChapters

    /// The chapter the campaign page is showing.
    var selectedChapterIndex: Int

    /// The stage the player has picked on the campaign page.
    var selectedStageID: Stage.ID?

    /// Whether the bookshop prologue has been read.
    private(set) var hasSeenPrologue: Bool

    /// Heroes unlocked by the most recent victory, for the "joins your
    /// party" banner. Cleared when acknowledged.
    private(set) var recentlyUnlockedHeroes: [Hero] = []

    /// Maximum party size.
    static let partySize = 3

    private static let progressKey = "LanternLullaby.CampaignProgress.v1"
    private static let prologueKey = "LanternLullaby.HasSeenPrologue.v1"

    init() {
        let loaded = Self.loadProgress()
        progress = loaded ?? Self.freshProgress()
        hasSeenPrologue = UserDefaults.standard.bool(forKey: Self.prologueKey)
        selectedChapterIndex = 0
        selectedStageID = nil

        if let chapter = chapters.first(where: { $0.id == progress.currentChapterID }) {
            selectedChapterIndex = chapter.index
        }
        selectedStageID = progress.currentStageID
        sanitizeParty()
    }

    // MARK: - Progress shape

    private static func freshProgress() -> CampaignProgress {
        let chapters = CampaignCatalogBook1.allChapters
        let firstChapter = chapters[0]
        let firstStage = firstChapter.stages[0]
        let starters = HeroUnlocks.starterHeroIDs
        return CampaignProgress(
            selectedHeroIDs: [CardCatalog.StarterIDs.wart, CardCatalog.StarterIDs.archimedes],
            currentChapterID: firstChapter.id,
            currentStageID: firstStage.id,
            clearedStageIDs: [],
            unlockedHeroIDs: starters
        )
    }

    private static func loadProgress() -> CampaignProgress? {
        guard let data = UserDefaults.standard.data(forKey: progressKey) else { return nil }
        do {
            return try JSONDecoder().decode(CampaignProgress.self, from: data)
        } catch {
            // Keep the unreadable save rather than starting a fresh book
            // over the top of it — it is the only copy the player has.
            UserDefaults.standard.set(data, forKey: progressKey + ".corrupt")
            return nil
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: Self.progressKey)
        }
    }

    /// Wipes progress back to a fresh book.
    func resetProgress() {
        progress = Self.freshProgress()
        hasSeenPrologue = false
        UserDefaults.standard.removeObject(forKey: Self.prologueKey)
        DialogueManager.clearPersistedKeys()
        selectedChapterIndex = 0
        selectedStageID = progress.currentStageID
        recentlyUnlockedHeroes = []
        save()
    }

    func markPrologueSeen() {
        hasSeenPrologue = true
        UserDefaults.standard.set(true, forKey: Self.prologueKey)
    }

    func acknowledgeUnlocks() {
        recentlyUnlockedHeroes = []
    }

    // MARK: - Chapters and stages

    var selectedChapter: Chapter {
        chapters[min(max(0, selectedChapterIndex), chapters.count - 1)]
    }

    var selectedStage: Stage? {
        guard let id = selectedStageID else { return nil }
        return stage(withID: id)
    }

    /// The stage the campaign cursor points at (the next one to play).
    var currentStage: Stage? {
        stage(withID: progress.currentStageID)
    }

    func stage(withID id: Stage.ID) -> Stage? {
        for chapter in chapters {
            if let stage = chapter.stages.first(where: { $0.id == id }) { return stage }
        }
        return nil
    }

    func chapter(containing stage: Stage) -> Chapter? {
        chapters.first { chapter in chapter.stages.contains { $0.id == stage.id } }
    }

    /// A chapter opens once the previous chapter's boss is cleared.
    func isChapterUnlocked(_ chapter: Chapter) -> Bool {
        guard chapter.index > 0 else { return true }
        guard let previous = chapters.first(where: { $0.index == chapter.index - 1 }),
              let boss = previous.stages.last else { return false }
        return progress.clearedStageIDs.contains(boss.id)
    }

    func isStageUnlocked(_ stage: Stage, in chapter: Chapter) -> Bool {
        isChapterUnlocked(chapter) && progress.isUnlocked(stage, in: chapter)
    }

    func isStageCleared(_ stage: Stage) -> Bool {
        progress.clearedStageIDs.contains(stage.id)
    }

    func clearedCount(in chapter: Chapter) -> Int {
        chapter.stages.filter { progress.clearedStageIDs.contains($0.id) }.count
    }

    /// Everything the stage will throw at the party, in wave order.
    func enemies(for stage: Stage) -> [[Enemy]] {
        waveSpecs(for: stage).map(\.enemies)
    }

    // MARK: - Party

    var unlockedHeroes: [Hero] {
        CardCatalog.playableHeroes.filter { progress.unlockedHeroIDs.contains($0.id) }
    }

    var party: [Hero] {
        progress.selectedHeroIDs.compactMap { id in
            CardCatalog.playableHeroes.first { $0.id == id }
        }
    }

    func isInParty(_ hero: Hero) -> Bool {
        progress.selectedHeroIDs.contains(hero.id)
    }

    /// Adds or removes a hero from the party. The party never empties and
    /// never exceeds `partySize`; both are silent no-ops.
    func toggleHero(_ hero: Hero) {
        guard progress.unlockedHeroIDs.contains(hero.id) else { return }
        if let index = progress.selectedHeroIDs.firstIndex(of: hero.id) {
            guard progress.selectedHeroIDs.count > 1 else { return }
            progress.selectedHeroIDs.remove(at: index)
        } else {
            guard progress.selectedHeroIDs.count < Self.partySize else { return }
            progress.selectedHeroIDs.append(hero.id)
        }
        save()
    }

    /// Moves a party member to the front so they lead the next battle.
    func makeLead(_ hero: Hero) {
        guard let index = progress.selectedHeroIDs.firstIndex(of: hero.id), index > 0 else { return }
        progress.selectedHeroIDs.remove(at: index)
        progress.selectedHeroIDs.insert(hero.id, at: 0)
        save()
    }

    /// Drops locked or unknown ids and guarantees at least one member.
    private func sanitizeParty() {
        let valid = progress.selectedHeroIDs.filter { id in
            progress.unlockedHeroIDs.contains(id) && CardCatalog.playableHeroes.contains { $0.id == id }
        }
        var deduped: [Hero.ID] = []
        for id in valid where !deduped.contains(id) { deduped.append(id) }
        progress.selectedHeroIDs = Array(deduped.prefix(Self.partySize))
        if progress.selectedHeroIDs.isEmpty {
            progress.selectedHeroIDs = [CardCatalog.StarterIDs.wart]
            progress.unlockedHeroIDs.insert(CardCatalog.StarterIDs.wart)
        }
    }

    // MARK: - Building a battle

    private func waveSpecs(for stage: Stage) -> [WaveSpec] {
        if let battle = stage.battle {
            let specs: [WaveSpec] = battle.waves.compactMap { wave in
                let ids = [wave.encounter.primaryEnemyID] + wave.encounter.supportEnemyIDs
                let enemies = ids.compactMap { EnemyLookup.enemy(withID: $0) }
                guard !enemies.isEmpty else { return nil }
                // A guest hero already in the party would be a duplicate.
                let guest = wave.allyReinforcementID
                    .flatMap { id in CardCatalog.playableHeroes.first { $0.id == id } }
                    .flatMap { hero in party.contains(where: { $0.id == hero.id }) ? nil : hero }
                return WaveSpec(enemies: enemies, allyReinforcement: guest)
            }
            if !specs.isEmpty { return specs }
        }
        if let encounter = stage.encounter {
            let ids = [encounter.primaryEnemyID] + encounter.supportEnemyIDs
            let enemies = ids.compactMap { EnemyLookup.enemy(withID: $0) }
            if !enemies.isEmpty { return [WaveSpec(enemies: enemies)] }
        }
        return [WaveSpec(enemies: [EnemyCatalogBook1.forestWolf])]
    }

    func configuration(for stage: Stage, in chapter: Chapter) -> BattleConfiguration {
        let heroes = party.isEmpty ? [CardCatalog.wart] : party
        return BattleConfiguration(
            title: stage.name,
            party: heroes,
            waves: waveSpecs(for: stage),
            arenaArtName: ArtCatalog.arena(forChapterIndex: chapter.index),
            lanternDrift: 2,
            deckCardIDs: CardCatalog.partyDeckCardIDs(for: heroes),
            stageID: stage.id,
            chapterIndex: chapter.index,
            tutorial: Self.tutorial(forChapter: chapter.index, stage: stage.index)
        )
    }

    /// The authored stage narrative merged with the battle's own text:
    /// opening lines, hero remarks, wave intros/outros and the victory line.
    func narrative(for stage: Stage, in chapter: Chapter) -> StageNarrative {
        let base = NarrativeCatalogBook1.narrative(forChapter: chapter.index + 1, stage: stage.index + 1)
        var dialogues = base.battleDialogues

        if let battle = stage.battle {
            var opening: [DialogueLine] = []
            if let text = battle.openingNarrative {
                opening.append(.narrator(text))
            }
            for hero in party {
                if let line = battle.heroDialogue?[hero.id] {
                    opening.append(
                        .hero(hero.id, name: hero.name, portrait: ArtCatalog.heroPortrait(for: hero), text: line)
                    )
                }
            }
            if let intro = battle.waves.first?.introText {
                opening.append(.narrator(intro))
            }
            if !opening.isEmpty {
                dialogues.insert(BattleDialogue(trigger: .battleStart, lines: opening), at: 0)
            }

            for (index, wave) in battle.waves.enumerated() where index > 0 {
                var lines: [DialogueLine] = []
                if let outro = battle.waves[index - 1].outroText {
                    lines.append(.narrator(outro))
                }
                if let intro = wave.introText {
                    lines.append(.narrator(intro))
                }
                if !lines.isEmpty {
                    dialogues.append(BattleDialogue(trigger: .waveStart(waveIndex: index), lines: lines))
                }
            }

            if let victory = battle.victoryNarrative {
                dialogues.append(BattleDialogue(trigger: .battleEnd, lines: [.narrator(victory)]))
            }
        }

        return StageNarrative(
            preStageScene: base.preStageScene,
            postStageScene: base.postStageScene,
            battleDialogues: dialogues
        )
    }

    /// A ready-to-play engine for the stage, narrative attached. The caller
    /// still needs to call `startStage()` once the battle is on screen.
    func makeBattle(for stage: Stage) -> BattleViewModel {
        let chapter = self.chapter(containing: stage) ?? selectedChapter
        let viewModel = BattleViewModel(configuration: configuration(for: stage, in: chapter))
        viewModel.configureNarrative(narrative(for: stage, in: chapter), partyHeroIDs: party.map(\.id))
        return viewModel
    }

    /// The scripted lesson for a stage, if it has one. Chapter and stage
    /// are 0-based, so this is page 1 and page 6 of Chapter 1 — the second
    /// landing the turn after Lancelot joins the party.
    static func tutorial(forChapter chapter: Int, stage: Int) -> TutorialScript? {
        switch (chapter, stage) {
        case (0, 0): return .firstBattle
        case (0, 5): return .partyAndPassives
        default: return nil
        }
    }

    /// What the victory card should say about clearing this stage.
    ///
    /// Called before `recordVictory`, so the hero unlocks it names are the
    /// ones the win is about to grant.
    func victorySummary(for stage: Stage) -> VictorySummary? {
        guard let chapter = chapter(containing: stage) else { return nil }

        let next = chapter.stages.first { $0.index == stage.index + 1 }
        let nextChapter = next == nil
            ? chapters.first { $0.index == chapter.index + 1 }
            : nil

        let pendingIDs = HeroUnlocks
            .heroesUnlockedAt(chapter: chapter.index, stage: stage.index)
            .filter { !progress.unlockedHeroIDs.contains($0) }
        let heroes = CardCatalog.playableHeroes.filter { pendingIDs.contains($0.id) }

        return VictorySummary(
            stageName: stage.name,
            chapterTitle: chapter.title,
            pageNumber: stage.index + 1,
            pageCount: chapter.stages.count,
            nextStageName: next?.name,
            nextChapterTitle: nextChapter?.title,
            unlockedHeroes: heroes
        )
    }

    // MARK: - Recording results

    /// Marks the stage cleared, unlocks heroes, seats new heroes in an open
    /// party slot, and moves the cursor forward (into the next chapter when
    /// a boss falls).
    func recordVictory(stageID: Stage.ID) {
        guard let stage = stage(withID: stageID), let chapter = chapter(containing: stage) else { return }

        let unlockedBefore = progress.unlockedHeroIDs
        progress.markCleared(stage, in: chapter)

        let newIDs = progress.unlockedHeroIDs.subtracting(unlockedBefore)
        let newHeroes = CardCatalog.playableHeroes.filter { newIDs.contains($0.id) }
        recentlyUnlockedHeroes = newHeroes
        for hero in newHeroes where progress.selectedHeroIDs.count < Self.partySize {
            if !progress.selectedHeroIDs.contains(hero.id) {
                progress.selectedHeroIDs.append(hero.id)
            }
        }

        let isLastStage = chapter.stages.allSatisfy { $0.index <= stage.index }
        if isLastStage, let next = chapters.first(where: { $0.index == chapter.index + 1 }) {
            progress.currentChapterID = next.id
            progress.currentStageID = next.stages[0].id
            selectedChapterIndex = next.index
        } else {
            progress.currentChapterID = chapter.id
        }
        selectedStageID = progress.currentStageID
        save()
    }
}

/// Finds an enemy definition across every catalog.
enum EnemyLookup {
    static func enemy(withID id: Enemy.ID) -> Enemy? {
        if let enemy = EnemyCatalogBook1.allEnemies.first(where: { $0.id == id }) { return enemy }
        return CampaignCatalog.enemy(withID: id)
    }
}
