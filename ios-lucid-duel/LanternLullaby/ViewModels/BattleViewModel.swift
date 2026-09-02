import CoreGraphics
import Foundation
import Observation

/// What an enemy plans to do next turn (telegraphed to the player).
nonisolated enum EnemyIntent: Hashable, Sendable {
    case attack(Int)
    case brace(Int)
    /// A self-buff; the label is what the intent chip reads.
    case buff(String)
}

/// Tracks narrative flow state during battle.
enum NarrativePhase: Equatable {
    case none                    // Normal gameplay
    case showingPreScene         // Pre-battle cutscene
    case showingDialogue         // In-battle dialogue overlay
    case showingPostScene        // Post-battle cutscene
    case waitingForDialogueDismiss  // Paused, waiting for tap
}

/// A resolved hit against a combatant, used for floating combat numbers.
nonisolated struct HitEvent: Identifiable, Hashable, Sendable {
    let id: UUID
    let amount: Int
    let absorbed: Int

    var healthDamage: Int { max(0, amount - absorbed) }

    init(amount: Int, absorbed: Int) {
        self.id = UUID()
        self.amount = amount
        self.absorbed = absorbed
    }
}

/// Transient banner announcing that the player's lucidity entered a new zone.
nonisolated struct ZoneNotification: Identifiable, Hashable, Sendable {
    let id: UUID
    let zone: LucidityZone
    let message: String

    init(zone: LucidityZone, message: String) {
        self.id = UUID()
        self.zone = zone
        self.message = message
    }
}

/// One-shot cue describing the direction of the last meter movement, used
/// by the meter for its sharpening/softening visual response.
nonisolated struct LucidityPulse: Identifiable, Hashable, Sendable {
    nonisolated enum Direction: Hashable, Sendable {
        /// Lucidity rose — the dream sharpens into focus.
        case sharpen
        /// Lucidity fell — the dream softens and blurs.
        case soften
    }

    let id: UUID
    let direction: Direction

    init(direction: Direction) {
        self.id = UUID()
        self.direction = direction
    }
}

/// Placeholder for audio: names the sound that *would* play right now.
/// The UI surfaces it as a small "♪" chip until real audio is added.
nonisolated struct SoundCue: Identifiable, Hashable, Sendable {
    let id: UUID
    let label: String

    init(label: String) {
        self.id = UUID()
        self.label = label
    }
}

/// A short banner for battle events that are not zone changes: a hero
/// falling, a teammate stepping up, a new wave arriving.
nonisolated struct BattleNotice: Identifiable, Hashable, Sendable {
    let id: UUID
    let text: String

    init(text: String) {
        self.id = UUID()
        self.text = text
    }
}

/// Runtime state for one hero in the party. Health lives here for every
/// member; the engine mirrors the lead hero's health into `GameState`.
nonisolated struct PartyMember: Identifiable, Hashable, Sendable {
    let hero: Hero
    var health: Int

    var id: UUID { hero.id }
    var isDown: Bool { health <= 0 }
}

/// Runtime state for one enemy in the current wave.
nonisolated struct EnemyCombatant: Identifiable, Hashable, Sendable {
    /// Unique per slot — two Forest Sprites in one wave need distinct ids.
    let id: UUID
    let enemy: Enemy
    var health: Int
    var shield: Int
    var brain: EnemyBrain
    let isPrimary: Bool

    var isDown: Bool { health <= 0 }
    var healthFraction: Double {
        guard enemy.maxHealth > 0 else { return 0 }
        return Double(health) / Double(enemy.maxHealth)
    }
}

/// The battle engine: owns the mutable `GameState` and enforces every rule
/// of card play, lucidity movement, zone bonuses, waves, and turn flow.
///
/// The party fights as a unit: one shared hand, deck, shield and Lucidity
/// meter, while each hero keeps their own health. The lead hero takes the
/// hits and contributes their passive; switching leads is free. Enemies
/// arrive in waves and each living enemy acts on its own turn.
@Observable
final class BattleViewModel {
    private(set) var state: GameState
    private(set) var selectedInstanceID: CardInstance.ID?
    private(set) var enemyHit: HitEvent?
    private(set) var playerHit: HitEvent?

    /// Banner shown when the meter crosses into a new zone; auto-clears.
    private(set) var zoneNotification: ZoneNotification?

    /// Banner for hero switches, wave arrivals and the like; auto-clears.
    private(set) var battleNotice: BattleNotice?

    /// Direction cue for the last lucidity movement; auto-clears.
    private(set) var lucidityPulse: LucidityPulse?

    /// Increments on every card play; drives impact haptics.
    private(set) var playImpactTrigger: Int = 0

    /// Increments when an enemy acts; drives the enemy panel pulse.
    private(set) var enemyActionTrigger: Int = 0

    /// Increments when a new wave arrives; drives the wave banner.
    private(set) var waveTrigger: Int = 0

    /// True during the enemy's 1-second "thinking" beat.
    private(set) var isEnemyThinking: Bool = false

    /// The enemy currently taking its action (for the lunge animation).
    private(set) var actingEnemyID: UUID?

    /// The sound that would play right now (placeholder); auto-clears.
    private(set) var soundCue: SoundCue?

    // MARK: - Dialogue System

    /// Manages dialogue triggers and queue.
    let dialogueManager = DialogueManager()

    /// Currently active dialogue to display (nil = no dialogue showing).
    private(set) var activeDialogue: BattleDialogue?

    /// Pre-battle story scene to show before combat begins.
    private(set) var preStageScene: StoryScene?

    /// Post-battle story scene to show after victory.
    private(set) var postStageScene: StoryScene?

    /// Current phase of narrative flow.
    private(set) var narrativePhase: NarrativePhase = .none

    /// Everything registered for this stage, kept so a retry can re-arm it.
    private var registeredDialogues: [BattleDialogue] = []

