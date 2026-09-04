import CoreGraphics
import Foundation
import Testing
@testable import LanternLullaby

/// A headless auto-player that runs campaign stages many times with a
/// sensible-but-not-clever policy, so balance numbers can be checked here
/// before anyone has to play them on a phone.
///
/// The policy roughly plays the way the tutorial teaches: fire charged
/// abilities, relax when the flame runs high, hit the front enemy with the
/// best attack the meter can afford, shield ahead of heavy blows, dig when
/// the hand is thin, and let a card go rather than sit at the cap.
///
/// Every run prints one `SIM|` line per stage so the harness can grep a
/// table out of the test log. The assertions are deliberately loose — this
/// is a report first and a regression guard second.
struct BalanceSimulationTests {

    // MARK: - Policy

    struct Outcome {
        var wins = 0
        var defeats = 0
        var awakenings = 0
        var deepSleeps = 0
        var stalls = 0
        var turns: [Int] = []
        var runs: Int { wins + defeats + awakenings + deepSleeps + stalls }
        var winRate: Double { runs == 0 ? 0 : Double(wins) / Double(runs) }
        var meanTurns: Double { turns.isEmpty ? 0 : Double(turns.reduce(0, +)) / Double(turns.count) }
    }

    private static let maxTurns = 40

    /// How the auto-player behaves. `sensible` plays the way the tutorial
    /// teaches; `naive` is a first-timer who ignores the lantern until it is
    /// nearly too late, never lets a card go, and forgets abilities.
    struct Policy {
        let name: String
        let dangerLine: Int
        let ceiling: Int
        let usesAbilities: Bool
        let letsCardsGo: Bool
        let shieldsAhead: Bool

        static let sensible = Policy(name: "sensible", dangerLine: 74, ceiling: 82, usesAbilities: true, letsCardsGo: true, shieldsAhead: true)
        static let naive = Policy(name: "naive", dangerLine: 80, ceiling: 85, usesAbilities: false, letsCardsGo: false, shieldsAhead: false)
    }

    /// Plays one battle to the end. Returns the outcome and turns taken.
    static func play(_ viewModel: BattleViewModel, policy: Policy) -> (GameOutcome, Int) {
        viewModel.instantEnemyTurns = true
        var guardCounter = 0
        while viewModel.state.outcome == .ongoing, viewModel.state.turnNumber <= maxTurns {
            guardCounter += 1
            if guardCounter > 2000 { break }
            if !takeAnAction(viewModel, policy: policy) {
                viewModel.endTurn()
            }
        }
        return (viewModel.state.outcome, viewModel.state.turnNumber)
    }

