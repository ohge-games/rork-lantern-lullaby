import CoreGraphics
import Foundation
import Testing
@testable import LanternLullaby

/// The answers to a telegraphed intent — Hush, Wooden Feint, Cut the Straps,
/// Snuffed Wick — plus the two rules that make the lantern a real resource:
/// a released card burns, and an enemy can push the meter itself.
struct AnswerCardTests {

    // MARK: - Answering an intent

    @Test func hushCostsTheEnemyItsActionButNotItsPlan() {
        let foe = enemy("Knight", health: 200, pattern: .scripted(cycle: [.attack(12), .attack(20)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.hush.id, count: 20)
        ))
        viewModel.instantEnemyTurns = true
        let healthBefore = viewModel.allies[0].health

        play(CardCatalog.hush, on: viewModel)
        #expect(viewModel.enemies[0].intent == .stunned)

        viewModel.endTurn()
        // The blow never landed, and the plan is still the first of the cycle.
        #expect(viewModel.allies[0].health == healthBefore)
        #expect(viewModel.enemies[0].intent == .attack(12))
    }

    @Test func woodenFeintTakesTheStingOutOfTheNextBlow() {
        let foe = enemy("Knight", health: 200, pattern: .scripted(cycle: [.attack(20)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.woodenFeint.id, count: 20)
        ))
        viewModel.instantEnemyTurns = true
        let healthBefore = viewModel.allies[0].health

        play(CardCatalog.woodenFeint, on: viewModel)
        // The chip promises the smaller number before the turn is taken.
        #expect(viewModel.enemies[0].intent == .attack(14))

        viewModel.endTurn()
        #expect(viewModel.allies[0].health == healthBefore - 14)
        // The weaken is spent: the next swing is full strength again.
        #expect(viewModel.enemies[0].intent == .attack(20))
    }

    @Test func cutTheStrapsBreaksAShieldBeforeItsDamageLands() {
        let foe = enemy("Guard", health: 200, pattern: .scripted(cycle: [.brace(shield: 30), .attack(1)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.kay],
            deck: Array(repeating: CardCatalog.cutTheStraps.id, count: 20)
        ))
        viewModel.instantEnemyTurns = true
        viewModel.endTurn()
        #expect(viewModel.enemies[0].shield == 30)

        let healthBefore = viewModel.enemies[0].health
        play(CardCatalog.cutTheStraps, on: viewModel)
        // Nothing was absorbed: all 8 reached the enemy.
        #expect(viewModel.enemies[0].shield == 0)
        #expect(viewModel.enemies[0].health == healthBefore - 8)
    }

    @Test func snuffedWickBlowsOutAWindUp() {
        let foe = enemy("Boar", health: 200, pattern: .scripted(cycle: [.buff(.windUp(multiplier: 2)), .attack(20)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.snuffedWick.id, count: 20)
        ))
        viewModel.instantEnemyTurns = true
        viewModel.endTurn()  // the wind-up lands
        #expect(viewModel.enemies[0].intent == .attack(40))

        play(CardCatalog.snuffedWick, on: viewModel)
        #expect(viewModel.enemies[0].intent == .attack(20))

        let healthBefore = viewModel.allies[0].health
        viewModel.endTurn()
        #expect(viewModel.allies[0].health == healthBefore - 20)
    }