    /// Tracks the last primary-enemy health percentage for threshold checks.
    private var lastEnemyHealthPercent: Int = 100

    // MARK: - Roster

    let configuration: BattleConfiguration

    /// The heroes in the party, lead first in the initial order.
    private(set) var party: [PartyMember]

    /// The enemies of the current wave, primary first.
    private(set) var enemyLine: [EnemyCombatant]

    /// Index into `configuration.waves` of the wave on the field.
    private(set) var waveIndex: Int = 0

    /// Which enemy offensive cards will hit.
    private(set) var targetedEnemyID: UUID

    /// Which enemy the latest hit landed on (places the floating number).
    private(set) var enemyHitTargetID: UUID?

    /// Which hero currently leads the team. Switching is free — it costs
    /// no turn and no Lucidity.
    private(set) var activeAllyID: UUID

    /// Which ally the latest enemy hit landed on (places the floating number).
    private(set) var playerHitTargetID: UUID?

    /// Increments on every hero switch; drives the switch haptic.
    private(set) var heroSwitchTrigger: Int = 0

    /// Tracks whether this is the first card played this turn (for Kay's passive).
    private var isFirstCardThisTurn: Bool = true

    /// How many cards of each type have been played this turn, for Focus
    /// Strain. Cleared at the start of every player turn.
    private(set) var cardsPlayedThisTurn: [CardType: Int] = [:]

    /// Current turn number, cached for growing passives (Escanor).
    private var currentTurnForPassives: Int { state.turnNumber }

    /// The first hero of the party (the Dreamer in the sandbox duel).
    let playerHero: Hero
    private let cardsByID: [Card.ID: Card]

    /// The heroes whose passives apply right now: the lead hero only, so
    /// choosing who stands in front is a real decision.
    private var activeHeroes: [Hero] {
        guard let lead = party.first(where: { $0.id == activeAllyID }) else { return [] }
        return [lead.hero]
    }

    /// Builds the engine for a configuration.
    ///
    /// - Parameter initialState: test hook; when `nil` a fresh shuffled duel
    ///   is created and the opening hand is drawn. When given, the lead
    ///   hero and the primary enemy are seeded from it.
    init(configuration: BattleConfiguration, initialState: GameState? = nil) {
        self.configuration = configuration
        let heroes = configuration.party
        let lead = heroes[0]
        playerHero = lead
        cardsByID = Dictionary(uniqueKeysWithValues: CardCatalog.allCards.map { ($0.id, $0) })
        party = heroes.map { PartyMember(hero: $0, health: $0.maxHealth) }
        enemyLine = []
        activeAllyID = lead.id
        targetedEnemyID = lead.id

        if let initialState {
            state = initialState
            party[0].health = initialState.player.currentHealth
            spawnWave(0, seedingPrimaryFrom: initialState.enemy)
        } else {
            state = Self.freshDuel(for: configuration)
            spawnWave(0, seedingPrimaryFrom: nil)
            drawPlayerCards(GameRules.startingHandSize)
            state.phase = .playerMain
        }

        dialogueManager.onDialogueStateChanged = { [weak self] isShowing in
            self?.handleDialogueStateChange(isShowing)
        }
    }

    /// The original sandbox duel: the Dreamer versus the Nightmare.
    convenience init(initialState: GameState? = nil) {
        self.init(configuration: .legacyDuel, initialState: initialState)
    }

    // MARK: - Narrative System

    /// Configure narrative content for this battle. Call after init; then
    /// call `startStage()` once the battle is actually on screen.
    func configureNarrative(_ narrative: StageNarrative, partyHeroIDs: [UUID] = []) {
        preStageScene = narrative.preStageScene
        postStageScene = narrative.postStageScene

        var allDialogues = narrative.battleDialogues
        let comboDialogues = NarrativeCatalogBook1.comboDialogues(forParty: partyHeroIDs)
        allDialogues.append(contentsOf: comboDialogues)
        registeredDialogues = allDialogues

        dialogueManager.registerDialogues(allDialogues)
        dialogueManager.loadShownKeys()
    }

    /// Opens the stage: the pre-battle scene if there is one, otherwise the
    /// battle-start dialogue straight away.
    func startStage() {
        tutorialPending = configuration.tutorial != nil
        if preStageScene != nil {
            narrativePhase = .showingPreScene
        } else {
            dialogueManager.checkTrigger(.battleStart)
            if activeDialogue == nil { beginTutorialIfNeeded() }
        }
    }

    /// Called when pre-stage scene completes.
    func dismissPreScene() {
        preStageScene = nil
        narrativePhase = .none
        dialogueManager.checkTrigger(.battleStart)
        if activeDialogue == nil { beginTutorialIfNeeded() }
    }

    /// Called when post-stage scene completes.
    func dismissPostScene() {
        postStageScene = nil
        narrativePhase = .none
        dialogueManager.saveShownKeys()
    }

    /// Called when user taps to dismiss current dialogue.
    func dismissDialogue() {
        dialogueManager.dismissCurrentDialogue()
    }

    /// Handle dialogue manager state changes.
    private func handleDialogueStateChange(_ isShowing: Bool) {
        if isShowing, let dialogue = dialogueManager.activeDialogue {
            activeDialogue = dialogue
            if dialogue.pausesBattle {
                narrativePhase = .showingDialogue
            }
        } else {
            activeDialogue = nil
            if narrativePhase == .showingDialogue {
                narrativePhase = .none
            }
            if tutorialPending, state.phase == .playerMain {
                beginTutorialIfNeeded()
            }
            // The last victory line has been read: play the epilogue scene
            // before the victory card.
            if state.outcome == .victory, postStageScene != nil, narrativePhase == .none {
                narrativePhase = .showingPostScene
            }
        }
    }