    /// One decision. Returns false when the sensible thing is to end the turn.
    private static func takeAnAction(_ vm: BattleViewModel, policy: Policy) -> Bool {
        guard vm.state.phase == .playerMain, vm.state.outcome == .ongoing else { return false }
        let lucidity = vm.state.player.lucidity
        // The intent chips say when an enemy is about to push the lantern;
        // a player who reads them leaves room for it.
        let incomingPush = vm.enemies.filter { $0.health > 0 }.reduce(0) { total, enemy in
            if case .push(let amount) = enemy.intent { return total + amount }
            return total
        }
        let dangerLine = policy.dangerLine - max(0, incomingPush)
        let ceiling = policy.ceiling - max(0, incomingPush)
        let hand = vm.state.player.hand.compactMap { instance in vm.card(for: instance).map { (instance, $0) } }

        // 1. Charged abilities are free; use them.
        if policy.usesAbilities {
            for member in vm.party where vm.isAbilityReady(for: member.id) {
                vm.fireAbility(for: member.id)
                return true
            }
        }

        // 2. Too bright: relax, or let something go.
        if lucidity >= dangerLine, lucidity + incomingPush > LucidityZone.drifting.range.upperBound {
            if let relax = hand.first(where: { $0.1.netLucidityShift < 0 && $0.1.choices == nil }) {
                vm.toggleSelection(of: relax.0)
                vm.playSelectedCard(allyTarget: vm.activeAllyID)
                return true
            }
            if let choice = hand.first(where: { $0.1.choices != nil }),
               let relaxBranch = choice.1.choices?.first(where: { branch in
                   branch.effects.contains { $0.type == .lucidityModify && $0.value < 0 }
               }) {
                vm.toggleSelection(of: choice.0)
                vm.playSelectedCard(choice: relaxBranch, allyTarget: vm.activeAllyID)
                return true
            }
            if let center = hand.first(where: { $0.1.effects.contains { $0.type == .lucidityCenter } }),
               vm.projectedLucidity(after: center.1) < lucidity {
                vm.toggleSelection(of: center.0)
                vm.playSelectedCard()
                return true
            }
            if policy.letsCardsGo, lucidity >= ceiling, let spare = hand.first(where: { !vm.cardDealsDamage($0.1) }) ?? hand.first {
                vm.toggleSelection(of: spare.0)
                vm.releaseSelectedCard()
                return true
            }
            return false
        }

        // 3. Hurt: heal if it is affordable.
        if let lead = vm.party.first(where: { $0.id == vm.activeAllyID }),
           lead.health * 100 / max(1, lead.hero.maxHealth) <= 40,
           let heal = hand.first(where: { $0.1.effects.contains { $0.type == .heal } && $0.1.choices == nil }),
           vm.projectedLucidity(after: heal.1) <= ceiling {
            vm.toggleSelection(of: heal.0)
            vm.playSelectedCard(allyTarget: vm.activeAllyID)
            return true
        }

        // 4. A heavy blow is coming: shield if affordable.
        let incoming = vm.enemies.filter { $0.health > 0 }.reduce(0) { total, enemy in
            if case .attack(let amount) = enemy.intent { return total + amount }
            return total
        }
        if policy.shieldsAhead, incoming >= 14, vm.state.player.shield < incoming / 2,
           let shield = hand.first(where: { $0.1.effects.contains { $0.type == .shield } && !vm.cardDealsDamage($0.1) && $0.1.choices == nil }),
           vm.projectedLucidity(after: shield.1) <= ceiling {
            vm.toggleSelection(of: shield.0)
            vm.playSelectedCard(allyTarget: vm.activeAllyID)
            return true
        }

        // 5. Attack: best affordable damage on the front enemy.
        let attacks = hand
            .filter { vm.cardDealsDamage($0.1) && $0.1.choices == nil }
            .map { ($0.0, $0.1, vm.projectedDamage(of: $0.1), vm.projectedLucidity(after: $0.1)) }
            .filter { $0.3 <= ceiling }
            .sorted { $0.2 > $1.2 }
        if let best = attacks.first {
            vm.toggleSelection(of: best.0)
            vm.hoverEnemy(vm.targetedEnemyID)
            vm.playSelectedCard()
            return true
        }

        // 6. Thin hand: dig.
        if hand.count <= 3,
           let draw = hand.first(where: { $0.1.effects.contains { $0.type == .drawCards } && !vm.cardDealsDamage($0.1) && $0.1.choices == nil }),
           vm.projectedLucidity(after: draw.1) <= ceiling {
            vm.toggleSelection(of: draw.0)
            vm.playSelectedCard()
            return true
        }

        // 7. A choice card's attack branch, if the meter allows.
        if let choice = hand.first(where: { $0.1.choices != nil }),
           let strike = choice.1.choices?.first(where: { branch in branch.effects.contains { $0.type == .damage } }),
           vm.projectedLucidity(after: choice.1, choice: strike) <= ceiling {
            vm.toggleSelection(of: choice.0)
            vm.hoverEnemy(vm.targetedEnemyID)
            vm.playSelectedCard(choice: strike)
            return true
        }

        return false
    }

