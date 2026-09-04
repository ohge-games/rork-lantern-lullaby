import Foundation
import Testing
@testable import LanternLullaby

/// Editorial guard-rails for Book 1's authored text: bubble length, boss
/// taunt timing, unique card names, the Merlyn spelling, and the beats the
/// campaign relies on actually existing.
struct NarrativeContentTests {

    // MARK: - Helpers

    /// Every authored `StageNarrative` for Book 1, keyed "chapter-stage".
    private static var book1Narratives: [(key: String, narrative: StageNarrative)] {
        var out: [(String, StageNarrative)] = []
        for chapter in 1...5 {
            for stage in 1...10 {
                out.append(("\(chapter)-\(stage)", NarrativeCatalogBook1.narrative(forChapter: chapter, stage: stage)))
            }
        }
        return out
    }

    /// Every `DialogueLine` the player can be shown from the narrative
    /// catalogs: stage scenes, battle dialogues, combos, and the prologue.
    private static var allNarrativeLines: [(where: String, line: DialogueLine)] {
        var out: [(String, DialogueLine)] = []
        for (key, narrative) in book1Narratives {
            for line in narrative.preStageScene?.lines ?? [] { out.append(("\(key) pre", line)) }
            for line in narrative.postStageScene?.lines ?? [] { out.append(("\(key) post", line)) }
            for dialogue in narrative.battleDialogues {
                for line in dialogue.lines { out.append(("\(key) \(dialogue.trigger)", line)) }
            }
        }
        let everyHero = CardCatalog.allHeroes.map(\.id)
        for combo in NarrativeCatalogBook1.comboDialogues(forParty: everyHero) {
            for line in combo.lines { out.append(("combo \(combo.trigger)", line)) }
        }
        for (index, scene) in NarrativeCatalogBook1.prologueScenes.enumerated() {
            for line in scene.lines { out.append(("prologue \(index)", line)) }
        }
        for line in NarrativeCatalogBook1.firstMorningScene.lines { out.append(("first morning", line)) }
        return out
    }

    /// Every user-visible string the campaign catalog contributes to a
    /// battle: names, wave text, opening/victory lines and hero remarks.
    private static var allCampaignStrings: [(where: String, text: String)] {
        var out: [(String, String)] = []
        for chapter in CampaignCatalogBook1.allChapters {
            out.append(("chapter \(chapter.index + 1) title", chapter.title))
            for stage in chapter.stages {
                let key = "\(chapter.index + 1)-\(stage.index + 1)"
                out.append(("\(key) name", stage.name))
                guard let battle = stage.battle else { continue }
                if let text = battle.openingNarrative { out.append(("\(key) opening", text)) }
                if let text = battle.victoryNarrative { out.append(("\(key) victory", text)) }
                for (heroID, text) in battle.heroDialogue ?? [:] {
                    out.append(("\(key) heroDialogue \(heroID)", text))
                }
                for (index, wave) in battle.waves.enumerated() {
                    if let text = wave.introText { out.append(("\(key) wave \(index) intro", text)) }
                    if let text = wave.outroText { out.append(("\(key) wave \(index) outro", text)) }
                }
            }
        }
        return out
    }

    // MARK: - (a) Bubble length

    @Test func noNarrativeLineExceedsBubbleLength() {
        let limit = 170
        for (place, line) in Self.allNarrativeLines {
            #expect(line.text.count <= limit, "\(place): \(line.text.count) chars — \(line.text)")
        }
        for (place, text) in Self.allCampaignStrings {
            #expect(text.count <= limit, "\(place): \(text.count) chars — \(text)")
        }
    }

    // MARK: - (b) Boss taunts wait for the boss wave