    /// Check for primary-enemy health threshold dialogues.
    private func checkEnemyHealthDialogues() {
        guard let primary = enemyLine.first(where: { $0.isPrimary }), primary.enemy.maxHealth > 0 else { return }
        let currentPercent = (primary.health * 100) / primary.enemy.maxHealth

        // Check thresholds: 75%, 50%, 25%, 10%
        let thresholds = [75, 50, 25, 10]
        for threshold in thresholds {
            if lastEnemyHealthPercent > threshold && currentPercent <= threshold {
                dialogueManager.checkHealthThreshold(enemyHealthPercent: threshold)
            }
        }

        lastEnemyHealthPercent = currentPercent
    }

    /// Trigger victory dialogue, then the post scene once it has been read.
    private func triggerVictoryNarrative() {
        dialogueManager.checkTrigger(.battleEnd)
        if activeDialogue == nil, postStageScene != nil {
            narrativePhase = .showingPostScene
        }
        dialogueManager.saveShownKeys()
    }

    /// Check if battle should be paused for dialogue.
    var isBattlePausedForDialogue: Bool {
        narrativePhase == .showingDialogue ||
        narrativePhase == .showingPreScene ||
        narrativePhase == .showingPostScene
    }

    // MARK: - Lookups

    func card(for instance: CardInstance) -> Card? {
        cardsByID[instance.cardID]
    }

    var selectedInstance: CardInstance? {
        state.player.hand.first { $0.id == selectedInstanceID }
    }

    var selectedCard: Card? {
        selectedInstance.flatMap { cardsByID[$0.cardID] }
    }

    /// The enemy standing in front of the current wave.
    var primaryEnemy: Enemy? {
        enemyLine.first { $0.isPrimary }?.enemy
    }

    /// Painting behind the battlefield.
    var arenaArtName: String { configuration.arenaArtName }

    /// Name of the hero enemies are aiming at.
    var leadHeroName: String {
        party.first { $0.id == activeAllyID }?.hero.name ?? playerHero.name
    }

    // MARK: - Tutorial

    private(set) var tutorialSteps: [TutorialStep] = []
    private(set) var tutorialIndex: Int = 0
    private var tutorialPending = false

    var activeTutorialStep: TutorialStep? {
        tutorialIndex < tutorialSteps.count ? tutorialSteps[tutorialIndex] : nil
    }

    /// A callout that waits for a tap pauses play; one that waits for an
    /// action lets the player try it.
    var isTutorialBlocking: Bool {
        activeTutorialStep?.advance == .tap
    }

    /// The player tapped the callout.
    func advanceTutorial() {
        guard let step = activeTutorialStep, step.advance == .tap else { return }
        tutorialIndex += 1
    }

    private func tutorialEvent(_ event: TutorialAdvance) {
        guard let step = activeTutorialStep, step.advance == event else { return }
        tutorialIndex += 1
    }

    private func beginTutorialIfNeeded() {
        guard let script = configuration.tutorial, tutorialSteps.isEmpty else {
            tutorialPending = false
            return
        }
        tutorialPending = false
        tutorialSteps = script.steps
        tutorialIndex = 0
    }

    var waveCount: Int { configuration.waveCount }

    var hasMoreWaves: Bool { waveIndex + 1 < configuration.waves.count }

    /// True when the player's current zone boosts this card by +20%.
    func isBonusActive(for card: Card) -> Bool {
        let zone = state.player.zone
        return (card.cardType == .offensive && zone == .vivid)
            || (card.cardType == .defensive && zone == .drifting)
    }

    /// Lucidity cost after hero passive discounts are applied.
    ///
    /// Passives that affect cost:
    /// - `cheaperLucidityCosts`: reduces cost while in Drifting zone (Merlin)
    /// - `firstCardDiscount`: reduces cost of first card each turn (Kay)
    /// Extra Lucidity this card costs because its type has already been
    /// played this turn. Zero for the first card of a type.
    func strain(for card: Card) -> Int {
        (cardsPlayedThisTurn[card.cardType] ?? 0) * GameRules.focusStrainPerRepeat
    }

    func effectiveCost(of card: Card) -> Int {
        var cost = card.lucidityCost + strain(for: card)

        for hero in activeHeroes {
            switch hero.passive.kind {
            case .cheaperLucidityCosts(let amount):
                if state.player.zone == .drifting {
                    cost -= amount
                }
            case .firstCardDiscount(let amount):
                if isFirstCardThisTurn {
                    cost -= amount
                }
            default:
                break
            }
        }

        return max(0, cost)
    }

    /// Effect value as it would resolve *right now* (for previews/badges).
    func resolvedEffectValue(for effect: Effect, on card: Card) -> Int {
        effect.resolvedValue(cardType: card.cardType, zone: state.player.zone)
    }

    /// Where the meter would land if this card were played now. Mirrors the
    /// exact application order of `playSelectedCard`.
    func projectedLucidity(after card: Card, choice: CardChoiceOption? = nil) -> Int {
        var lucidity = GameRules.clampLucidity(state.player.lucidity + effectiveCost(of: card))
        for effect in card.effects + (choice?.effects ?? []) {
            switch effect.type {
            case .lucidityModify:
                lucidity = GameRules.clampLucidity(lucidity + effect.value)
            case .lucidityCenter:
                lucidity = Self.shifted(lucidity, towardCenterBy: effect.value)
            default:
                break
            }
        }
        return lucidity
    }

    // MARK: - Team roster

