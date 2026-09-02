//
//  LanternLullabyTests.swift
//  LanternLullabyTests
//
//  Created by Rork on August 8, 2026.
//

import Testing
import Foundation
@testable import LanternLullaby

struct LucidityZoneTests {

    @Test func zoneBoundariesMatchSpec() {
        #expect(LucidityZone.zone(for: 0) == .deepSleep)
        #expect(LucidityZone.zone(for: 15) == .deepSleep)
        #expect(LucidityZone.zone(for: 16) == .drifting)
        #expect(LucidityZone.zone(for: 35) == .drifting)
        #expect(LucidityZone.zone(for: 36) == .balanced)
        #expect(LucidityZone.zone(for: 50) == .balanced)
        #expect(LucidityZone.zone(for: 65) == .balanced)
        #expect(LucidityZone.zone(for: 66) == .vivid)
        #expect(LucidityZone.zone(for: 85) == .vivid)
        #expect(LucidityZone.zone(for: 86) == .awakening)
        #expect(LucidityZone.zone(for: 100) == .awakening)
    }

    @Test func extremesAreLoseConditions() {
        #expect(LucidityZone.deepSleep.isLoseCondition)
        #expect(LucidityZone.awakening.isLoseCondition)
        #expect(!LucidityZone.drifting.isLoseCondition)
        #expect(!LucidityZone.balanced.isLoseCondition)
        #expect(!LucidityZone.vivid.isLoseCondition)
    }

    @Test func overshootClampsIntoLoseZones() {
        #expect(LucidityZone.zone(for: GameRules.clampLucidity(-10)) == .deepSleep)
        #expect(LucidityZone.zone(for: GameRules.clampLucidity(140)) == .awakening)
    }
}

struct EffectResolutionTests {

    @Test func vividBoostsOffensiveDamage() {
        let strike = Effect(type: .damage, value: 10)
        #expect(strike.resolvedValue(cardType: .offensive, zone: .vivid) == 12)
        #expect(strike.resolvedValue(cardType: .offensive, zone: .balanced) == 10)
        #expect(strike.resolvedValue(cardType: .defensive, zone: .vivid) == 10)
    }

    @Test func driftingBoostsDefensiveShield() {
        let ward = Effect(type: .shield, value: 5)
        #expect(ward.resolvedValue(cardType: .defensive, zone: .drifting) == 6)
        #expect(ward.resolvedValue(cardType: .defensive, zone: .balanced) == 5)
        #expect(ward.resolvedValue(cardType: .offensive, zone: .drifting) == 5)
    }

    @Test func meterAndDrawEffectsAreNeverScaled() {
        let relax = Effect(type: .lucidityModify, value: -8)
        let draw = Effect(type: .drawCards, value: 2)
        let center = Effect(type: .lucidityCenter, value: 5)
        #expect(relax.resolvedValue(cardType: .defensive, zone: .drifting) == -8)
        #expect(draw.resolvedValue(cardType: .offensive, zone: .vivid) == 2)
        #expect(center.resolvedValue(cardType: .utility, zone: .vivid) == 5)
    }
}

struct CardModelTests {

    @Test func netLucidityShiftCombinesCostAndRelax() {
        let card = Card(
            id: UUID(),
            name: "Slow Breath",
            text: "Gain 4 shield. Reduce Lucidity by 7.",
            lucidityCost: 3,
            cardType: .defensive,
            effects: [
                Effect(type: .shield, value: 4),
                Effect(type: .lucidityModify, value: -7),
            ],
            heroID: nil
        )
        #expect(card.netLucidityShift == -4)
    }