    // MARK: - Party the player plausibly has at each stage

    /// The three toughest heroes unlocked by this point, toughest leading,
    /// which is what a player who has read the party lesson will do.
    static func plausibleParty(chapterIndex: Int, stageIndex: Int) -> [Hero] {
        var unlocked = Set(HeroUnlocks.starterHeroIDs)
        for chapter in CampaignCatalogBook1.allChapters where chapter.index <= chapterIndex {
            for stage in chapter.stages {
                let cleared = chapter.index < chapterIndex || stage.index < stageIndex
                if cleared {
                    for id in HeroUnlocks.heroesUnlockedAt(chapter: chapter.index, stage: stage.index) {
                        unlocked.insert(id)
                    }
                }
            }
        }
        let heroes = CardCatalog.playableHeroes.filter { unlocked.contains($0.id) }
        return Array(heroes.sorted { $0.maxHealth > $1.maxHealth }.prefix(CampaignCoordinator.partySize))
    }

    static func simulate(chapterIndex: Int, stageIndex: Int, runs: Int, policy: Policy = .sensible) -> Outcome {
        let coordinator = CampaignCoordinator()
        let chapter = coordinator.chapters[chapterIndex]
        let stage = chapter.stages[stageIndex]
        let party = plausibleParty(chapterIndex: chapterIndex, stageIndex: stageIndex)
        var outcome = Outcome()

        for _ in 0..<runs {
            let base = coordinator.configuration(for: stage, in: chapter)
            let config = BattleConfiguration(
                title: base.title,
                party: party,
                waves: base.waves,
                arenaArtName: base.arenaArtName,
                lanternDrift: base.lanternDrift,
                deckCardIDs: CardCatalog.partyDeckCardIDs(for: party),
                stageID: base.stageID,
                chapterIndex: base.chapterIndex,
                tutorial: nil
            )
            let viewModel = BattleViewModel(configuration: config)
            let (result, turns) = play(viewModel, policy: policy)
            switch result {
            case .victory: outcome.wins += 1; outcome.turns.append(turns)
            case .defeated: outcome.defeats += 1
            case .lostToLucidity(let zone): zone == .awakening ? (outcome.awakenings += 1) : (outcome.deepSleeps += 1)
            case .ongoing: outcome.stalls += 1
            }
        }
        return outcome
    }

    static func report(_ label: String, _ o: Outcome) {
        let line = String(
            format: "SIM|%@|win %3.0f%%|turns %4.1f|def %2d|awake %2d|sleep %2d|stall %2d",
            label, o.winRate * 100, o.meanTurns, o.defeats, o.awakenings, o.deepSleeps, o.stalls
        )
        print(line)
    }

    // MARK: - Reports

    @Test func chapterOneReport() {
        let runs = 30
        var first: Outcome?
        for policy in [Policy.sensible, Policy.naive] {
            for stageIndex in 0..<10 {
                let o = Self.simulate(chapterIndex: 0, stageIndex: stageIndex, runs: runs, policy: policy)
                if stageIndex == 0, policy.name == "sensible" { first = o }
                Self.report(String(format: "%@|C1-%02d %@", policy.name, stageIndex + 1, CampaignCatalogBook1.chapter1.stages[stageIndex].name), o)
            }
        }
        // The very first page must be a near-certain win for a sensible policy.
        #expect((first?.winRate ?? 0) >= 0.85)
    }

    @Test func chapterTwoReport() {
        let runs = 30
        for policy in [Policy.sensible, Policy.naive] {
            for stageIndex in 0..<10 {
                let o = Self.simulate(chapterIndex: 1, stageIndex: stageIndex, runs: runs, policy: policy)
                Self.report(String(format: "%@|C2-%02d %@", policy.name, stageIndex + 1, CampaignCatalogBook1.chapter2.stages[stageIndex].name), o)
            }
        }
    }
}