    /// The player's hero row. The shared shield is shown on the lead; the
    /// gold ring follows `activeAllyID`.
    var allies: [AllyMember] {
        party.map { member in
            AllyMember(
                id: member.id,
                name: member.hero.name,
                iconName: ArtCatalog.heroIcon(for: member.hero),
                artName: ArtCatalog.heroPortrait(for: member.hero),
                fullBodyArtName: ArtCatalog.heroFullBody(for: member.hero),
                health: member.health,
                maxHealth: member.hero.maxHealth,
                shield: member.id == activeAllyID ? state.player.shield : 0,
                passiveName: member.hero.passive.name,
                passiveText: member.hero.passive.text,
                isActive: member.id == activeAllyID
            )
        }
    }

    /// The enemy row of the current wave: primary first.
    var enemies: [EnemyMember] {
        enemyLine.map { combatant in
            EnemyMember(
                id: combatant.id,
                name: combatant.enemy.name,
                iconName: combatant.enemy.iconName,
                artName: combatant.enemy.artName,
                fullBodyArtName: combatant.enemy.fullBodyArtName,
                maxHealth: combatant.enemy.maxHealth,
                health: combatant.health,
                shield: combatant.shield,
                intent: combatant.brain.intent,
                isPrimary: combatant.isPrimary
            )
        }
    }

    // MARK: - Hero switching

    /// Puts a living teammate in the lead. Free action: no turn, no
    /// Lucidity. The shared hand stays as-is.
    func switchActiveHero(to id: UUID) {
        guard state.outcome == .ongoing,
              id != activeAllyID,
              let member = party.first(where: { $0.id == id }),
              !member.isDown else { return }

        activeAllyID = id
        syncLeadMirror()
        heroSwitchTrigger += 1
        showNotice("\(member.hero.name) steps forward to lead")
        emitSound("hero switch")
    }

    // MARK: - Targeting

    /// True while an offensive card is selected — enemies light up as targets.
    var isTargetingActive: Bool {
        guard state.phase == .playerMain, let card = selectedCard else { return false }
        return cardDealsDamage(card)
    }

    var targetedEnemyName: String {
        enemies.first { $0.id == targetedEnemyID }?.name ?? primaryEnemy?.name ?? "the enemy"
    }

    func cardDealsDamage(_ card: Card) -> Bool {
        if card.effects.contains(where: { $0.type == .damage }) { return true }
        return card.choices?.contains { choice in
            choice.effects.contains { $0.type == .damage }
        } ?? false
    }

    /// Total damage a card would deal right now (drives the target preview).
    func projectedDamage(of card: Card, choice: CardChoiceOption? = nil) -> Int {
        (card.effects + (choice?.effects ?? []))
            .filter { $0.type == .damage }
            .map { resolvedEffectValue(for: $0, on: card) }
            .reduce(0, +)
    }

    /// Tap flow: first tap targets an enemy; tapping the already-targeted
    /// enemy while a single-branch offensive card is selected confirms and
    /// plays the card on it. Dual-direction cards still need a branch pick.
    func tapEnemy(_ id: UUID) {
        guard state.phase == .playerMain else { return }
        guard let member = enemyLine.first(where: { $0.id == id }), !member.isDown else { return }

        if isTargetingActive, targetedEnemyID == id, let card = selectedCard, card.choices == nil {
            playSelectedCard()
            return
        }
        targetedEnemyID = id
    }

    // MARK: - Drag-and-drop play

    /// True while a card is being dragged out of the hand.
    private(set) var isDraggingCard = false

    /// Tail of the targeting thread (global space): the dragged card's top.
    private(set) var dragAnchor: CGPoint?

    /// Head of the targeting thread (global space): the finger.
    private(set) var dragPoint: CGPoint?

    /// The hero under the finger while a support card is dragged.
    private(set) var hoveredAllyID: UUID?

    /// The hero a dual-direction card was dropped on; consumed when the
    /// player picks a branch.
    private(set) var pendingAllyTarget: UUID?

    /// The ally target of the card currently resolving (for `swapLead`).
    private var resolvingAllyTarget: UUID?

    /// Battlefield frames reported by hero figures (global space).
    @ObservationIgnored private var allyFrames: [UUID: CGRect] = [:]

    func reportAllyFrame(_ id: UUID, frame: CGRect) {
        allyFrames[id] = frame
    }

    /// The living hero under a drag location.
    func allyID(at point: CGPoint) -> UUID? {
        for member in party where !member.isDown {
            if let frame = allyFrames[member.id],
               frame.insetBy(dx: -16, dy: -16).contains(point) {
                return member.id
            }
        }
        return nil
    }

    /// True while the dragged card can be dropped on one of your heroes:
    /// support cards always, dual-direction cards too.
    var isAllyTargetingActive: Bool {
        guard isDraggingCard, let card = selectedCard, card.needsTarget else { return false }
        return card.choices != nil || !cardDealsDamage(card)
    }

    /// How far a global card must be pulled above the hand to play.
    private static let globalPlayLift: CGFloat = 70

    /// True while a card that needs no target is held high enough to play.
    var isLiftedForGlobalPlay: Bool {
        guard let card = selectedCard, !card.needsTarget,
              let anchor = dragAnchor, let point = dragPoint else { return false }
        return point.y < anchor.y - Self.globalPlayLift
    }

    /// Moves the targeting thread and aims at whatever sits under the finger.
    func updateCardDrag(anchor: CGPoint, point: CGPoint) {
        guard isDraggingCard, let card = selectedCard else { return }
        dragAnchor = anchor
        dragPoint = point

        guard card.needsTarget else {
            hoveredAllyID = nil
            return
        }

        let enemyUnderFinger = cardDealsDamage(card) ? enemyID(at: point) : nil
        let allyUnderFinger = (card.choices != nil || !cardDealsDamage(card)) ? allyID(at: point) : nil

        if let enemyUnderFinger {
            hoverEnemy(enemyUnderFinger)
            hoveredAllyID = nil
        } else {
            hoveredAllyID = allyUnderFinger
        }
    }