    @Test func enemyCatalogIDsAreUnique() {
        let ids = EnemyCatalogBook1.allEnemies.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func catalogCardIDsAreUnique() {
        let ids = CardCatalog.allCards.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func starterDeckHasEighteenUniqueInstances() {
        let deck = CardCatalog.starterDeck()
        #expect(deck.count == 18)
        #expect(Set(deck.map(\.id)).count == 18)
        #expect(deck.allSatisfy { CardCatalog.card(withID: $0.cardID) != nil })
    }

    @Test func focusedMindCarriesTwoChoices() {
        let choices = CardCatalog.focusedMind.choices
        #expect(choices?.count == 2)
        #expect(choices?.map(\.id) == ["concentrate", "relax"])
    }

    @Test func cardWithoutChoicesDecodesFromLegacyJSON() throws {
        // Cards saved before `choices` existed must still decode.
        let data = try JSONEncoder().encode(CardCatalog.strike)
        var json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        json.removeValue(forKey: "choices")
        let stripped = try JSONSerialization.data(withJSONObject: json)
        let decoded = try JSONDecoder().decode(Card.self, from: stripped)
        #expect(decoded.choices == nil)
        #expect(decoded.id == CardCatalog.strike.id)
    }
}

struct GameStateTests {

    private func makeHero(name: String) -> Hero {
        Hero(
            id: UUID(),
            name: name,
            maxHealth: 30,
            passive: PassiveAbility(
                name: "Steady Mind",
                text: "Lucidity drifts 2 toward Balanced each turn.",
                kind: .lucidityDrift(amount: 2)
            ),
            cardIDs: []
        )
    }

    @Test func newGameStartsBalanced() {
        let state = GameState.newGame(
            playerHero: makeHero(name: "Dreamer"),
            enemyHero: makeHero(name: "Nightmare"),
            playerDeck: [],
            enemyDeck: []
        )
        #expect(state.player.lucidity == 50)
        #expect(state.player.zone == .balanced)
        #expect(state.enemy.zone == .balanced)
        #expect(state.resolvedOutcome == .ongoing)
    }

    @Test func lucidityLossBeatsVictoryOnSameResolution() {
        var state = GameState.newGame(
            playerHero: makeHero(name: "Dreamer"),
            enemyHero: makeHero(name: "Nightmare"),
            playerDeck: [],
            enemyDeck: []
        )
        state.enemy.currentHealth = 0
        state.player.lucidity = 90
        #expect(state.resolvedOutcome == .lostToLucidity(zone: .awakening))
    }

    @Test func gameStateRoundTripsThroughCodable() throws {
        let state = GameState.newGame(
            playerHero: makeHero(name: "Dreamer"),
            enemyHero: makeHero(name: "Nightmare"),
            playerDeck: [
                CardInstance(cardID: CardCatalog.strike.id),
                CardInstance(cardID: CardCatalog.deepBreath.id),
            ],
            enemyDeck: [CardInstance(cardID: CardCatalog.strike.id)]
        )
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(GameState.self, from: data)
        #expect(decoded.player.deck == state.player.deck)
        #expect(decoded.player.lucidity == 50)
    }
}

@MainActor
struct BattleEngineTests {

    /// Builds a deterministic mid-duel state with an exact hand.
    private func state(hand cards: [Card], lucidity: Int = 50) -> GameState {
        var state = GameState.newGame(
            playerHero: CardCatalog.dreamer,
            enemyHero: CardCatalog.nightmare,
            playerDeck: CardCatalog.starterDeck(),
            enemyDeck: []
        )
        state.player.hand = cards.map { CardInstance(cardID: $0.id) }
        state.player.lucidity = lucidity
        state.phase = .playerMain
        return state
    }

    private func play(_ card: Card, on viewModel: BattleViewModel, choice: CardChoiceOption? = nil) {
        guard let instance = viewModel.state.player.hand.first(where: { $0.cardID == card.id }) else {
            Issue.record("Card \(card.name) not in hand")
            return
        }
        viewModel.toggleSelection(of: instance)
        viewModel.playSelectedCard(choice: choice)
    }

    private func choice(_ id: String) -> CardChoiceOption? {
        CardCatalog.focusedMind.choices?.first { $0.id == id }
    }

    @Test func strikeDealsDamageAndRaisesLucidity() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth - 15)
        #expect(viewModel.state.player.lucidity == 58)
        #expect(viewModel.state.player.hand.isEmpty)
        #expect(viewModel.state.player.discardPile.count == 1)
    }

