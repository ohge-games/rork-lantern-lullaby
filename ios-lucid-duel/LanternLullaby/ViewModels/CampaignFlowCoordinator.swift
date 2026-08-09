import Foundation
import SwiftUI

// MARK: - Campaign Flow Coordinator
// Manages the full campaign experience: progress, unlocks, stage transitions

@Observable
final class CampaignFlowCoordinator {
    
    // MARK: - State
    
    /// Current campaign progress (persisted)
    private(set) var progress: CampaignProgress
    
    /// Currently selected book
    private(set) var currentBook: Book?
    
    /// Currently selected chapter
    private(set) var currentChapter: Chapter?
    
    /// Currently selected stage (about to play or just completed)
    private(set) var currentStage: Stage?
    
    /// Heroes selected for current battle
    private(set) var selectedPartyHeroIDs: [UUID] = []
    
    /// Current flow state
    private(set) var flowState: CampaignFlowState = .bookSelect
    
    /// Active battle view model (when in battle)
    private(set) var battleViewModel: BattleViewModel?
    
    // MARK: - Available Content
    
    /// All available books
    let allBooks: [Book] = [
        Book(
            id: UUID(uuidString: "00000000-0000-0000-0001-000000000001")!,
            index: 0,
            title: "The Once and Future King",
            chapters: CampaignCatalogBook1.allChapters
        )
    ]
    
    /// All unlocked heroes (derived from progress)
    var unlockedHeroes: [Hero] {
        // Always include starters
        var heroes: [Hero] = [
            CardCatalogHeroes.wart,
            CardCatalogHeroes.archimedes
        ]
        
        // Add unlocked heroes
        for heroID in progress.unlockedHeroIDs {
            if let hero = CardCatalogHeroes.hero(withID: heroID),
               !heroes.contains(where: { $0.id == heroID }) {
                heroes.append(hero)
            }
        }
        
        return heroes.sorted { $0.name < $1.name }
    }
    
    // MARK: - Init
    
    init() {
        self.progress = CampaignProgress.load() ?? CampaignProgress()
    }
    
    // MARK: - Navigation
    
    /// Select a book to view chapters
    func selectBook(_ book: Book) {
        currentBook = book
        flowState = .chapterSelect
    }
    
    /// Select a chapter to view stages
    func selectChapter(_ chapter: Chapter) {
        currentChapter = chapter
        flowState = .stageSelect
    }
    
    /// Select a stage to prepare for battle
    func selectStage(_ stage: Stage) {
        currentStage = stage
        flowState = .heroSelect
        
        // Default party: first two unlocked heroes
        let available = unlockedHeroes
        selectedPartyHeroIDs = Array(available.prefix(2).map { $0.id })
    }
    
    /// Update party selection
    func setParty(_ heroIDs: [UUID]) {
        // Validate: max 3 heroes, must be unlocked
        let validIDs = heroIDs.filter { id in
            unlockedHeroes.contains { $0.id == id }
        }
        selectedPartyHeroIDs = Array(validIDs.prefix(3))
    }
    
    /// Add hero to party (if room)
    func addHeroToParty(_ heroID: UUID) {
        guard selectedPartyHeroIDs.count < 3,
              !selectedPartyHeroIDs.contains(heroID),
              unlockedHeroes.contains(where: { $0.id == heroID }) else { return }
        selectedPartyHeroIDs.append(heroID)
    }
    
    /// Remove hero from party
    func removeHeroFromParty(_ heroID: UUID) {
        selectedPartyHeroIDs.removeAll { $0 == heroID }
    }
    
    /// Start the battle with current stage and party
    func startBattle() {
        guard let chapter = currentChapter,
              let stage = currentStage else { return }
        
        // Create battle view model
        let viewModel = BattleViewModel()
        
        // Get narrative for this stage
        let chapterNumber = chapter.index + 1
        let stageNumber = stage.index + 1
        let narrative = NarrativeCatalogBook1.narrative(
            forChapter: chapterNumber,
            stage: stageNumber
        )
        
        // Configure narrative with party
        viewModel.configureNarrative(narrative, partyHeroIDs: selectedPartyHeroIDs)
        
        battleViewModel = viewModel
        flowState = .inBattle
    }
    
