import Foundation

// MARK: - Campaign Progress
// Persisted player progress through the campaign

struct CampaignProgress: Codable {
    
    /// Cleared stages: key = "book-chapter-stage" (e.g., "0-0-4")
    var clearedStages: Set<String> = []
    
    /// Unlocked hero IDs (beyond starters)
    var unlockedHeroIDs: Set<UUID> = []
    
    /// Currently selected hero IDs for party
    var selectedHeroIDs: [UUID] = []
    
    /// Highest book index reached
    var highestBookIndex: Int = 0
    
    /// Highest chapter index reached (within highest book)
    var highestChapterIndex: Int = 0
    
    /// Total battles won
    var battlesWon: Int = 0
    
    /// Total battles lost
    var battlesLost: Int = 0
    
    // MARK: - Stage Progress
    
    /// Mark a stage as cleared
    mutating func markCleared(bookIndex: Int, chapterIndex: Int, stageIndex: Int) {
        let key = stageKey(bookIndex: bookIndex, chapterIndex: chapterIndex, stageIndex: stageIndex)
        clearedStages.insert(key)
        battlesWon += 1
        
        // Update highest reached
        if bookIndex > highestBookIndex {
            highestBookIndex = bookIndex
            highestChapterIndex = chapterIndex
        } else if bookIndex == highestBookIndex && chapterIndex > highestChapterIndex {
            highestChapterIndex = chapterIndex
        }
        
        // Check for hero unlocks
        checkHeroUnlocks(bookIndex: bookIndex, chapterIndex: chapterIndex, stageIndex: stageIndex)
    }
    
    /// Check if a stage is cleared
    func isCleared(bookIndex: Int, chapterIndex: Int, stageIndex: Int) -> Bool {
        let key = stageKey(bookIndex: bookIndex, chapterIndex: chapterIndex, stageIndex: stageIndex)
        return clearedStages.contains(key)
    }
    
    /// Record a battle loss
    mutating func recordLoss() {
        battlesLost += 1
    }
    
    // MARK: - Hero Unlocks
    
    /// Check and apply hero unlocks for the given stage
    private mutating func checkHeroUnlocks(bookIndex: Int, chapterIndex: Int, stageIndex: Int) {
        // Book 1 unlock triggers (0-indexed)
        // Chapter 1 (index 0): Lancelot at stage 5 (index 4), Kay at stage 8 (index 7)
        // Chapter 2 (index 1): Bedivere at stage 3 (index 2), Morgana at stage 8 (index 7)
        // Chapter 3 (index 2): Escanor at stage 5 (index 4), Galahad at stage 8 (index 7)
        // Chapter 4 (index 3): Merlin at stage 1 (index 0)
        
        guard bookIndex == 0 else { return }  // Only Book 1 for now
        
        switch (chapterIndex, stageIndex) {
        case (0, 4):  // Ch1-S5
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.lancelot)
        case (0, 7):  // Ch1-S8
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.kay)
        case (1, 2):  // Ch2-S3
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.bedivere)
        case (1, 7):  // Ch2-S8
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.morgana)
        case (2, 4):  // Ch3-S5
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.escanor)
        case (2, 7):  // Ch3-S8
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.galahad)
        case (3, 0):  // Ch4-S1
            unlockedHeroIDs.insert(CardCatalogHeroes.HeroIDs.merlin)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    private func stageKey(bookIndex: Int, chapterIndex: Int, stageIndex: Int) -> String {
        "\(bookIndex)-\(chapterIndex)-\(stageIndex)"
    }
    
    // MARK: - Persistence
    
    private static let storageKey = "CampaignProgress"
    
    /// Save to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
    
    /// Load from UserDefaults
    static func load() -> CampaignProgress? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let progress = try? JSONDecoder().decode(CampaignProgress.self, from: data) else {
            return nil
        }
        return progress
    }
    
    /// Reset all progress (new game)
    static func reset() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

// MARK: - Stats

extension CampaignProgress {
    
    /// Total stages cleared
    var totalStagesCleared: Int {
        clearedStages.count
    }
    
    /// Win rate as percentage
    var winRate: Double {
        let total = battlesWon + battlesLost
        guard total > 0 else { return 0 }
        return Double(battlesWon) / Double(total) * 100
    }
    
    /// Number of heroes unlocked (including starters)
    var heroCount: Int {
        unlockedHeroIDs.count + 2  // +2 for Wart and Archimedes
    }
}
