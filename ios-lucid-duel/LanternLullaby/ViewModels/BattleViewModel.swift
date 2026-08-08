import CoreGraphics
import Foundation
import Observation

/// What the enemy plans to do next turn (telegraphed to the player).
nonisolated enum EnemyIntent: Hashable, Sendable {
    case attack(Int)
    case brace(Int)
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

/// The battle engine: owns the mutable `GameState` and enforces every rule
/// of card play, lucidity movement, zone bonuses, and turn flow.
@Observable
final class BattleViewModel {
    private(set) var state: GameState
    private(set) var selectedInstanceID: CardInstance.ID?
    private(set) var enemyIntent: EnemyIntent
    private(set) var enemyHit: HitEvent?
    private(set) var playerHit: HitEvent?

    /// Banner shown when the meter crosses into a new zone; auto-clears.
    private(set) var zoneNotification: ZoneNotification?

    /// Direction cue for the last lucidity movement; auto-clears.
    private(set) var lucidityPulse: LucidityPulse?

    /// Increments on every card play; drives impact haptics.
    private(set) var playImpactTrigger: Int = 0

    /// Increments when the enemy acts; drives the enemy panel pulse.
    private(set) var enemyActionTrigger: Int = 0

    /// True during the enemy's 1-second "thinking" beat.
    private(set) var isEnemyThinking: Bool = false

    /// The sound that would play right now (placeholder); auto-clears.
    private(set) var soundCue: SoundCue?

    /// Placeholder teammates for the team layout (mockup; not yet playable).
    private(set) var supportAllies: [AllyMember]

    /// Placeholder extra enemies. They keep local health so targeting them
    /// works, but only the primary enemy decides the duel.
    private(set) var supportEnemies: [EnemyMember]

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

    let playerHero: Hero
    let enemyHero: Hero
    private let cardsByID: [Card.ID: Card]

    /// - Parameter initialState: test hook; when `nil` a fresh shuffled duel
    ///   is created and the opening hand is drawn.
    init(initialState: GameState? = nil) {
        let player = CardCatalog.dreamer
        let enemy = CardCatalog.nightmare
        playerHero = player
        enemyHero = enemy
        cardsByID = Dictionary(uniqueKeysWithValues: CardCatalog.allCards.map { ($0.id, $0) })
        supportAllies = Self.placeholderAllies()
        supportEnemies = Self.placeholderEnemies()
        targetedEnemyID = enemy.id
        activeAllyID = player.id

        if let initialState {
            state = initialState
            enemyIntent = Self.intent(forTurn: initialState.turnNumber)
        } else {
            state = Self.freshDuel(playerHero: player, enemyHero: enemy)
            enemyIntent = Self.intent(forTurn: 1)
            drawPlayerCards(GameRules.startingHandSize)
            state.phase = .playerMain
        }
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

    /// True when the player's current zone boosts this card by +20%.
    func isBonusActive(for card: Card) -> Bool {
        let zone = state.player.zone
        return (card.cardType == .offensive && zone == .vivid)
            || (card.cardType == .defensive && zone == .drifting)
    }

    /// Lucidity cost after the player hero's passive discounts.
    func effectiveCost(of card: Card) -> Int {
        if case .cheaperLucidityCosts(let amount) = playerHero.passive.kind {
            return max(0, card.lucidityCost - amount)
        }
        return card.lucidityCost
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

    // MARK: - Team roster (layout mockup)

    /// The player's three-hero row. Slot one mirrors live engine state; the
    /// others keep local placeholder health. The gold ring follows
    /// `activeAllyID`.
    var allies: [AllyMember] {
        let dreamer = AllyMember(
            id: playerHero.id,
            name: playerHero.name,
            iconName: "moon.stars.fill",
            artName: "dreamer_child_portrait",
            fullBodyArtName: "child_with_lantern",
            health: state.player.currentHealth,
            maxHealth: playerHero.maxHealth,
            shield: state.player.shield,
            passiveName: playerHero.passive.name,
            passiveText: playerHero.passive.text,
            isActive: false
        )
        return ([dreamer] + supportAllies).map { ally in
            var member = ally
            member.isActive = ally.id == activeAllyID
            return member
        }
    }

    /// The enemy row: the live primary enemy plus placeholder minions.
    var enemies: [EnemyMember] {
        let primary = EnemyMember(
            id: enemyHero.id,
            name: enemyHero.name,
            iconName: "theatermasks.fill",
            artName: "nightmare_shadow_mask",
            fullBodyArtName: "shadow_villain_cloak",
            maxHealth: enemyHero.maxHealth,
            health: state.enemy.currentHealth,
            shield: state.enemy.shield,
            intent: enemyIntent,
            isPrimary: true
        )
        return [primary] + supportEnemies
    }

    // MARK: - Hero switching

    /// Puts a living teammate in the lead. Free action: no turn, no
    /// Lucidity. The shared hand stays as-is (per-hero decks come later).
    func switchActiveHero(to id: UUID) {
        guard state.outcome == .ongoing,
              id != activeAllyID,
              let ally = allies.first(where: { $0.id == id }),
              ally.health > 0 else { return }

        activeAllyID = id
        heroSwitchTrigger += 1
        emitSound("hero switch")
    }

    // MARK: - Targeting (layout mockup)

    /// True while an offensive card is selected — enemies light up as targets.
    var isTargetingActive: Bool {
        guard state.phase == .playerMain, let card = selectedCard else { return false }
        return cardDealsDamage(card)
    }

    var targetedEnemyName: String {
        enemies.first { $0.id == targetedEnemyID }?.name ?? enemyHero.name
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
        guard let member = enemies.first(where: { $0.id == id }), member.health > 0 else { return }

        if isTargetingActive, targetedEnemyID == id, let card = selectedCard, card.choices == nil {
            playSelectedCard()
            return
        }
        targetedEnemyID = id
    }

    // MARK: - Drag-and-drop play

    /// True while a card is being dragged out of the hand.
    private(set) var isDraggingCard = false

    /// Battlefield frames reported by enemy figures (global space), used
    /// to hit-test card drops. Read only inside gestures — not observed.
    @ObservationIgnored private var enemyFrames: [UUID: CGRect] = [:]

    func reportEnemyFrame(_ id: UUID, frame: CGRect) {
        enemyFrames[id] = frame
    }

    /// The living enemy under a drag location, front-most first.
    func enemyID(at point: CGPoint) -> UUID? {
        for enemy in enemies where enemy.health > 0 {
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
        guard state.phase == .playerMain else { return }
        selectedInstanceID = instance.id
        isDraggingCard = true
    }

    func endCardDrag() {
        isDraggingCard = false
    }

    /// Aims the dragged card at an enemy while hovering over it.
    func hoverEnemy(_ id: UUID) {
        guard let member = enemies.first(where: { $0.id == id }), member.health > 0 else { return }
        targetedEnemyID = id
    }

    // MARK: - Player actions

    func toggleSelection(of instance: CardInstance) {
        guard state.phase == .playerMain else { return }
        selectedInstanceID = selectedInstanceID == instance.id ? nil : instance.id
    }

    func clearSelection() {
        selectedInstanceID = nil
    }

    /// Resolves the selected card: cost first, then base effects in order,
    /// then the chosen branch (for dual-direction cards), then the card
    /// moves to the discard pile and end conditions are checked.
    ///
    /// - Parameter choice: required when the card carries `choices`; playing
    ///   a dual-direction card without picking a branch is a no-op.
    func playSelectedCard(choice: CardChoiceOption? = nil) {
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

        for effect in card.effects + (choice?.effects ?? []) {
            resolve(effect, from: card, zoneAtPlay: zoneAtPlay)
        }

        playImpactTrigger += 1
        emitSound("card played")
        refreshOutcome()
    }

    func endTurn() {
        guard state.phase == .playerMain, state.outcome == .ongoing else { return }
        selectedInstanceID = nil
        state.phase = .enemyTurn
        Task { await resolveEnemyTurn() }
    }

    func startNewDuel() {
        state = Self.freshDuel(playerHero: playerHero, enemyHero: enemyHero)
        selectedInstanceID = nil
        enemyHit = nil
        playerHit = nil
        zoneNotification = nil
        lucidityPulse = nil
        soundCue = nil
        isEnemyThinking = false
        supportAllies = Self.placeholderAllies()
        supportEnemies = Self.placeholderEnemies()
        targetedEnemyID = enemyHero.id
        enemyHitTargetID = nil
        activeAllyID = playerHero.id
        playerHitTargetID = nil
        enemyIntent = Self.intent(forTurn: 1)
        drawPlayerCards(GameRules.startingHandSize)
        state.phase = .playerMain
    }

    // MARK: - Effect resolution

    private func resolve(_ effect: Effect, from card: Card, zoneAtPlay: LucidityZone) {
        let value = effect.resolvedValue(cardType: card.cardType, zone: zoneAtPlay)
        switch effect.type {
        case .damage:
            dealDamageToEnemy(value)
        case .heal:
            state.player.currentHealth = min(playerHero.maxHealth, state.player.currentHealth + value)
        case .shield:
            state.player.shield += value
        case .lucidityModify:
            applyPlayerLucidityDelta(value)
        case .lucidityCenter:
            setPlayerLucidity(Self.shifted(state.player.lucidity, towardCenterBy: value))
        case .drawCards:
            drawPlayerCards(value)
        }
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
        // Placeholder minion target: local bookkeeping only (layout mockup).
        if let index = supportEnemies.firstIndex(where: { $0.id == targetedEnemyID }) {
            var minion = supportEnemies[index]
            let absorbed = min(minion.shield, amount)
            minion.shield -= absorbed
            minion.health = max(0, minion.health - (amount - absorbed))
            supportEnemies[index] = minion

            let hit = HitEvent(amount: amount, absorbed: absorbed)
            enemyHit = hit
            enemyHitTargetID = minion.id
            scheduleHitClear(id: hit.id, isEnemy: true)

            if minion.health == 0 { targetedEnemyID = enemyHero.id }
            return
        }

        let absorbed = min(state.enemy.shield, amount)
        state.enemy.shield -= absorbed
        state.enemy.currentHealth = max(0, state.enemy.currentHealth - (amount - absorbed))
        let hit = HitEvent(amount: amount, absorbed: absorbed)
        enemyHit = hit
        enemyHitTargetID = enemyHero.id
        scheduleHitClear(id: hit.id, isEnemy: true)
    }

    /// Enemy damage lands on whoever leads the team. The shared shield
    /// absorbs first either way. If a teammate falls, the Dreamer retakes
    /// the lead; the duel is only lost when the Dreamer falls (engine rule).
    private func dealDamageToPlayer(_ amount: Int) {
        let absorbed = min(state.player.shield, amount)
        state.player.shield -= absorbed
        let remainder = amount - absorbed

        let hit = HitEvent(amount: amount, absorbed: absorbed)
        playerHit = hit
        playerHitTargetID = activeAllyID
        scheduleHitClear(id: hit.id, isEnemy: false)

        if let index = supportAllies.firstIndex(where: { $0.id == activeAllyID }) {
            supportAllies[index].health = max(0, supportAllies[index].health - remainder)
            if supportAllies[index].health == 0 {
                activeAllyID = playerHero.id
            }
            return
        }

        state.player.currentHealth = max(0, state.player.currentHealth - remainder)
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

    private func refreshOutcome() {
        state.outcome = state.resolvedOutcome
        if state.outcome != .ongoing {
            state.phase = .gameOver
            selectedInstanceID = nil
            switch state.outcome {
            case .victory:
                emitSound("victory chime")
            case .lostToLucidity(let zone):
                emitSound(zone == .awakening ? "alarm blare" : "fading hum")
            case .defeated:
                emitSound("defeat toll")
            case .ongoing:
                break
            }
        }
    }

    // MARK: - Enemy turn

    private func resolveEnemyTurn() async {
        // "Enemy thinking…" beat before it acts.
        isEnemyThinking = true
        try? await Task.sleep(for: .seconds(1))
        isEnemyThinking = false
        guard state.phase == .enemyTurn else { return }

        // A combatant's shield lasts until the start of its own next turn.
        state.enemy.shield = 0

        enemyActionTrigger += 1

        switch enemyIntent {
        case .attack(let amount):
            dealDamageToPlayer(amount)
            emitSound("enemy strike")
        case .brace(let amount):
            state.enemy.shield += amount
            emitSound("enemy braces")
        }

        refreshOutcome()
        guard state.outcome == .ongoing else { return }

        try? await Task.sleep(for: .milliseconds(600))
        beginPlayerTurn()
    }

    private func beginPlayerTurn() {
        state.turnNumber += 1
        state.player.shield = 0
        if case .lucidityDrift(let amount) = playerHero.passive.kind {
            setPlayerLucidity(Self.shifted(state.player.lucidity, towardCenterBy: amount))
        }
        drawPlayerCards(GameRules.cardsDrawnPerTurn)
        emitSound("card drawn")
        enemyIntent = Self.intent(forTurn: state.turnNumber)
        state.phase = .playerMain
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

    /// Simple MVP AI: 8–15 random damage each turn, with a telegraphed
    /// 20-damage heavy blow every third turn.
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

    /// Fixed-identity placeholder teammates (stable across restarts).
    private static func placeholderAllies() -> [AllyMember] {
        [
            AllyMember(
                id: UUID(uuidString: "AA000000-0000-0000-0000-000000000001")!,
                name: "Sleepwalker",
                iconName: "figure.walk",
                artName: "sleepwalker_child",
                fullBodyArtName: "sleepwalker_child_2",
                health: 38,
                maxHealth: 48,
                shield: 0,
                passiveName: "Light Step",
                passiveText: "Takes 2 less damage while in the Drifting zone.",
                isActive: false
            ),
            AllyMember(
                id: UUID(uuidString: "AA000000-0000-0000-0000-000000000002")!,
                name: "Ember Muse",
                iconName: "flame.fill",
                artName: "ember_muse_portrait",
                fullBodyArtName: "ember_fire_spirit_child",
                health: 52,
                maxHealth: 52,
                shield: 0,
                passiveName: "Kindled Verse",
                passiveText: "Offensive cards deal 2 extra damage while Vivid.",
                isActive: false
            ),
        ]
    }

    /// Fixed-identity placeholder minions flanking the primary enemy.
    private static func placeholderEnemies() -> [EnemyMember] {
        [
            EnemyMember(
                id: UUID(uuidString: "EE000000-0000-0000-0000-000000000001")!,
                name: "Night Shade",
                iconName: "cloud.fog.fill",
                artName: "shadow_creature_fog",
                fullBodyArtName: "night_shade_fog_creature",
                maxHealth: 30,
                health: 30,
                shield: 0,
                intent: .attack(6),
                isPrimary: false
            ),
            EnemyMember(
                id: UUID(uuidString: "EE000000-0000-0000-0000-000000000002")!,
                name: "Dread Wisp",
                iconName: "wind",
                artName: "dread_wisp_spirit",
                fullBodyArtName: "dread_wisp_spirit_2",
                maxHealth: 22,
                health: 22,
                shield: 5,
                intent: .brace(5),
                isPrimary: false
            ),
        ]
    }

    private static func freshDuel(playerHero: Hero, enemyHero: Hero) -> GameState {
        GameState.newGame(
            playerHero: playerHero,
            enemyHero: enemyHero,
            playerDeck: CardCatalog.starterDeck().shuffled(),
            enemyDeck: []
        )
    }
}