    @Test func deepBreathRelaxesForFree() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.deepBreath]))
        play(CardCatalog.deepBreath, on: viewModel)
        #expect(viewModel.state.player.lucidity == 40)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth)
    }

    @Test func vividZoneBoostsOffensiveDamage() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike], lucidity: 70))
        play(CardCatalog.strike, on: viewModel)
        // 15 * 1.2 = 18 damage; lucidity 70 + 8 = 78.
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth - 18)
        #expect(viewModel.state.player.lucidity == 78)
    }

    @Test func driftingZoneBoostsDefensiveShield() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.shieldWall], lucidity: 20))
        play(CardCatalog.shieldWall, on: viewModel)
        // 10 * 1.2 = 12 shield.
        #expect(viewModel.state.player.shield == 12)
    }

    @Test func mentalShiftMovesTowardCenterAfterCost() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.mentalShift], lucidity: 70))
        play(CardCatalog.mentalShift, on: viewModel)
        // 70 + 4 cost = 74, then 5 toward 50 = 69.
        #expect(viewModel.state.player.lucidity == 69)
    }

    @Test func enemyShieldAbsorbsBeforeHealth() {
        var initial = state(hand: [CardCatalog.strike])
        initial.enemy.shield = 6
        let viewModel = BattleViewModel(initialState: initial)
        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.state.enemy.shield == 0)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth - 9)
    }

    @Test func dreamWalkDrawsTwoCards()  {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.dreamWalk]))
        let deckBefore = viewModel.state.player.deck.count
        play(CardCatalog.dreamWalk, on: viewModel)
        #expect(viewModel.state.player.hand.count == 2)
        #expect(viewModel.state.player.deck.count == deckBefore - 2)
    }

    @Test func playingIntoAwakeningEndsTheDuel() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.focusStrike], lucidity: 80))
        play(CardCatalog.focusStrike, on: viewModel)
        // 80 + 12 = 92 → Awakening → immediate loss.
        #expect(viewModel.state.outcome == .lostToLucidity(zone: .awakening))
        #expect(viewModel.state.phase == .gameOver)
    }

    @Test func projectedLucidityMatchesActualResolution() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.mentalShift], lucidity: 70))
        guard let card = viewModel.state.player.hand.first.flatMap({ viewModel.card(for: $0) }) else {
            Issue.record("Missing card")
            return
        }
        let projected = viewModel.projectedLucidity(after: card)
        play(card, on: viewModel)
        #expect(viewModel.state.player.lucidity == projected)
    }

    @Test func focusedMindConcentrateDealsDamageAndRaisesLucidity() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.focusedMind]))
        play(CardCatalog.focusedMind, on: viewModel, choice: choice("concentrate"))
        // Cost 0, then +10 lucidity, then 20 damage (utility — never zone-scaled).
        #expect(viewModel.state.player.lucidity == 60)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth - 20)
        #expect(viewModel.state.player.discardPile.count == 1)
    }

    @Test func focusedMindRelaxHealsAndLowersLucidity() {
        var initial = state(hand: [CardCatalog.focusedMind])
        initial.player.currentHealth = 40
        let viewModel = BattleViewModel(initialState: initial)
        play(CardCatalog.focusedMind, on: viewModel, choice: choice("relax"))
        #expect(viewModel.state.player.lucidity == 42)
        #expect(viewModel.state.player.currentHealth == 50)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth)
    }

    @Test func choiceCardWithoutChoiceIsANoOp() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.focusedMind]))
        play(CardCatalog.focusedMind, on: viewModel)
        // Card stays in hand; nothing resolved.
        #expect(viewModel.state.player.hand.count == 1)
        #expect(viewModel.state.player.lucidity == 50)
        #expect(viewModel.state.player.discardPile.isEmpty)
    }

    @Test func enteringVividFiresZoneNotification() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike], lucidity: 60))
        play(CardCatalog.strike, on: viewModel)
        // 60 + 8 = 68 → Vivid.
        #expect(viewModel.state.player.zone == .vivid)
        #expect(viewModel.zoneNotification?.zone == .vivid)
        #expect(viewModel.zoneNotification?.message.contains("Offensive +20%") == true)
    }

    @Test func lucidityMovementFiresDirectionalPulse() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike, CardCatalog.deepBreath]))
        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.lucidityPulse?.direction == .sharpen)
        play(CardCatalog.deepBreath, on: viewModel)
        #expect(viewModel.lucidityPulse?.direction == .soften)
    }

    @Test func selectionTogglesAndClears() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike, CardCatalog.meditate]))
        let first = viewModel.state.player.hand[0]
        viewModel.toggleSelection(of: first)
        #expect(viewModel.selectedInstanceID == first.id)
        viewModel.toggleSelection(of: first)
        #expect(viewModel.selectedInstanceID == nil)
        viewModel.toggleSelection(of: first)
        viewModel.clearSelection()
        #expect(viewModel.selectedInstanceID == nil)
    }

    @Test func everyThirdTurnIsHeavyAttack() {
        #expect(BattleViewModel.intent(forTurn: 3) == .attack(GameRules.enemyHeavyAttackDamage))
        #expect(BattleViewModel.intent(forTurn: 6) == .attack(GameRules.enemyHeavyAttackDamage))
        #expect(BattleViewModel.intent(forTurn: 9) == .attack(GameRules.enemyHeavyAttackDamage))
    }

    @Test func normalTurnsRollWithinAttackRange() {
        for turn in [1, 2, 4, 5, 7, 8] {
            guard case .attack(let amount) = BattleViewModel.intent(forTurn: turn) else {
                Issue.record("Expected an attack intent on turn \(turn)")
                return
            }
            #expect(GameRules.enemyAttackRange.contains(amount))
        }
    }

    @Test func playingCardEmitsSoundPlaceholder() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        #expect(viewModel.soundCue == nil)
        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.soundCue != nil)
    }

    @Test func lucidityLossEmitsDistinctFailSounds() {
        let awakeningVM = BattleViewModel(initialState: state(hand: [CardCatalog.focusStrike], lucidity: 80))
        play(CardCatalog.focusStrike, on: awakeningVM)
        #expect(awakeningVM.soundCue?.label == "alarm blare")

        let sleepVM = BattleViewModel(initialState: state(hand: [CardCatalog.deepBreath], lucidity: 22))
        play(CardCatalog.deepBreath, on: sleepVM)
        // 22 − 10 = 12 → Deep Sleep.
        #expect(sleepVM.state.outcome == .lostToLucidity(zone: .deepSleep))
        #expect(sleepVM.soundCue?.label == "fading hum")
    }

    // MARK: - Team layout & targeting (mockup)

    @Test func rosterShowsThreeAlliesAndThreeEnemies() {
        let viewModel = BattleViewModel(initialState: state(hand: []))
        #expect(viewModel.allies.count == 3)
        #expect(viewModel.allies.first?.isActive == true)
        #expect(viewModel.allies.filter { $0.isActive }.count == 1)
        #expect(viewModel.enemies.count == 3)
        #expect(viewModel.enemies.first?.isPrimary == true)
    }

    @Test func defaultTargetIsPrimaryEnemy() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        #expect(viewModel.targetedEnemyID == CardCatalog.nightmare.id)
    }

    @Test func targetingActivatesOnlyForDamageCards() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike, CardCatalog.meditate]))
        #expect(!viewModel.isTargetingActive)

        let strike = viewModel.state.player.hand.first { $0.cardID == CardCatalog.strike.id }
        viewModel.toggleSelection(of: strike!)
        #expect(viewModel.isTargetingActive)

        let meditate = viewModel.state.player.hand.first { $0.cardID == CardCatalog.meditate.id }
        viewModel.toggleSelection(of: meditate!)
        #expect(!viewModel.isTargetingActive)
    }

    @Test func tappingMinionRetargetsAndRoutesDamageLocally() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        guard let minion = viewModel.enemies.first(where: { !$0.isPrimary }) else {
            Issue.record("Missing placeholder minion")
            return
        }
        viewModel.tapEnemy(minion.id)
        #expect(viewModel.targetedEnemyID == minion.id)

        let enemyHealthBefore = viewModel.state.enemy.currentHealth
        play(CardCatalog.strike, on: viewModel)

        // Damage lands on the minion (through its shield), not the primary.
        let after = viewModel.enemies.first { $0.id == minion.id }
        let expected = max(0, minion.health - max(0, 15 - minion.shield))
        #expect(after?.health == expected)
        #expect(viewModel.state.enemy.currentHealth == enemyHealthBefore)
        #expect(viewModel.enemyHitTargetID == minion.id)
    }

    @Test func tappingTargetedEnemyWithCardSelectedPlaysIt() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        let instance = viewModel.state.player.hand[0]
        viewModel.toggleSelection(of: instance)
        // Second tap on the already-targeted primary enemy confirms the play.
        viewModel.tapEnemy(CardCatalog.nightmare.id)
        #expect(viewModel.state.player.hand.isEmpty)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth - 15)
    }

    @Test func deadMinionCannotBeTargeted() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike, CardCatalog.strike]))
        guard let minion = viewModel.enemies.first(where: { $0.name == "Dread Wisp" }) else {
            Issue.record("Missing placeholder minion")
            return
        }
        // Two strikes fell the 22 HP (+5 shield) wisp: 15−5 shield = 10, then 15.
        viewModel.tapEnemy(minion.id)
        play(CardCatalog.strike, on: viewModel)
        viewModel.tapEnemy(minion.id)
        play(CardCatalog.strike, on: viewModel)

        // The kill resets the target to the primary enemy…
        let after = viewModel.enemies.first { $0.id == minion.id }
        #expect(after?.health == 0)
        #expect(viewModel.targetedEnemyID == CardCatalog.nightmare.id)

        // …and a dead minion can't be re-targeted.
        viewModel.tapEnemy(minion.id)
        #expect(viewModel.targetedEnemyID == CardCatalog.nightmare.id)
    }

    @Test func projectedDamageMatchesZoneBoost() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike], lucidity: 70))
        // Vivid zone: 15 * 1.2 = 18.
        #expect(viewModel.projectedDamage(of: CardCatalog.strike) == 18)
        #expect(viewModel.cardDealsDamage(CardCatalog.strike))
        #expect(!viewModel.cardDealsDamage(CardCatalog.meditate))
        #expect(viewModel.cardDealsDamage(CardCatalog.focusedMind))
    }

    // MARK: - Hero switching

    @Test func switchingMovesTheActiveRing() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        #expect(viewModel.activeAllyID == CardCatalog.dreamer.id)

        guard let teammate = viewModel.allies.first(where: { !$0.isActive }) else {
            Issue.record("Missing teammate")
            return
        }
        viewModel.switchActiveHero(to: teammate.id)

        #expect(viewModel.activeAllyID == teammate.id)
        #expect(viewModel.allies.filter { $0.isActive }.count == 1)
        #expect(viewModel.allies.first { $0.id == teammate.id }?.isActive == true)
        #expect(viewModel.allies.first { $0.id == CardCatalog.dreamer.id }?.isActive == false)
    }

    @Test func switchingIsFree() {
        let viewModel = BattleViewModel(initialState: state(hand: [CardCatalog.strike]))
        let lucidityBefore = viewModel.state.player.lucidity
        let turnBefore = viewModel.state.turnNumber
        let handBefore = viewModel.state.player.hand

        guard let teammate = viewModel.allies.first(where: { !$0.isActive }) else {
            Issue.record("Missing teammate")
            return
        }
        viewModel.switchActiveHero(to: teammate.id)

        // No Lucidity, no turn, no hand change — and the player can still act.
        #expect(viewModel.state.player.lucidity == lucidityBefore)
        #expect(viewModel.state.turnNumber == turnBefore)
        #expect(viewModel.state.player.hand == handBefore)
        #expect(viewModel.state.phase == .playerMain)

        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.state.enemy.currentHealth == CardCatalog.nightmare.maxHealth - 15)
    }

    @Test func switchingToSelfOrUnknownIsNoOp() {
        let viewModel = BattleViewModel(initialState: state(hand: []))
        viewModel.switchActiveHero(to: CardCatalog.dreamer.id)
        #expect(viewModel.activeAllyID == CardCatalog.dreamer.id)

        viewModel.switchActiveHero(to: UUID())
        #expect(viewModel.activeAllyID == CardCatalog.dreamer.id)
    }

    @Test func switchEmitsSoundAndHapticTrigger() {
        let viewModel = BattleViewModel(initialState: state(hand: []))
        let triggerBefore = viewModel.heroSwitchTrigger

        guard let teammate = viewModel.allies.first(where: { !$0.isActive }) else {
            Issue.record("Missing teammate")
            return
        }
        viewModel.switchActiveHero(to: teammate.id)

        #expect(viewModel.heroSwitchTrigger == triggerBefore + 1)
        #expect(viewModel.soundCue?.label == "hero switch")
    }

    @Test func restartReturnsLeadToTheDreamer() {
        let viewModel = BattleViewModel(initialState: state(hand: []))
        guard let teammate = viewModel.allies.first(where: { !$0.isActive }) else {
            Issue.record("Missing teammate")
            return
        }
        viewModel.switchActiveHero(to: teammate.id)
        #expect(viewModel.activeAllyID == teammate.id)

        viewModel.startNewDuel()
        #expect(viewModel.activeAllyID == CardCatalog.dreamer.id)
    }
}