    /// True when releasing now would play the card.
    var hasDropTarget: Bool {
        guard isDraggingCard, let card = selectedCard, let point = dragPoint else { return false }
        guard card.needsTarget else { return isLiftedForGlobalPlay }
        if cardDealsDamage(card), enemyID(at: point) != nil { return true }
        if card.choices != nil || !cardDealsDamage(card), allyID(at: point) != nil { return true }
        return false
    }

    func setPendingAllyTarget(_ id: UUID?) {
        pendingAllyTarget = id
    }

    /// Battlefield frames reported by enemy figures (global space), used
    /// to hit-test card drops. Read only inside gestures — not observed.
    @ObservationIgnored private var enemyFrames: [UUID: CGRect] = [:]

    func reportEnemyFrame(_ id: UUID, frame: CGRect) {
        enemyFrames[id] = frame
    }

    /// The living enemy under a drag location, front-most first.
    func enemyID(at point: CGPoint) -> UUID? {
        for enemy in enemyLine where !enemy.isDown {
            if let frame = enemyFrames[enemy.id],
               frame.insetBy(dx: -16, dy: -16).contains(point) {
                return enemy.id
            }
        }
        return nil
    }

    /// Lifts a card out of the fan: it becomes the selected card so zone
    /// bonuses, targeting glow, and damage projections all track the drag.
    func beginCardDrag(of instance: CardInstance) {
        guard state.phase == .playerMain, !isBattlePausedForDialogue, !isTutorialBlocking else { return }
        selectedInstanceID = instance.id
        pendingAllyTarget = nil
        isDraggingCard = true
    }

    func endCardDrag() {
        isDraggingCard = false
        dragAnchor = nil
        dragPoint = nil
        hoveredAllyID = nil
    }

    /// Aims the dragged card at an enemy while hovering over it.
    func hoverEnemy(_ id: UUID) {
        guard let member = enemyLine.first(where: { $0.id == id }), !member.isDown else { return }
        targetedEnemyID = id
    }

    // MARK: - Player actions

    func toggleSelection(of instance: CardInstance) {
        guard state.phase == .playerMain, !isTutorialBlocking else { return }
        selectedInstanceID = selectedInstanceID == instance.id ? nil : instance.id
    }

    func clearSelection() {
        selectedInstanceID = nil
        pendingAllyTarget = nil
    }

    /// Resolves the selected card: cost first, then base effects in order,
    /// then the chosen branch (for dual-direction cards), then the card
    /// moves to the discard pile and end conditions are checked.
    ///
    /// - Parameters:
    ///   - choice: required when the card carries `choices`; playing a
    ///     dual-direction card without picking a branch is a no-op.
    ///   - allyTarget: the hero the card was dropped on, for effects that
    ///     act on a chosen hero (`swapLead`). Falls back to the target a
    ///     dual-direction card was dropped on.
    func playSelectedCard(choice: CardChoiceOption? = nil, allyTarget: UUID? = nil) {
        guard !isBattlePausedForDialogue, !isTutorialBlocking else { return }

        guard state.phase == .playerMain,
              state.outcome == .ongoing,
              let instance = selectedInstance,
              let card = cardsByID[instance.cardID] else { return }

        if let available = card.choices {
            guard let choice, available.contains(choice) else { return }
        }

        // Zone bonuses lock in at the moment of play, before the cost moves
        // the meter — what the badge promised is what the player gets.
        let zoneAtPlay = state.player.zone

        state.player.hand.removeAll { $0.id == instance.id }
        state.player.discardPile.append(instance)
        selectedInstanceID = nil

        applyPlayerLucidityDelta(effectiveCost(of: card))
        isFirstCardThisTurn = false
        cardsPlayedThisTurn[card.cardType, default: 0] += 1

        resolvingAllyTarget = allyTarget ?? pendingAllyTarget
        pendingAllyTarget = nil
        for effect in card.effects + (choice?.effects ?? []) {
            resolve(effect, from: card, zoneAtPlay: zoneAtPlay)
        }
        resolvingAllyTarget = nil

        playImpactTrigger += 1
        emitSound("card played")
        tutorialEvent(.cardPlayed)
        refreshOutcome()
    }

    func endTurn() {
        guard !isBattlePausedForDialogue, !isTutorialBlocking else { return }
        guard state.phase == .playerMain, state.outcome == .ongoing else { return }
        selectedInstanceID = nil
        pendingAllyTarget = nil
        state.phase = .enemyTurn
        tutorialEvent(.turnEnded)
        Task { await resolveEnemyTurn() }
    }

    /// Restarts the same fight from the first wave with everyone healed.
    func startNewDuel() {
        state = Self.freshDuel(for: configuration)
        party = configuration.party.map { PartyMember(hero: $0, health: $0.maxHealth) }
        activeAllyID = configuration.party[0].id
        selectedInstanceID = nil
        enemyHit = nil
        playerHit = nil
        zoneNotification = nil
        battleNotice = nil
        lucidityPulse = nil
        soundCue = nil
        isEnemyThinking = false
        actingEnemyID = nil
        isFirstCardThisTurn = true
        cardsPlayedThisTurn = [:]
        enemyHitTargetID = nil
        playerHitTargetID = nil
        pendingAllyTarget = nil
        hoveredAllyID = nil
        tutorialSteps = []
        tutorialIndex = 0
        tutorialPending = false
        spawnWave(0, seedingPrimaryFrom: nil)
        drawPlayerCards(GameRules.startingHandSize)
        state.phase = .playerMain

        // Re-arm the stage's dialogue for the retry (one-time beats stay
        // spent) and skip straight to the opening lines.
        preStageScene = nil
        narrativePhase = .none
        activeDialogue = nil
        dialogueManager.registerDialogues(registeredDialogues)
        dialogueManager.loadShownKeys()
        dialogueManager.checkTrigger(.battleStart)
    }

    // MARK: - Waves

