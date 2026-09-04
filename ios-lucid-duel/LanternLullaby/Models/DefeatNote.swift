import Foundation

/// What a loss says, and what it teaches.
///
/// Losing in this game is a story beat, not a punishment: the dream ends
/// early, the book is still open at the same page, and you go back tonight.
/// So each ending gets a line of story and one concrete thing to try — the
/// rule the player most likely has not used yet, named in plain words a
/// ten-year-old can act on.
///
/// The text lives here rather than in the overlay views so it can be read,
/// tested and rewritten without touching SwiftUI.
nonisolated struct DefeatNote: Equatable, Sendable {
    /// The heading on the card.
    let title: String
    /// One line of story: what just happened to the dreamer.
    let line: String
    /// One concrete thing to try next time.
    let advice: String

    /// The note for how this battle ended. `stageName` names the page so a
    /// loss reads as a place in the book rather than a generic failure.
    static func note(for outcome: GameOutcome, stageName: String?) -> DefeatNote? {
        let page = stageName.map { "\($0) is still open in front of you." }
            ?? "The book is still open at the same page."

        switch outcome {
        case .lostToLucidity(let zone) where zone == .awakening:
            return DefeatNote(
                title: "You Awoke",
                line: "The flame flared white and the dream let go of you. \(page)",
                advice: "The lantern climbs every time you play a card. Spend a turn on a Relax card, or drop any card onto the lantern to let it go — that dims the flame without costing you a turn."
            )
        case .lostToLucidity:
            return DefeatNote(
                title: "Lost in Dreams",
                line: "The flame guttered out and the dream closed over you. \(page)",
                advice: "Relax cards dim the lantern, and enemies that whisper dim it further. Attack cards brighten it — when the flame runs low, the way back up is to fight."
            )
        case .defeated:
            return DefeatNote(
                title: "The Dream Overwhelms You",
                line: "Your party could not hold the clearing. \(page)",
                advice: "Only the hero in front takes the hits. Play Step Forward to put a fresh hero in the lead, watch the intent chips for the big blow, and shield the turn before it lands."
            )
        case .victory, .ongoing:
            return nil
        }
    }
}