    @Test func everyAnswerCardIsAimedAtAnEnemy() {
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [enemy("Knight", health: 40, pattern: .scripted(cycle: [.attack(1)]))])],
            party: [CardCatalog.wart]
        ))
        for card in CardCatalog.answerCards {
            #expect(viewModel.cardTargetsEnemy(card), "\(card.name) should aim at an enemy")
            #expect(card.needsTarget, "\(card.name) should need a target")
        }
    }

    // MARK: - The enemy fights over the lantern

    @Test func anEnemyCanPushTheLanternBothWays() {
        let glamour = enemy("Glamour", health: 200, pattern: .scripted(cycle: [.lucidityPush(10)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [glamour])],
            party: [CardCatalog.wart]
        ))
        viewModel.instantEnemyTurns = true
        #expect(viewModel.enemies[0].intent == .push(10))

        let before = viewModel.state.player.lucidity
        viewModel.endTurn()
        #expect(viewModel.state.player.lucidity == before + 10)
    }

    @Test func aLanternPushCanEndTheBattle() {
        let whisper = enemy("Whisper", health: 200, pattern: .scripted(cycle: [.lucidityPush(-20)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [whisper])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.deepBreath.id, count: 20)
        ))
        viewModel.instantEnemyTurns = true
        // Two Deep Breaths take the flame to 26; the whisper takes it under.
        play(CardCatalog.deepBreath, on: viewModel)
        play(CardCatalog.deepBreath, on: viewModel)
        viewModel.endTurn()
        #expect(viewModel.state.outcome == .lostToLucidity(zone: .deepSleep))
    }

    // MARK: - Letting a card go

    @Test func aReleasedCardBurnsInsteadOfReturning() {
        let foe = enemy("Knight", health: 400, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.strike.id, count: 12)
        ))
        let total = viewModel.state.player.deck.count + viewModel.state.player.hand.count

        guard let instance = viewModel.state.player.hand.first else {
            Issue.record("Empty hand")
            return
        }
        viewModel.toggleSelection(of: instance)
        viewModel.releaseSelectedCard()

        #expect(viewModel.burnedCards.count == 1)
        #expect(!viewModel.state.player.discardPile.contains { $0.id == instance.id })
        // Nothing is created or lost: the burned card is simply out of play.
        let inPlay = viewModel.state.player.deck.count
            + viewModel.state.player.hand.count
            + viewModel.state.player.discardPile.count
        #expect(inPlay + viewModel.burnedCards.count == total)
    }

    @Test func releasingNeverDropsTheFlameIntoDeepSleep() {
        // A flame at 19: a full 5-point release would put it out.
        let viewModel = BattleViewModel(initialState: seededState(hand: [CardCatalog.strike], lucidity: 19))
        #expect(viewModel.safeReleaseRelief == 3)

        guard let instance = viewModel.state.player.hand.first else {
            Issue.record("Empty hand")
            return
        }
        viewModel.toggleSelection(of: instance)
        viewModel.releaseSelectedCard()

        #expect(viewModel.state.player.lucidity == LucidityZone.drifting.range.lowerBound)
        #expect(viewModel.state.outcome == .ongoing)
    }

    @Test func aReleaseWellAboveTheFloorGivesTheFullRelief() {
        let viewModel = BattleViewModel(initialState: seededState(hand: [CardCatalog.strike], lucidity: 70))
        #expect(viewModel.safeReleaseRelief == GameRules.releaseRelief)

        guard let instance = viewModel.state.player.hand.first else {
            Issue.record("Empty hand")
            return
        }
        viewModel.toggleSelection(of: instance)
        viewModel.releaseSelectedCard()
        #expect(viewModel.state.player.lucidity == 70 - GameRules.releaseRelief)
    }

    // MARK: - The field

    @Test func twoOfTheSameEnemyDoNotActInLockstep() {
        let pattern = AttackPattern.scripted(cycle: [.attack(9), .brace(shield: 6)])
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [
                enemy("Sprite", health: 40, pattern: pattern),
                enemy("Sprite", health: 40, pattern: pattern),
            ])],
            party: [CardCatalog.wart]
        ))
        #expect(viewModel.enemies[0].intent != viewModel.enemies[1].intent)
    }

    @Test func aGuestArrivesWithCardsAndANearlyChargedAbility() {
        let foe = enemy("Wolf", health: 30, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let survivor = enemy("Wolf", health: 200, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [
                WaveSpec(enemies: [foe]),
                WaveSpec(enemies: [survivor], allyReinforcement: CardCatalog.lancelot),
            ],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.strike.id, count: 30)
        ))
        let deckBefore = viewModel.state.player.deck.count
        let handBefore = viewModel.state.player.hand.count

        play(CardCatalog.strike, on: viewModel)   // clears wave 1
        play(CardCatalog.strike, on: viewModel)
        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.waveIndex == 1)
        #expect(viewModel.party.contains { $0.id == CardCatalog.HeroIDs.lancelot })

        // Cards of his own: two in hand, the rest shuffled in.
        let lancelotCards = (viewModel.state.player.hand + viewModel.state.player.deck)
            .compactMap { viewModel.card(for: $0) }
            .filter { $0.heroID == CardCatalog.HeroIDs.lancelot }
        #expect(!lancelotCards.isEmpty)
        #expect(viewModel.state.player.deck.count + viewModel.state.player.hand.count
                > deckBefore + handBefore - 3)

        // And he rides in almost ready to swing.
        if let ability = viewModel.ability(for: CardCatalog.HeroIDs.lancelot) {
            #expect(viewModel.charge(for: CardCatalog.HeroIDs.lancelot) == ability.chargeRequired - 2)
        }
    }

    @Test func aFifthHeroIsNeverAddedToACrowdedField() {
        let foe = enemy("Wolf", health: 30, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let survivor = enemy("Wolf", health: 200, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [
                WaveSpec(enemies: [foe]),
                WaveSpec(enemies: [survivor], allyReinforcement: CardCatalog.lancelot),
            ],
            party: [CardCatalog.wart, CardCatalog.archimedes, CardCatalog.kay, CardCatalog.bedivere],
            deck: Array(repeating: CardCatalog.strike.id, count: 30)
        ))
        play(CardCatalog.strike, on: viewModel)
        play(CardCatalog.strike, on: viewModel)
        play(CardCatalog.strike, on: viewModel)
        #expect(viewModel.waveIndex == 1)
        #expect(viewModel.party.count == BattleViewModel.maxFieldedHeroes)
    }

    // MARK: - Looking through the piles

    @Test func theDeckListsGroupedCopiesSortedByCost() {
        let foe = enemy("Knight", health: 400, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.focusStrike.id, count: 6)
                + Array(repeating: CardCatalog.deepBreath.id, count: 6)
        ))
        let deck = viewModel.contents(of: .deck)
        #expect(deck.count <= 2)
        #expect(deck.reduce(0) { $0 + $1.count } == viewModel.count(of: .deck))
        // Cheapest first, so the list reads as a plan rather than a shuffle.
        let costs = deck.map(\.card.lucidityCost)
        #expect(costs == costs.sorted())
    }

    @Test func theDiscardReadsNewestFirstAndBurnedCardsAreTheirOwnPile() {
        let foe = enemy("Knight", health: 400, pattern: .scripted(cycle: [.brace(shield: 1)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart],
            deck: Array(repeating: CardCatalog.strike.id, count: 10)
                + Array(repeating: CardCatalog.mentalShift.id, count: 10)
        ))
        play(CardCatalog.strike, on: viewModel)
        play(CardCatalog.mentalShift, on: viewModel)
        #expect(viewModel.contents(of: .discard).first?.card.id == CardCatalog.mentalShift.id)

        #expect(viewModel.count(of: .burned) == 0)
        guard let instance = viewModel.state.player.hand.first else {
            Issue.record("Empty hand")
            return
        }
        viewModel.toggleSelection(of: instance)
        viewModel.releaseSelectedCard()
        #expect(viewModel.count(of: .burned) == 1)
        #expect(viewModel.contents(of: .burned).count == 1)
    }

    // MARK: - Restart and persistence

    @Test func restartingDuringTheEnemyTurnRunsOnlyOneTurn() async {
        let foe = enemy("Knight", health: 400, pattern: .scripted(cycle: [.attack(10)]))
        let viewModel = BattleViewModel(configuration: configuration(
            waves: [WaveSpec(enemies: [foe])],
            party: [CardCatalog.wart]
        ))
        let maxHealth = CardCatalog.wart.maxHealth

        viewModel.endTurn()
        viewModel.startNewDuel()
        viewModel.endTurn()
        await viewModel.enemyTurnTask?.value

        // Exactly one blow landed: the abandoned turn did not also resolve.
        #expect(viewModel.allies[0].health == maxHealth - 10)
    }

    @Test func aRetryBringsTheLessonBackWithIt() {
        let foe = enemy("Wolf", health: 400, pattern: .scripted(cycle: [.brace(shield: 1)]))
        var config = configuration(waves: [WaveSpec(enemies: [foe])], party: [CardCatalog.wart])
        config = BattleConfiguration(
            title: config.title,
            party: config.party,
            waves: config.waves,
            arenaArtName: config.arenaArtName,
            lanternDrift: config.lanternDrift,
            deckCardIDs: config.deckCardIDs,
            tutorial: .firstBattle
        )
        let viewModel = BattleViewModel(configuration: config)
        viewModel.startStage()
        #expect(viewModel.activeTutorialStep != nil)

        viewModel.startNewDuel()
        #expect(viewModel.activeTutorialStep != nil)
    }

    @Test func aSaveMissingAFieldStillOpensTheBook() throws {
        let progress = CampaignProgress(
            selectedHeroIDs: [CardCatalog.HeroIDs.wart],
            currentChapterID: UUID(),
            currentStageID: UUID(),
            clearedStageIDs: [UUID(), UUID()],
            unlockedHeroIDs: [CardCatalog.HeroIDs.wart]
        )
        let data = try JSONEncoder().encode(progress)
        guard var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Issue.record("Progress did not encode to an object")
            return
        }
        json.removeValue(forKey: "selectedHeroIDs")
        json["somethingFromALaterBuild"] = 7
        let trimmed = try JSONSerialization.data(withJSONObject: json)

        let decoded = try JSONDecoder().decode(CampaignProgress.self, from: trimmed)
        #expect(decoded.clearedStageIDs == progress.clearedStageIDs)
        #expect(decoded.selectedHeroIDs.isEmpty)
    }

    // MARK: - Helpers

    private func enemy(_ name: String, health: Int, pattern: AttackPattern) -> Enemy {
        Enemy(
            id: UUID(),
            name: name,
            tier: .minion,
            maxHealth: health,
            pattern: pattern,
            iconName: "pawprint.fill",
            artName: "forest_wolf_full",
            fullBodyArtName: "forest_wolf_full",
            passive: nil
        )
    }

    private func configuration(
        waves: [WaveSpec],
        party: [Hero] = [CardCatalog.wart, CardCatalog.archimedes],
        deck: [Card.ID] = Array(repeating: CardCatalog.strike.id, count: 20)
    ) -> BattleConfiguration {
        BattleConfiguration(
            title: "Test",
            party: party,
            waves: waves,
            arenaArtName: "bg_moonlit_forest",
            lanternDrift: 0,
            deckCardIDs: deck
        )
    }

    private func seededState(hand cards: [Card], lucidity: Int) -> GameState {
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

    private func play(_ card: Card, on viewModel: BattleViewModel) {
        guard let instance = viewModel.state.player.hand.first(where: { $0.cardID == card.id }) else {
            Issue.record("Card \(card.name) not in hand")
            return
        }
        viewModel.toggleSelection(of: instance)
        viewModel.playSelectedCard()
    }
}