    /// Puts a wave on the field. The primary can be seeded from a saved
    /// `CombatantState` (test hook) so its health and shield carry over.
    private func spawnWave(_ index: Int, seedingPrimaryFrom seed: CombatantState?) {
        waveIndex = index
        let wave = configuration.waves[index]
        var line: [EnemyCombatant] = []
        var usedIDs = Set<UUID>()

        for (slot, enemy) in wave.enemies.enumerated() {
            var id = enemy.id
            if usedIDs.contains(id) { id = UUID() }
            usedIDs.insert(id)

            var health = enemy.maxHealth
            var shield = wave.openingShield(at: slot)
            if slot == 0, let seed {
                health = seed.currentHealth
                shield = seed.shield
            }
            let fraction = enemy.maxHealth > 0 ? Double(health) / Double(enemy.maxHealth) : 0
            let brain = EnemyBrain(pattern: enemy.pattern, turn: state.turnNumber, healthFraction: fraction)
            line.append(
                EnemyCombatant(
                    id: id,
                    enemy: enemy,
                    health: health,
                    shield: shield,
                    brain: brain,
                    isPrimary: slot == 0
                )
            )
        }

        enemyLine = line
        targetedEnemyID = line.first?.id ?? targetedEnemyID
        enemyHitTargetID = nil
        lastEnemyHealthPercent = 100
        syncPrimaryMirror()

        // A hero the story promised rides in with this wave.
        if let guest = wave.allyReinforcement, !party.contains(where: { $0.id == guest.id }) {
            party.append(PartyMember(hero: guest, health: guest.maxHealth))
            if index > 0 {
                showNotice("\(guest.name) joins the fight")
                emitSound("ally arrives")
            }
        }
    }

    private func beginNextWave() {
        spawnWave(waveIndex + 1, seedingPrimaryFrom: nil)
        waveTrigger += 1
        let name = primaryEnemy?.name ?? "The enemy"
        showNotice("Wave \(waveIndex + 1) of \(waveCount) — \(name) approaches")
        emitSound("new wave")
        dialogueManager.checkWaveStart(waveIndex: waveIndex)
    }

    // MARK: - Effect resolution

    private func resolve(_ effect: Effect, from card: Card, zoneAtPlay: LucidityZone) {
        var value = effect.resolvedValue(cardType: card.cardType, zone: zoneAtPlay)
        value = applyPassiveBonuses(to: value, effectType: effect.type, cardType: card.cardType, zone: zoneAtPlay)

        switch effect.type {
        case .damage:
            dealDamageToEnemy(value)
        case .heal:
            healLead(value)
        case .shield:
            state.player.shield += value
        case .lucidityModify:
            applyPlayerLucidityDelta(value)
        case .lucidityCenter:
            setPlayerLucidity(Self.shifted(state.player.lucidity, towardCenterBy: value))
        case .drawCards:
            drawPlayerCards(value)
        case .swapLead:
            if let target = resolvingAllyTarget {
                switchActiveHero(to: target)
            }
        }
    }

    /// Applies hero passive bonuses to an effect value.
    ///
    /// - `vividFury`: bonus damage while Vivid (Lancelot)
    /// - `growingMight`: bonus damage per turn (Escanor)
    /// - `driftingBulwark`: bonus shield while Drifting
    private func applyPassiveBonuses(to value: Int, effectType: EffectType, cardType: CardType, zone: LucidityZone) -> Int {
        var modified = value

        for hero in activeHeroes {
            switch hero.passive.kind {
            case .vividFury(let amount):
                if effectType == .damage && cardType == .offensive && zone == .vivid {
                    modified += amount
                }
            case .growingMight(let perTurn):
                if effectType == .damage {
                    modified += perTurn * (currentTurnForPassives - 1)
                }
            case .driftingBulwark(let amount):
                if effectType == .shield && zone == .drifting {
                    modified += amount
                }
            default:
                break
            }
        }

        return modified
    }

    private func applyPlayerLucidityDelta(_ delta: Int) {
        setPlayerLucidity(state.player.lucidity + delta)
    }

    /// The single write path for the player's lucidity: clamps the value,
    /// emits the sharpen/soften pulse, and announces zone transitions.
    private func setPlayerLucidity(_ newValue: Int) {
        let oldValue = state.player.lucidity
        let clamped = GameRules.clampLucidity(newValue)
        guard clamped != oldValue else { return }

        let oldZone = LucidityZone.zone(for: oldValue)
        state.player.lucidity = clamped

        firePulse(direction: clamped > oldValue ? .sharpen : .soften)

        let newZone = LucidityZone.zone(for: clamped)
        if newZone != oldZone {
            announceZoneEntry(newZone)
        }
    }

    private func firePulse(direction: LucidityPulse.Direction) {
        let pulse = LucidityPulse(direction: direction)
        lucidityPulse = pulse
        Task {
            try? await Task.sleep(for: .milliseconds(650))
            if lucidityPulse?.id == pulse.id { lucidityPulse = nil }
        }
    }

    private func announceZoneEntry(_ zone: LucidityZone) {
        // Lose zones end the duel; the game-over overlay is the notification.
        guard !zone.isLoseCondition else { return }

        let message: String
        switch zone {
        case .drifting: message = "Entering Drifting Zone — Defensive +20%"
        case .vivid: message = "Entering Vivid Zone — Offensive +20%"
        case .balanced: message = "Entering Balanced Zone — Steady"
        case .deepSleep, .awakening: return
        }

        let notification = ZoneNotification(zone: zone, message: message)
        zoneNotification = notification
        emitSound("zone shift")
        Task {
            try? await Task.sleep(for: .milliseconds(2200))
            if zoneNotification?.id == notification.id { zoneNotification = nil }
        }
    }