    /// Called when battle ends (victory or defeat)
    func completeBattle(victory: Bool) {
        guard let book = currentBook,
              let chapter = currentChapter,
              let stage = currentStage else { return }
        
        if victory {
            // Mark stage cleared and check for unlocks
            progress.markCleared(
                bookIndex: book.index,
                chapterIndex: chapter.index,
                stageIndex: stage.index
            )
            progress.save()
            
            flowState = .victoryScreen
        } else {
            flowState = .defeatScreen
        }
        
        battleViewModel = nil
    }
    
    /// After victory, continue to next stage or back to select
    func continueAfterVictory() {
        guard let chapter = currentChapter,
              let stage = currentStage else {
            flowState = .stageSelect
            return
        }
        
        // Find next stage
        let nextIndex = stage.index + 1
        if let nextStage = chapter.stages.first(where: { $0.index == nextIndex }) {
            // Auto-advance to next stage
            currentStage = nextStage
            flowState = .heroSelect
        } else {
            // Chapter complete - back to chapter select
            flowState = .chapterSelect
            currentStage = nil
        }
    }
    
    /// After defeat, retry or go back
    func retryAfterDefeat() {
        flowState = .heroSelect
    }
    
    func exitToStageSelect() {
        flowState = .stageSelect
        battleViewModel = nil
    }
    
    func exitToChapterSelect() {
        flowState = .chapterSelect
        currentStage = nil
        battleViewModel = nil
    }
    
    func exitToBookSelect() {
        flowState = .bookSelect
        currentChapter = nil
        currentStage = nil
        battleViewModel = nil
    }
    
    // MARK: - Queries
    
    /// Check if a stage is unlocked (playable)
    func isStageUnlocked(_ stage: Stage, inChapter chapter: Chapter, book: Book) -> Bool {
        // First stage of first chapter is always unlocked
        if chapter.index == 0 && stage.index == 0 {
            return true
        }
        
        // Stage is unlocked if previous stage is cleared
        if stage.index > 0 {
            return progress.isCleared(
                bookIndex: book.index,
                chapterIndex: chapter.index,
                stageIndex: stage.index - 1
            )
        }
        
        // First stage of chapter is unlocked if last stage of previous chapter is cleared
        if chapter.index > 0, let prevChapter = book.chapters.first(where: { $0.index == chapter.index - 1 }) {
            let lastStageIndex = prevChapter.stages.count - 1
            return progress.isCleared(
                bookIndex: book.index,
                chapterIndex: prevChapter.index,
                stageIndex: lastStageIndex
            )
        }
        
        return false
    }
    
    /// Check if a stage is cleared (completed)
    func isStageCleared(_ stage: Stage, inChapter chapter: Chapter, book: Book) -> Bool {
        return progress.isCleared(
            bookIndex: book.index,
            chapterIndex: chapter.index,
            stageIndex: stage.index
        )
    }
    
    /// Check if a chapter is unlocked
    func isChapterUnlocked(_ chapter: Chapter, inBook book: Book) -> Bool {
        if chapter.index == 0 { return true }
        
        // Chapter is unlocked if previous chapter's last stage is cleared
        if let prevChapter = book.chapters.first(where: { $0.index == chapter.index - 1 }) {
            let lastStageIndex = prevChapter.stages.count - 1
            return progress.isCleared(
                bookIndex: book.index,
                chapterIndex: prevChapter.index,
                stageIndex: lastStageIndex
            )
        }
        
        return false
    }
    
    /// Get completion percentage for a chapter
    func chapterProgress(_ chapter: Chapter, inBook book: Book) -> Double {
        let totalStages = chapter.stages.count
        guard totalStages > 0 else { return 0 }
        
        let clearedCount = chapter.stages.filter { stage in
            isStageCleared(stage, inChapter: chapter, book: book)
        }.count
        
        return Double(clearedCount) / Double(totalStages)
    }
}

// MARK: - Flow State

enum CampaignFlowState: Equatable {
    case bookSelect
    case chapterSelect
    case stageSelect
    case heroSelect
    case inBattle
    case victoryScreen
    case defeatScreen
}

// MARK: - Book Model

struct Book: Identifiable {
    let id: UUID
    let index: Int
    let title: String
    let chapters: [Chapter]
}
