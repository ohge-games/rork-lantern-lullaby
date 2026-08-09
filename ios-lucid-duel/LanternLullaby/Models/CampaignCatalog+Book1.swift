import Foundation

// MARK: - Book 1: The Once and Future King — Campaign Structure

/// Full campaign data for Book 1 (Arthurian).
/// 5 chapters × 10 stages = 50 battles.
enum CampaignCatalogBook1 {

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 1: The Sword in the Stone
    // Wart's journey from squire to king
    // ─────────────────────────────────────────────────────────────────────────

    static let chapter1 = Chapter(
        id: chapterID(1),
        index: 0,
        title: "The Sword in the Stone",
        stages: [
            // Stage 1: The Forest Sauvage
            Stage(
                id: stageID(1, 1),
                index: 0,
                name: "The Forest Sauvage",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 1),
                    waves: [
                        BattleWave(
                            id: waveID(1, 1, 1),
                            encounter: Encounter(
                                id: encounterID(1, 1, 1),
                                primaryEnemyID: EnemyCatalogBook1.forestWolf.id,
                                supportEnemyIDs: []
                            ),
                            introText: "A shadow moves between the trees...",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "The forest is darker than you remember from the book. Every sound could be danger—or imagination.",
                    victoryNarrative: "The wolf fades like morning mist. Was it ever really there?",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 2: Merlyn's Cottage
            Stage(
                id: stageID(1, 2),
                index: 1,
                name: "Merlyn's Cottage",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 2),
                    waves: [
                        BattleWave(
                            id: waveID(1, 2, 1),
                            encounter: Encounter(
                                id: encounterID(1, 2, 1),
                                primaryEnemyID: EnemyCatalogBook1.forestSprite.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestSprite.id]
                            ),
                            introText: "Merlyn's wards flicker—something slipped through!",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "The wizard's cottage is alive with magic. But not everything here is friendly.",
                    victoryNarrative: "Archimedes hoots approvingly. 'Not bad for a beginner.'",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 3: The Mews at Midnight
            Stage(
                id: stageID(1, 3),
                index: 2,
                name: "The Mews at Midnight",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 3),
                    waves: [
                        BattleWave(
                            id: waveID(1, 3, 1),
                            encounter: Encounter(
                                id: encounterID(1, 3, 1),
                                primaryEnemyID: EnemyCatalogBook1.waywardKnight.id,
                                supportEnemyIDs: []
                            ),
                            introText: "A figure in rusted armor blocks your path.",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "The hawks cry warnings in the dark. Someone is here who shouldn't be.",
                    victoryNarrative: "The knight crumbles to dust. A warning, perhaps, of darker things to come.",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 4: A Tench in the Moat
            Stage(
                id: stageID(1, 4),
                index: 3,
                name: "A Tench in the Moat",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 4),
                    waves: [
                        BattleWave(
                            id: waveID(1, 4, 1),
                            encounter: Encounter(
                                id: encounterID(1, 4, 1),
                                primaryEnemyID: EnemyCatalogBook1.forestWolf.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestWolf.id]
                            ),
                            introText: "The dream shifts—you're small, so small, and the wolves are everywhere.",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "Merlyn turns you into a fish to learn humility. But dreams don't follow the same rules...",
                    victoryNarrative: "You gasp awake on the shore. The lesson learned, but at what cost?",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 5: The Ant Fortress (Lancelot unlocks!)
            Stage(
                id: stageID(1, 5),
                index: 4,
                name: "The Ant Fortress",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 5),
                    waves: [
                        BattleWave(
                            id: waveID(1, 5, 1),
                            encounter: Encounter(
                                id: encounterID(1, 5, 1),
                                primaryEnemyID: EnemyCatalogBook1.waywardKnight.id,
                                supportEnemyIDs: []
                            ),
                            introText: "A bandit captain blocks the road. But you're not alone...",
                            outroText: "A knight in silver-blue armor rides from the treeline!"
                        ),
                        BattleWave(
                            id: waveID(1, 5, 2),
                            encounter: Encounter(
                                id: encounterID(1, 5, 2),
                                primaryEnemyID: EnemyCatalogBook1.waywardKnight.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestWolf.id]
                            ),
                            introText: "'Stand back, young one. I am Lancelot du Lac.'",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "EVERYTHING NOT FORBIDDEN IS COMPULSORY. The ants taught you about war. But this is different.",
                    victoryNarrative: "'You fight with heart,' Lancelot says. 'Perhaps we'll meet again, in waking or in dreams.'",
                    heroDialogue: [
                        CardCatalogHeroes.HeroIDs.lancelot: "Lancelot smiles grimly. 'I know this road. I've walked it in sorrow.'"
                    ]
                ),
                isBoss: false
            ),

            // Stage 6: Flight of the Wild Geese
            Stage(
                id: stageID(1, 6),
                index: 5,
                name: "Flight of the Wild Geese",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 6),
                    waves: [
                        BattleWave(
                            id: waveID(1, 6, 1),
                            encounter: Encounter(
                                id: encounterID(1, 6, 1),
                                primaryEnemyID: EnemyCatalogBook1.forestSprite.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestSprite.id, EnemyCatalogBook1.forestSprite.id]
                            ),
                            introText: "The fey are curious about you. Not all curiosity is kind.",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "Borders are imaginary lines drawn by the frightened. You fly above them all.",
                    victoryNarrative: "The geese taught you that nations are just stories. But stories have power in dreams.",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 7: The Badger's Sett
            Stage(
                id: stageID(1, 7),
                index: 6,
                name: "The Badger's Sett",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 7),
                    waves: [
                        BattleWave(
                            id: waveID(1, 7, 1),
                            encounter: Encounter(
                                id: encounterID(1, 7, 1),
                                primaryEnemyID: EnemyCatalogBook1.giantBoar.id,
                                supportEnemyIDs: []
                            ),
                            introText: "Something massive stirs in the darkness below...",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "The badger speaks of why humans make war. You wish you could forget.",
                    victoryNarrative: "The boar was just a dream within a dream. But the lesson was real.",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 8: The Questing Beast (Kay unlocks!)
            Stage(
                id: stageID(1, 8),
                index: 7,
                name: "The Questing Beast",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 8),
                    waves: [
                        BattleWave(
                            id: waveID(1, 8, 1),
                            encounter: Encounter(
                                id: encounterID(1, 8, 1),
                                primaryEnemyID: EnemyCatalogBook1.giantBoar.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestWolf.id]
                            ),
                            introText: "King Pellinore has hunted this beast his whole life. But tonight, it hunts you.",
                            outroText: "From the mist, a gruff voice: 'Need a hand, little brother?'"
                        ),
                        BattleWave(
                            id: waveID(1, 8, 2),
                            encounter: Encounter(
                                id: encounterID(1, 8, 2),
                                primaryEnemyID: EnemyCatalogBook1.forestWolf.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestWolf.id, EnemyCatalogBook1.forestWolf.id]
                            ),
                            introText: "Kay draws his sword beside you. 'I've always got your back, Wart.'",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "The Beast has the head of a snake, the body of a leopard, the haunches of a lion. It is impossible. It is real.",
                    victoryNarrative: "'Not bad,' Kay admits reluctantly. 'For a dreamer.'",
                    heroDialogue: [
                        CardCatalogHeroes.HeroIDs.kay: "Kay snorts. 'This is nothing. Remember when we faced those three outlaws?'"
                    ]
                ),
                isBoss: false
            ),

            // Stage 9: Tournament Eve
            Stage(
                id: stageID(1, 9),
                index: 8,
                name: "Tournament Eve",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 9),
                    waves: [
                        BattleWave(
                            id: waveID(1, 9, 1),
                            encounter: Encounter(
                                id: encounterID(1, 9, 1),
                                primaryEnemyID: EnemyCatalogBook1.waywardKnight.id,
                                supportEnemyIDs: [EnemyCatalogBook1.waywardKnight.id]
                            ),
                            introText: "Knights drunk on ambition block your path to the tournament grounds.",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "Tomorrow, Kay will compete. Tomorrow, everything changes. But first, survive tonight.",
                    victoryNarrative: "The path is clear. Tomorrow awaits.",
                    heroDialogue: nil
                ),
                isBoss: false
            ),

            // Stage 10: The Sword in the Stone (BOSS)
            Stage(
                id: stageID(1, 10),
                index: 9,
                name: "The Sword in the Stone",
                encounter: nil,
                battle: MultistageBattle(
                    id: battleID(1, 10),
                    waves: [
                        BattleWave(
                            id: waveID(1, 10, 1),
                            encounter: Encounter(
                                id: encounterID(1, 10, 1),
                                primaryEnemyID: EnemyCatalogBook1.waywardKnight.id,
                                supportEnemyIDs: [EnemyCatalogBook1.waywardKnight.id]
                            ),
                            introText: "Those who would stop you from reaching the stone attack!",
                            outroText: "You break through—and there it is. The sword."
                        ),
                        BattleWave(
                            id: waveID(1, 10, 2),
                            encounter: Encounter(
                                id: encounterID(1, 10, 2),
                                primaryEnemyID: EnemyCatalogBook1.sirEctorChallenge.id,
                                supportEnemyIDs: []
                            ),
                            introText: "'Before you draw that blade,' Sir Ector says quietly, 'you must prove you're worthy.'",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "WHOSO PULLETH OUT THIS SWORD OF THIS STONE AND ANVIL IS RIGHTWISE KING BORN OF ALL ENGLAND.",
                    victoryNarrative: "The sword slides free like it was waiting for you. Like it was always yours.\n\nYou wake.\n\nThe book is warm in your hands.",
                    heroDialogue: [
                        CardCatalogHeroes.HeroIDs.lancelot: "Lancelot kneels. 'My king. I will serve you—in dreams and in waking.'",
                        CardCatalogHeroes.HeroIDs.kay: "Kay laughs. 'I always knew. Even when I was terrible to you. I always knew.'"
                    ]
                ),
                isBoss: true
            ),
        ]
    )

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - ID Generators
    // ─────────────────────────────────────────────────────────────────────────

    private static func chapterID(_ chapter: Int) -> UUID {
        UUID(uuidString: String(format: "D1%02d00000-0000-4000-8000-000000000001", chapter))!
    }

    private static func stageID(_ chapter: Int, _ stage: Int) -> UUID {
        UUID(uuidString: String(format: "D1%02d%02d000-0000-4000-8000-000000000001", chapter, stage))!
    }

    private static func battleID(_ chapter: Int, _ stage: Int) -> UUID {
        UUID(uuidString: String(format: "D1%02d%02d100-0000-4000-8000-000000000001", chapter, stage))!
    }

    private static func waveID(_ chapter: Int, _ stage: Int, _ wave: Int) -> UUID {
        UUID(uuidString: String(format: "D1%02d%02d1%02d-0000-4000-8000-000000000001", chapter, stage, wave))!
    }

    private static func encounterID(_ chapter: Int, _ stage: Int, _ wave: Int) -> UUID {
        UUID(uuidString: String(format: "D1%02d%02d2%02d-0000-4000-8000-000000000001", chapter, stage, wave))!
    }
}