    private func showNotice(_ text: String) {
        let notice = BattleNotice(text: text)
        battleNotice = notice
        Task {
            try? await Task.sleep(for: .milliseconds(2400))
            if battleNotice?.id == notice.id { battleNotice = nil }
        }
    }

    /// Sound placeholder: flashes a "♪" chip where a sound would play.
    private func emitSound(_ label: String) {
        let cue = SoundCue(label: label)
        soundCue = cue
        Task {
            try? await Task.sleep(for: .milliseconds(1300))
            if soundCue?.id == cue.id { soundCue = nil }
        }
    }

    private func dealDamageToEnemy(_ amount: Int) {
        guard let index = enemyLine.firstIndex(where: { $0.id == targetedEnemyID && !$0.isDown })
                ?? enemyLine.firstIndex(where: { !$0.isDown }) else { return }

        let absorbed = min(enemyLine[index].shield, amount)
        enemyLine[index].shield -= absorbed
        enemyLine[index].health = max(0, enemyLine[index].health - (amount - absorbed))

        let hit = HitEvent(amount: amount, absorbed: absorbed)
        enemyHit = hit
        enemyHitTargetID = enemyLine[index].id
        scheduleHitClear(id: hit.id, isEnemy: true)

        if enemyLine[index].isDown {
            emitSound("enemy falls")
            if let primary = enemyLine.first(where: { $0.isPrimary && !$0.isDown }) {
                targetedEnemyID = primary.id
            } else if let next = enemyLine.first(where: { !$0.isDown }) {
                targetedEnemyID = next.id
            }
        }

        syncPrimaryMirror()
        if enemyLine[index].isPrimary {
            checkEnemyHealthDialogues()
        }
    }

    /// Enemy damage lands on whoever leads the team. The shared shield
    /// absorbs first. If the lead falls, the next living teammate steps
    /// forward; the battle is lost only when nobody is left standing.
    private func dealDamageToPlayer(_ amount: Int) {
        let reducedAmount = applyDamageReductionPassives(to: amount)

        let absorbed = min(state.player.shield, reducedAmount)
        state.player.shield -= absorbed
        let remainder = reducedAmount - absorbed

        let hit = HitEvent(amount: reducedAmount, absorbed: absorbed)
        playerHit = hit
        playerHitTargetID = activeAllyID
        scheduleHitClear(id: hit.id, isEnemy: false)

        guard let index = party.firstIndex(where: { $0.id == activeAllyID }) else { return }
        party[index].health = max(0, party[index].health - remainder)
        syncLeadMirror()

        if party[index].isDown {
            let fallen = party[index].hero.name
            if let next = party.first(where: { !$0.isDown }) {
                activeAllyID = next.id
                heroSwitchTrigger += 1
                syncLeadMirror()
                showNotice("\(fallen) falls — \(next.hero.name) steps forward")
                emitSound("hero falls")
            }
        }
    }

    /// Applies damage reduction passives to incoming damage.
    ///
    /// - `balancedResilience`: reduce damage by percent while Balanced (Bedivere)
    private func applyDamageReductionPassives(to damage: Int) -> Int {
        var reduced = damage

        for hero in activeHeroes {
            if case .balancedResilience(let percent) = hero.passive.kind {
                if state.player.zone == .balanced {
                    let reduction = Double(damage) * Double(percent) / 100.0
                    reduced = max(0, damage - Int(reduction.rounded()))
                }
            }
        }

        return reduced
    }

    private func healLead(_ amount: Int) {
        guard let index = party.firstIndex(where: { $0.id == activeAllyID }) else { return }
        let maxHealth = party[index].hero.maxHealth
        party[index].health = min(maxHealth, party[index].health + amount)
        syncLeadMirror()
    }

    /// Mirrors the lead hero's health into `GameState` so the serializable
    /// snapshot (and its end-condition checks) stays truthful.
    private func syncLeadMirror() {
        if let lead = party.first(where: { $0.id == activeAllyID }) {
            state.player.currentHealth = lead.health
        } else {
            state.player.currentHealth = 0
        }
    }

    /// Mirrors the primary enemy's health and shield into `GameState`.
    private func syncPrimaryMirror() {
        guard let primary = enemyLine.first(where: { $0.isPrimary }) else { return }
        state.enemy.currentHealth = primary.health
        state.enemy.shield = primary.shield
    }

    private func drawPlayerCards(_ count: Int) {
        for _ in 0..<max(0, count) {
            guard state.player.hand.count < GameRules.maxHandSize else { return }
            if state.player.deck.isEmpty {
                guard !state.player.discardPile.isEmpty else { return }
                state.player.deck = state.player.discardPile.shuffled()
                state.player.discardPile = []
            }
            if let top = state.player.deck.popLast() {
                state.player.hand.append(top)
            }
        }
    }

    /// Evaluates end conditions in priority order: Lucidity losses first
    /// (overextending on the killing blow still costs the game), then the
    /// party falling, then a cleared final wave.
    private func evaluateOutcome() -> GameOutcome {
        if state.player.hasLostByLucidity {
            return .lostToLucidity(zone: state.player.zone)
        }
        if party.allSatisfy({ $0.isDown }) {
            return .defeated
        }
        if enemyLine.allSatisfy({ $0.isDown }) && !hasMoreWaves {
            return .victory
        }
        return .ongoing
    }

    private func refreshOutcome() {
        let outcome = evaluateOutcome()
        if outcome == .ongoing {
            if enemyLine.allSatisfy({ $0.isDown }) && hasMoreWaves {
                beginNextWave()
            }
            return
        }

        state.outcome = outcome
        state.phase = .gameOver
        selectedInstanceID = nil
        switch outcome {
        case .victory:
            emitSound("victory chime")
            triggerVictoryNarrative()
        case .lostToLucidity(let zone):
            emitSound(zone == .awakening ? "alarm blare" : "fading hum")
        case .defeated:
            emitSound("defeat toll")
        case .ongoing:
            break
        }
    }

