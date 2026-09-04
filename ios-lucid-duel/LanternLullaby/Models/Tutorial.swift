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

    /// The lesson after Lancelot joins: what a party is, what the lead
    /// does, and where passives come from.
    static let partyAndPassives = TutorialScript(steps: [
        TutorialStep(
            id: "party-intro",
            title: "A company, not a champion",
            text: "Lancelot fights with you now. Up to three heroes share one hand, one deck and one lantern — but each keeps their own health.",
            anchor: .hero,
            advance: .tap
        ),
        TutorialStep(
            id: "party-lead",
            title: "The lead takes the blows",
            text: "The hero in front is the lead. Enemies aim at them; if they fall, the next hero steps up. You only lose when nobody is left standing.",
            anchor: .hero,
            advance: .tap
        ),
        TutorialStep(
            id: "party-passive",
            title: "Only the lead's passive counts",
            text: "Only the lead's passive counts. Lancelot's Peerless Blade adds 3 damage while Vivid. Make Lancelot lead on the book page and you'll feel it.",
            anchor: .hero,
            advance: .tap
        ),
        TutorialStep(
            id: "party-ability",
            title: "Abilities charge as you play",
            text: "Under each hero's health bar is a row of pips. Playing one of that hero's cards fills a pip — wherever they stand.",
            anchor: .hero,
            advance: .tap
        ),
        TutorialStep(
            id: "party-ability-fire",
            title: "Then they fire for free",
            text: "Fill them all and a gold badge appears above the hero. Tap it: the ability fires for free. No Lucidity at all.",
            anchor: .hero,
            advance: .tap
        ),
        TutorialStep(
            id: "party-order",
            title: "Choose before you sleep",
            text: "Set your party and its order on the book page, before the dream begins. In battle, only a card like Step Forward can change who leads.",
            anchor: .center,
            advance: .tap
        ),
    ])

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
            text: "A card's +number is how much it raises Lucidity. Hit 100 and you jolt awake. Burn out to 0 and you sink into Deep Sleep. Both end the dream.",
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
            text: "Drag a card's thread to a target. Attacks go to an enemy; shields and heals go to a hero. Relax and draw cards just pull up. Try it now.",
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
            id: "release",
            title: "When nothing helps, let one go",
            text: "Drop any card onto the lantern instead of playing it. Let it go: the card is gone for this battle, the flame dims 5 — never below Drifting.",
            anchor: .lantern,
            advance: .tap
        ),
        TutorialStep(
            id: "strain",
            title: "Vary what you play",
            text: "Each repeat of a card type in the same turn costs +1 more Lucidity, shown on the card. Mixing attack, defense and rest keeps the cost low.",
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
            text: "A bright flame (Vivid, 66–85) makes your attacks 20% stronger.",
            anchor: .lantern,
            advance: .tap
        ),
        TutorialStep(
            id: "zones-drifting",
            title: "Or sink into the dark",
            text: "A dim flame (Drifting, 16–35) makes every card cost 2 less, draws you an extra card, and shows the enemy's next two moves.",
            anchor: .lantern,
            advance: .tap
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
