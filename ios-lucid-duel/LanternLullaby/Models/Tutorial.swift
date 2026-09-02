import Foundation

/// Where a tutorial callout points on the battle screen.
nonisolated enum TutorialAnchor: String, Codable, Sendable {
    case lantern
    case hand
    case enemy
    case hero
    case endTurn
    case center
}

/// What moves the tutorial to its next step.
nonisolated enum TutorialAdvance: String, Codable, Sendable {
    /// The player taps the callout.
    case tap
    /// The player plays any card.
    case cardPlayed
    /// The player ends their turn.
    case turnEnded
    /// The enemy turn resolves and a new player turn begins.
    case enemyTurnDone
}

nonisolated struct TutorialStep: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let text: String
    let anchor: TutorialAnchor
    let advance: TutorialAdvance
}

/// A scripted lesson layered over a real battle. Steps that advance on
/// `.tap` pause play; steps that advance on an action let the player try it.
nonisolated struct TutorialScript: Hashable, Codable, Sendable {
    let steps: [TutorialStep]

    /// The first battle: the lantern, cards, intents, Relax, and turns.
    static let firstBattle = TutorialScript(steps: [
        TutorialStep(
            id: "lantern",
            title: "Your lantern",
            text: "This flame is your Lucidity — how tightly you hold the dream. It sits at 50, right in the middle of the meter.",
            anchor: .lantern,
            advance: .tap
        ),
        TutorialStep(
            id: "cost",
            title: "Every card brightens the flame",
            text: "The +number on a card is how much it raises Lucidity. Reach 100 and you jolt awake. Let it gutter to 0 and you sink into Deep Sleep. Either one ends the dream.",
            anchor: .lantern,
            advance: .tap
        ),
        TutorialStep(
            id: "party",
            title: "Your party",
            text: "Wart leads tonight, so enemies aim at him. Archimedes waits behind. You set the order before each dream — and some cards can change it mid-fight.",
            anchor: .hero,
            advance: .tap
        ),
        TutorialStep(
            id: "intent",
            title: "Read the enemy",
            text: "The red number above the wolf is what it will do on its turn. Watch it every turn — shield up before a heavy blow.",
            anchor: .enemy,
            advance: .tap
        ),
        TutorialStep(
            id: "play",
            title: "Play a card",
            text: "Touch a card and drag the thread to a target. Attacks go to an enemy; shields and heals go to one of your heroes. Cards that need no target — Relax and draw — just pull up. Try it now.",
            anchor: .hand,
            advance: .cardPlayed
        ),
        TutorialStep(
            id: "relax",
            title: "Relax to dim the flame",
            text: "Cards like Deep Breath and Mental Shift lower Lucidity. Balance attacks with rest and the lantern stays steady.",
            anchor: .hand,
            advance: .tap
        ),
        TutorialStep(
            id: "endTurn",
            title: "End your turn",
            text: "Play what you like, then End Turn. The wolf acts, you draw a card, and the lantern drifts a little toward the middle.",
            anchor: .endTurn,
            advance: .turnEnded
        ),
        TutorialStep(
            id: "zones",
            title: "Ride the edge",
            text: "A bright flame (Vivid, 66–85) makes attacks 20% stronger. A dim one (Drifting, 16–35) makes shields and heals 20% stronger. Balanced is safe but plain.",
            anchor: .lantern,
            advance: .enemyTurnDone
        ),
        TutorialStep(
            id: "go",
            title: "The dream is yours",
            text: "Defeat the wolf. Keep the flame between the extremes. Good luck, dreamer.",
            anchor: .center,
            advance: .tap
        ),
    ])
}