    // MARK: - Enemy turn

    private func resolveEnemyTurn() async {
        // "Enemy thinking…" beat before it acts.
        isEnemyThinking = true
        try? await Task.sleep(for: .seconds(1))
        isEnemyThinking = false
        guard state.phase == .enemyTurn else { return }

        var hasActed = false
        for index in enemyLine.indices where !enemyLine[index].isDown {
            if hasActed {
                try? await Task.sleep(for: .milliseconds(500))
                guard state.phase == .enemyTurn else { return }
            }
            hasActed = true

            // A combatant's shield lasts until the start of its own next turn.
            enemyLine[index].shield = 0
            actingEnemyID = enemyLine[index].id
            enemyActionTrigger += 1

            let move = enemyLine[index].brain.execute()
            switch move {
            case .attack(let amount):
                dealDamageToPlayer(amount)
                emitSound("enemy strike")
            case .brace(let shield):
                enemyLine[index].shield += shield
                emitSound("enemy braces")
            case .buff(let buff):
                emitSound(EnemyBrain.label(for: buff).lowercased())
            }

            syncPrimaryMirror()
            refreshOutcome()
            guard state.outcome == .ongoing else { return }
        }

        actingEnemyID = nil
        try? await Task.sleep(for: .milliseconds(600))
        guard state.phase == .enemyTurn else { return }
        beginPlayerTurn()
    }

    private func beginPlayerTurn() {
        state.turnNumber += 1
        state.player.shield = 0
        isFirstCardThisTurn = true
        cardsPlayedThisTurn = [:]

        // The lantern's steady pull toward Balanced.
        if configuration.lanternDrift > 0 {
            setPlayerLucidity(Self.shifted(state.player.lucidity, towardCenterBy: configuration.lanternDrift))
        }

        applyTurnStartPassives()
        dialogueManager.checkTurnNumber(state.turnNumber)

        drawPlayerCards(GameRules.cardsDrawnPerTurn)
        applyBonusCardDrawPassives()
        topUpHand()
        emitSound("card drawn")

        // Every living enemy telegraphs its next move.
        for index in enemyLine.indices where !enemyLine[index].isDown {
            let fraction = enemyLine[index].healthFraction
            enemyLine[index].brain.plan(turn: state.turnNumber, healthFraction: fraction)
        }

        state.phase = .playerMain
        tutorialEvent(.enemyTurnDone)
    }

    /// Applies passives that trigger at the start of the player's turn.
    ///
    /// - `lucidityDrift`: drift toward center (the Dreamer)
    /// - `purityHealing`: heal if no debuffs (Galahad)
    private func applyTurnStartPassives() {
        for hero in activeHeroes {
            switch hero.passive.kind {
            case .lucidityDrift(let amount):
                setPlayerLucidity(Self.shifted(state.player.lucidity, towardCenterBy: amount))
            case .purityHealing(let amount):
                // Debuffs are not implemented yet, so the hero is always pure.
                healLead(amount)
            default:
                break
            }
        }
    }

    /// Applies bonus card draw passives (Archimedes).
    private func applyBonusCardDrawPassives() {
        for hero in activeHeroes {
            if case .bonusCardDraw(let amount) = hero.passive.kind {
                drawPlayerCards(amount)
            }
        }
    }

    /// The smallest hand the player starts a turn with: the rule's minimum
    /// plus any draw passive the lead carries.
    var minimumHandSize: Int {
        var minimum = GameRules.minimumHandSize
        for hero in activeHeroes {
            if case .bonusCardDraw(let amount) = hero.passive.kind {
                minimum += amount
            }
        }
        return minimum
    }

    /// Draws until the hand reaches `minimumHandSize` (deck permitting).
    private func topUpHand() {
        let shortfall = minimumHandSize - state.player.hand.count
        if shortfall > 0 {
            drawPlayerCards(shortfall)
        }
    }

    // MARK: - Helpers

    private func scheduleHitClear(id: UUID, isEnemy: Bool) {
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            if isEnemy {
                if enemyHit?.id == id { enemyHit = nil }
            } else if playerHit?.id == id {
                playerHit = nil
            }
        }
    }

    /// The sandbox Nightmare's rhythm: 8–15 random damage each turn, with a
    /// telegraphed 20-damage heavy blow every third turn.
    static func intent(forTurn turn: Int) -> EnemyIntent {
        if turn % GameRules.enemyHeavyTurnInterval == 0 {
            return .attack(GameRules.enemyHeavyAttackDamage)
        }
        return .attack(Int.random(in: GameRules.enemyAttackRange))
    }

    /// Moves a lucidity value toward 50 by up to `amount`, never overshooting.
    static func shifted(_ lucidity: Int, towardCenterBy amount: Int) -> Int {
        let center = GameRules.startingLucidity
        if lucidity > center { return max(center, lucidity - amount) }
        if lucidity < center { return min(center, lucidity + amount) }
        return lucidity
    }

    /// A `Hero` stand-in for the primary enemy so `GameState.newGame` can
    /// mirror its health.
    private static func mirrorHero(for enemy: Enemy) -> Hero {
        Hero(
            id: enemy.id,
            name: enemy.name,
            maxHealth: enemy.maxHealth,
            passive: enemy.passive ?? PassiveAbility(name: "None", text: "", kind: .none),
            cardIDs: []
        )
    }

    private static func freshDuel(for configuration: BattleConfiguration) -> GameState {
        let primary = configuration.waves[0].enemies[0]
        return GameState.newGame(
            playerHero: configuration.party[0],
            enemyHero: mirrorHero(for: primary),
            playerDeck: configuration.freshDeck().shuffled(),
            enemyDeck: []
        )
    }
}
