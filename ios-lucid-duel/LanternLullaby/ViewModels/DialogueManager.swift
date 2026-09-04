import Foundation
import SwiftUI

// MARK: - Dialogue Manager
// Handles triggering and queuing of in-battle dialogues

@Observable
final class DialogueManager {

    // Current active dialogue (nil if none showing)
    var activeDialogue: BattleDialogue?

    // Queue of pending dialogues
    private var dialogueQueue: [BattleDialogue] = []

    // Track which one-time dialogues have been shown
    private var shownFirstTimeKeys: Set<String> = []

    // All dialogues registered for this battle
    private var registeredDialogues: [BattleDialogue] = []

    // Callback when dialogue state changes
    var onDialogueStateChanged: ((Bool) -> Void)?

    // MARK: - Setup

    /// Register dialogues for the current battle
    func registerDialogues(_ dialogues: [BattleDialogue]) {
        registeredDialogues = dialogues
        dialogueQueue = []
        activeDialogue = nil
    }

    /// Clear all state (call when battle ends)
    func reset() {
        registeredDialogues = []
        dialogueQueue = []
        activeDialogue = nil
    }

    // MARK: - Trigger Checks

    /// Check if any dialogue should trigger for the given event
    func checkTrigger(_ trigger: DialogueTrigger) {
        let matchingDialogues = registeredDialogues.filter { dialogue in
            matchesTrigger(dialogue.trigger, event: trigger)
        }

        // Filter out already-shown first-time dialogues
        let newDialogues = matchingDialogues.filter { dialogue in
            if case .firstTimeOnly(let key) = dialogue.trigger {
                return !shownFirstTimeKeys.contains(key)
            }
            return true
        }

        // Queue them up
        for dialogue in newDialogues {
            queueDialogue(dialogue)
        }
    }

    /// Fires every registered first-time beat (party combos) that has not
    /// been seen yet. Called once the battle opens; the shown-key set keeps
    /// each one to a single showing across the whole book.
    func checkFirstTimeDialogues() {
        for dialogue in registeredDialogues {
            if case .firstTimeOnly = dialogue.trigger {
                checkTrigger(dialogue.trigger)
            }
        }
    }

    /// Forgets every first-time beat on disk, for a fresh book.
    static func clearPersistedKeys() {
        UserDefaults.standard.removeObject(forKey: shownKeysKey)
    }

    /// Check for enemy health threshold dialogues
    func checkHealthThreshold(enemyHealthPercent: Int) {
        checkTrigger(.enemyHealthThreshold(percent: enemyHealthPercent))
    }

    /// Check for turn-based dialogues
    func checkTurnNumber(_ turn: Int) {
        checkTrigger(.turnNumber(turn: turn))
    }

    /// Check for wave transitions
    func checkWaveStart(waveIndex: Int) {
        checkTrigger(.waveStart(waveIndex: waveIndex))
    }

    func checkWaveEnd(waveIndex: Int) {
        checkTrigger(.waveEnd(waveIndex: waveIndex))
    }

    // MARK: - Queue Management

    /// Shows a dialogue that was built at runtime (wave banners, hero
    /// entrances) without registering a trigger for it.
    func enqueue(_ dialogue: BattleDialogue) {
        queueDialogue(dialogue)
    }

    private func queueDialogue(_ dialogue: BattleDialogue) {
        // Mark first-time dialogues as shown
        if case .firstTimeOnly(let key) = dialogue.trigger {
            shownFirstTimeKeys.insert(key)
        }

        // Add to queue
        dialogueQueue.append(dialogue)

        // If nothing active, show immediately
        if activeDialogue == nil {
            showNextDialogue()
        }
    }

    private func showNextDialogue() {
        guard !dialogueQueue.isEmpty else {
            activeDialogue = nil
            onDialogueStateChanged?(false)
            return
        }

        activeDialogue = dialogueQueue.removeFirst()
        onDialogueStateChanged?(true)
    }

    /// Called when user dismisses current dialogue
    func dismissCurrentDialogue() {
        showNextDialogue()
    }

    // MARK: - Trigger Matching

    private func matchesTrigger(_ registered: DialogueTrigger, event: DialogueTrigger) -> Bool {
        switch (registered, event) {
        case (.battleStart, .battleStart):
            return true
        case (.battleEnd, .battleEnd):
            return true
        case (.waveStart(let a), .waveStart(let b)):
            return a == b
        case (.waveEnd(let a), .waveEnd(let b)):
            return a == b
        case (.enemyHealthThreshold(let a), .enemyHealthThreshold(let b)):
            // The engine reports each threshold exactly once as it is
            // crossed, so match it exactly — `b <= a` re-fired a 50%
            // line at 25% and 10% too.
            return a == b
        case (.turnNumber(let a), .turnNumber(let b)):
            return a == b
        case (.heroUnlock(let a), .heroUnlock(let b)):
            return a == b
        case (.firstTimeOnly(let a), .firstTimeOnly(let b)):
            return a == b
        default:
            return false
        }
    }

    // MARK: - Persistence (for first-time keys)

    private static let shownKeysKey = "DialogueManager.ShownFirstTimeKeys"

    func loadShownKeys() {
        if let saved = UserDefaults.standard.stringArray(forKey: Self.shownKeysKey) {
            shownFirstTimeKeys = Set(saved)
        }
    }

    func saveShownKeys() {
        UserDefaults.standard.set(Array(shownFirstTimeKeys), forKey: Self.shownKeysKey)
    }

    /// Reset all first-time dialogues (for testing or new game)
    func resetFirstTimeDialogues() {
        shownFirstTimeKeys = []
        UserDefaults.standard.removeObject(forKey: Self.shownKeysKey)
    }
}

// MARK: - Battle Dialogue State

/// Represents the dialogue state in a battle
enum BattleDialogueState {
    case none                           // No dialogue, normal battle
    case showingDialogue(BattleDialogue) // Currently showing dialogue
    case transitioning                  // Between dialogues
}