    @Test func bossTauntsFireOnTheBossWave() {
        for chapter in 1...5 {
            let narrative = NarrativeCatalogBook1.narrative(forChapter: chapter, stage: 10)
            let triggers = narrative.battleDialogues.map(\.trigger)
            #expect(!triggers.contains(.battleStart),
                    "chapter \(chapter) stage 10 still has a .battleStart dialogue, which plays over wave 1")
            #expect(triggers.contains(.waveStart(waveIndex: 1)),
                    "chapter \(chapter) stage 10 has no .waveStart(waveIndex: 1) taunt")
        }
    }

    @Test func healthThresholdsUseTheEngineCheckpoints() {
        let checkpoints: Set<Int> = [75, 50, 25, 10]
        for (key, narrative) in Self.book1Narratives {
            for dialogue in narrative.battleDialogues {
                if case .enemyHealthThreshold(let percent) = dialogue.trigger {
                    #expect(checkpoints.contains(percent), "\(key) uses \(percent)%, which the engine never checks")
                }
            }
        }
    }

    @Test func noDialogueUsesTheDeadHeroUnlockTrigger() {
        for (key, narrative) in Self.book1Narratives {
            for dialogue in narrative.battleDialogues {
                if case .heroUnlock = dialogue.trigger {
                    Issue.record("\(key) has a .heroUnlock dialogue, which never fires")
                }
            }
        }
    }

    // MARK: - (c) Card names are unique

    @Test func cardNamesAreUniqueAcrossTheCatalog() {
        // Intentional duplicates go here, by name. There are none today.
        let allowed: Set<String> = []
        var seen: [String: Int] = [:]
        for card in CardCatalog.allCards {
            seen[card.name, default: 0] += 1
        }
        let duplicates = seen.filter { $0.value > 1 && !allowed.contains($0.key) }
        #expect(duplicates.isEmpty, "duplicate card names: \(duplicates.keys.sorted())")
    }

    // MARK: - (d) Merlyn, never Merlin

    @Test func merlynIsSpelledTheBookWay() {
        for (place, line) in Self.allNarrativeLines {
            #expect(!line.speakerName.contains("Merlin"), "\(place): speaker \(line.speakerName)")
            #expect(!line.text.contains("Merlin"), "\(place): \(line.text)")
        }
        for (place, text) in Self.allCampaignStrings {
            #expect(!text.contains("Merlin"), "\(place): \(text)")
        }
        #expect(CardCatalog.merlin.name == "Merlyn")
    }

    // MARK: - (e) Beats the campaign relies on

    @Test func chapter1Stage3HasItsReflection() {
        let narrative = NarrativeCatalogBook1.narrative(forChapter: 1, stage: 3)
        #expect(narrative.postStageScene != nil)
        #expect(NarrativeCatalogBook1.chapter1Stage3Narrative.postStageScene?.lines.isEmpty == false)
    }

    @Test func firstMorningIsShownAfterTheFirstBattle() {
        let post = NarrativeCatalogBook1.chapter1Stage1Narrative.postStageScene?.lines ?? []
        let morning = NarrativeCatalogBook1.firstMorningScene.lines.map(\.text)
        #expect(post.map(\.text).suffix(morning.count).elementsEqual(morning))
    }

    @Test func everyComboPairHasADialogue() {
        let ids = CardCatalog.HeroIDs.self
        let pairs: [(UUID, UUID, String)] = [
            (ids.lancelot, ids.galahad, "combo_lancelot_galahad"),
            (ids.kay, ids.wart, "combo_kay_wart"),
            (ids.morgana, ids.merlin, "combo_morgana_merlin"),
            (ids.escanor, ids.kay, "combo_escanor_kay"),
            (ids.bedivere, ids.lancelot, "combo_bedivere_lancelot"),
            (ids.galahad, ids.morgana, "combo_galahad_morgana"),
        ]
        for (a, b, key) in pairs {
            let combos = NarrativeCatalogBook1.comboDialogues(forParty: [a, b])
            #expect(combos.count == 1, "\(key): expected exactly one combo, got \(combos.count)")
            #expect(combos.first?.trigger == .firstTimeOnly(key: key))
        }
    }

    @Test func bedivereRidesInOnTheCastleGate() {
        let stage = CampaignCatalogBook1.chapter2.stages[2]
        let waves = stage.battle?.waves ?? []
        #expect(waves.count == 2)
        #expect(waves.last?.allyReinforcementID == CardCatalog.HeroIDs.bedivere)
        let guards = waves.reduce(0) { $0 + 1 + $1.encounter.supportEnemyIDs.count }
        #expect(guards == 2)
    }
}
