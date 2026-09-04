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
        stages: chapter1Stages
    )

    static let chapter2 = Chapter(
        id: chapterID(2),
        index: 1,
        title: "The Queen of Air and Darkness",
        stages: chapter2Stages
    )

    static let chapter3 = Chapter(
        id: chapterID(3),
        index: 2,
        title: "The Ill-Made Knight",
        stages: chapter3Stages
    )

    static let chapter4 = Chapter(
        id: chapterID(4),
        index: 3,
        title: "The Candle in the Wind",
        stages: chapter4Stages
    )

    static let chapter5 = Chapter(
        id: chapterID(5),
        index: 4,
        title: "The Book of Merlyn",
        stages: chapter5Stages
    )

    static let allChapters: [Chapter] = [chapter1, chapter2, chapter3, chapter4, chapter5]

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 1: The Sword in the Stone
    // ─────────────────────────────────────────────────────────────────────────

    private static let chapter1Stages: [Stage] = [
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
                                supportEnemyIDs: [EnemyCatalogBook1.forestSprite.id]
                            ),
                            introText: "The dream shifts—you're small, so small, and the wolves are everywhere.",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: "Merlyn's lesson tonight was the moat: be small, be quick, be humble. The wolves did not get the lesson.",
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
                            outroText: "Hoofbeats. Someone is coming fast."
                        ),
                        BattleWave(
                            id: waveID(1, 5, 2),
                            encounter: Encounter(
                                id: encounterID(1, 5, 2),
                                primaryEnemyID: EnemyCatalogBook1.forestWolf.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestWolf.id]
                            ),
                            introText: "A knight in silver-blue armor reins in beside you. 'Stand back, young one. These are mine.'",
                            outroText: nil,
                            allyReinforcementID: CardCatalog.HeroIDs.lancelot
                        ),
                    ],
                    openingNarrative: "The ants' fortress is behind you. The road ahead has bandits — and, somewhere, a knight.",
                    victoryNarrative: "The last wolf bolts. The knight lowers his blade and looks at you for a long moment.",
                    heroDialogue: [
                        CardCatalog.HeroIDs.lancelot: "Lancelot smiles grimly. 'I know this road. I've walked it in sorrow.'"
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
                    openingNarrative: "The geese taught Wart that borders are only lines. The fey drawing lines around you tonight disagree.",
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
                    openingNarrative: "The badger asked Wart why men make war. Something in the sett below has an answer of its own.",
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
                                supportEnemyIDs: [EnemyCatalogBook1.forestSprite.id]
                            ),
                            introText: "Something big crashes through the bracken — and it isn't alone.",
                            outroText: "From the mist, a gruff voice: 'Need a hand, little brother?'"
                        ),
                        BattleWave(
                            id: waveID(1, 8, 2),
                            encounter: Encounter(
                                id: encounterID(1, 8, 2),
                                primaryEnemyID: EnemyCatalogBook1.forestWolf.id,
                                supportEnemyIDs: [EnemyCatalogBook1.forestWolf.id]
                            ),
                            introText: "Kay draws his sword beside you. 'I've always got your back, Wart.'",
                            outroText: nil,
                            allyReinforcementID: CardCatalog.HeroIDs.kay
                        ),
                    ],
                    openingNarrative: "King Pellinore chases the Questing Beast through these woods. Tonight its hunting-hounds found you first.",
                    victoryNarrative: "'Not bad,' Kay admits reluctantly. 'For a dreamer.'",
                    heroDialogue: [
                        CardCatalog.HeroIDs.kay: "Kay snorts. 'This is nothing. Remember when we faced those three outlaws?'"
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
                                supportEnemyIDs: [EnemyCatalogBook1.forestSprite.id, EnemyCatalogBook1.forestSprite.id]
                            ),
                            introText: "Knights hungry for glory block your path to the tournament grounds.",
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
                                supportEnemyIDs: [EnemyCatalogBook1.forestSprite.id]
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
                            introText: "The dream wears Sir Ector's face. But the eyes are wrong.",
                            outroText: nil
                        ),
                    ],
                    openingNarrative: nil,
                    victoryNarrative: nil,
                    heroDialogue: [
                        CardCatalog.HeroIDs.lancelot: "Lancelot's hand is on his sword. 'Whatever waits at that stone, we face it together.'",
                        CardCatalog.HeroIDs.kay: "Kay scowls. 'Just get Wart to the stone. I'll handle the rest.'"
                    ]
                ),
                isBoss: true
            ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 2: The Queen of Air and Darkness
    // Morgause's dark magic, the Orkney sons, fey creatures
    // ─────────────────────────────────────────────────────────────────────────

    private static let chapter2Stages: [Stage] = [
        Stage(
            id: stageID(2, 1),
            index: 0,
            name: "The Road to Orkney",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 1),
                waves: [
                    BattleWave(
                        id: waveID(2, 1, 1),
                        encounter: Encounter(id: encounterID(2, 1, 1), primaryEnemyID: EnemyCatalogBook1.shadowWisp.id, supportEnemyIDs: [EnemyCatalogBook1.shadowWisp.id]),
                        introText: "The northern road grows cold. Shadows move wrong.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The next chapter opens to mist and whispers. Queen Morgause waits in the north.",
                victoryNarrative: "The shadow disperses. But there will be more.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 2),
            index: 1,
            name: "The Orkney Shore",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 2),
                waves: [
                    BattleWave(
                        id: waveID(2, 2, 1),
                        encounter: Encounter(id: encounterID(2, 2, 1), primaryEnemyID: EnemyCatalogBook1.orkneyGuard.id, supportEnemyIDs: [EnemyCatalogBook1.shadowWisp.id]),
                        introText: "Guards spot you on the beach. 'No strangers in Orkney!'",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The black rocks of Orkney rise from the sea like broken teeth.",
                victoryNarrative: "You slip past the patrol. The castle looms ahead.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 3),
            index: 2,
            name: "The Castle Gate",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 3),
                waves: [
                    BattleWave(
                        id: waveID(2, 3, 1),
                        encounter: Encounter(id: encounterID(2, 3, 1), primaryEnemyID: EnemyCatalogBook1.orkneyGuard.id, supportEnemyIDs: []),
                        introText: "The gate guards cross their spears.",
                        outroText: nil
                    ),
                    BattleWave(
                        id: waveID(2, 3, 2),
                        encounter: Encounter(id: encounterID(2, 3, 2), primaryEnemyID: EnemyCatalogBook1.orkneyGuard.id, supportEnemyIDs: []),
                        introText: "A one-armed knight plants himself beside you. 'Hold. I'll vouch for this one.'",
                        outroText: nil,
                        allyReinforcementID: CardCatalog.HeroIDs.bedivere
                    ),
                ],
                openingNarrative: "Morgause's castle is beautiful and terrible. Like its queen.",
                victoryNarrative: "The gate falls silent. A one-armed knight steps from the shadows and lowers his shield.",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot studies the walls. 'I know this gate. Someone I trusted once held it.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 4),
            index: 3,
            name: "The Servant's Passage",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 4),
                waves: [
                    BattleWave(
                        id: waveID(2, 4, 1),
                        encounter: Encounter(id: encounterID(2, 4, 1), primaryEnemyID: EnemyCatalogBook1.shadowWisp.id, supportEnemyIDs: [EnemyCatalogBook1.shadowWisp.id, EnemyCatalogBook1.shadowWisp.id]),
                        introText: "The passage fills with whispering shadows.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Secret ways wind through the castle walls. Not all secrets are safe.",
                victoryNarrative: "Light returns. But you feel watched.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 5),
            index: 4,
            name: "The Kennels",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 5),
                waves: [
                    BattleWave(
                        id: waveID(2, 5, 1),
                        encounter: Encounter(id: encounterID(2, 5, 1), primaryEnemyID: EnemyCatalogBook1.enchantedHound.id, supportEnemyIDs: []),
                        introText: "The hound's eyes glow with unnatural light.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Morgause's hunting beasts are not natural creatures.",
                victoryNarrative: "The hound whimpers and fades. Even enchantments can be broken.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 6),
            index: 5,
            name: "The Four Brothers",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 6),
                waves: [
                    BattleWave(
                        id: waveID(2, 6, 1),
                        encounter: Encounter(id: encounterID(2, 6, 1), primaryEnemyID: EnemyCatalogBook1.orkneyGuard.id, supportEnemyIDs: [EnemyCatalogBook1.orkneyGuard.id, EnemyCatalogBook1.shadowWisp.id]),
                        introText: "Morgause's sons watch from the wall. They send their guards instead.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "They are not evil. Not yet. But their mother's shadow lies heavy on them.",
                victoryNarrative: "'We're not your enemies,' Gawaine calls down. 'Not yet. Go, before Mother sees.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 7),
            index: 6,
            name: "The Witch's Garden",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 7),
                waves: [
                    BattleWave(
                        id: waveID(2, 7, 1),
                        encounter: Encounter(id: encounterID(2, 7, 1), primaryEnemyID: EnemyCatalogBook1.shadowWisp.id, supportEnemyIDs: [EnemyCatalogBook1.enchantedHound.id]),
                        introText: "The garden grows things that should not exist.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Moonflowers that bloom at noon. Roses that sing. Beauty twisted wrong.",
                victoryNarrative: "The garden falls silent. Morgause knows you're here.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 8),
            index: 7,
            name: "The Dark Mirror",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 8),
                waves: [
                    BattleWave(
                        id: waveID(2, 8, 1),
                        encounter: Encounter(id: encounterID(2, 8, 1), primaryEnemyID: EnemyCatalogBook1.enchantedHound.id, supportEnemyIDs: [EnemyCatalogBook1.shadowWisp.id, EnemyCatalogBook1.shadowWisp.id]),
                        introText: "Morgause's mirror shows terrible truths.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The mirror shows you older. Crowned. Alone.",
                victoryNarrative: "The mirror cracks. From the dark, a woman's voice: 'Impressive. For a child.'",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot shields his eyes from the mirror. 'Don't look too long, dreamer.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 9),
            index: 8,
            name: "The Throne Room Approach",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 9),
                waves: [
                    BattleWave(
                        id: waveID(2, 9, 1),
                        encounter: Encounter(id: encounterID(2, 9, 1), primaryEnemyID: EnemyCatalogBook1.orkneyGuard.id, supportEnemyIDs: [EnemyCatalogBook1.orkneyGuard.id, EnemyCatalogBook1.shadowWisp.id]),
                        introText: "The last guards before the queen.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "You can feel Morgause's power radiating from the throne room.",
                victoryNarrative: "The doors swing open. She's waiting.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(2, 10),
            index: 9,
            name: "Queen of Air and Darkness",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(2, 10),
                waves: [
                    BattleWave(
                        id: waveID(2, 10, 1),
                        encounter: Encounter(id: encounterID(2, 10, 1), primaryEnemyID: EnemyCatalogBook1.enchantedHound.id, supportEnemyIDs: [EnemyCatalogBook1.shadowWisp.id]),
                        introText: "Her hounds attack first. She watches, amused.",
                        outroText: "'Enough,' Morgause says. 'Face me yourself, little dreamer.'"
                    ),
                    BattleWave(
                        id: waveID(2, 10, 2),
                        encounter: Encounter(id: encounterID(2, 10, 2), primaryEnemyID: EnemyCatalogBook1.queenMorgause.id, supportEnemyIDs: []),
                        introText: "The Queen of Air and Darkness rises from her throne.",
                        outroText: nil
                    ),
                ],
                openingNarrative: nil,
                victoryNarrative: nil,
                heroDialogue: [
                    CardCatalog.HeroIDs.morgana: "Morgana faces her sister. 'This ends, Morgause. Here.'",
                    CardCatalog.HeroIDs.bedivere: "Bedivere raises his shield. 'For the king. For Camelot.'"
                ]
            ),
            isBoss: true
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 3: The Ill-Made Knight
    // Lancelot's trials, tournaments, the cost of honor
    // ─────────────────────────────────────────────────────────────────────────

    private static let chapter3Stages: [Stage] = [
        Stage(
            id: stageID(3, 1),
            index: 0,
            name: "The Tournament Grounds",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 1),
                waves: [
                    BattleWave(
                        id: waveID(3, 1, 1),
                        encounter: Encounter(id: encounterID(3, 1, 1), primaryEnemyID: EnemyCatalogBook1.tournamentSquire.id, supportEnemyIDs: [EnemyCatalogBook1.tournamentSquire.id]),
                        introText: "Young squires challenge you for practice.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The tournament field stretches before you. Knights from every land gather.",
                victoryNarrative: "A good warm-up. But the real challenges await.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 2),
            index: 1,
            name: "The First Joust",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 2),
                waves: [
                    BattleWave(
                        id: waveID(3, 2, 1),
                        encounter: Encounter(id: encounterID(3, 2, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: []),
                        introText: "A rival knight rides out, lance lowered.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The crowd roars. Your first challenger salutes.",
                victoryNarrative: "'Well struck!' the knight laughs, offering his hand.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 3),
            index: 2,
            name: "The Pavilion of Challengers",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 3),
                waves: [
                    BattleWave(
                        id: waveID(3, 3, 1),
                        encounter: Encounter(id: encounterID(3, 3, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: [EnemyCatalogBook1.tournamentSquire.id]),
                        introText: "Two knights attack at once—against all rules of honor.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Not all knights fight fair. Some care only for winning.",
                victoryNarrative: "The crowd boos the dishonorable pair. Your reputation grows.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 4),
            index: 3,
            name: "The Forest Chapel",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 4),
                waves: [
                    BattleWave(
                        id: waveID(3, 4, 1),
                        encounter: Encounter(id: encounterID(3, 4, 1), primaryEnemyID: EnemyCatalogBook1.waywardKnight.id, supportEnemyIDs: [EnemyCatalogBook1.waywardKnight.id]),
                        introText: "Bandits desecrate a holy place.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The Grail calls to the pure of heart. Are you worthy?",
                victoryNarrative: "The chapel bells ring softly. A blessing, perhaps.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 5),
            index: 4,
            name: "Sir Turquine's Castle",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 5),
                waves: [
                    BattleWave(
                        id: waveID(3, 5, 1),
                        encounter: Encounter(id: encounterID(3, 5, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: [EnemyCatalogBook1.rivalKnight.id]),
                        introText: "Turquine's guards move to block you.",
                        outroText: "A massive figure emerges. 'Who dares?'"
                    ),
                    BattleWave(
                        id: waveID(3, 5, 2),
                        encounter: Encounter(id: encounterID(3, 5, 2), primaryEnemyID: EnemyCatalogBook1.sirTurquine.id, supportEnemyIDs: []),
                        introText: "Sir Turquine has imprisoned sixty knights. You will free them.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Turquine hates Lancelot above all others. He takes his fury out on everyone.",
                victoryNarrative: "The prisoners stumble into the light. Among them: Escanor, called the Noonday Pride.",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot's eyes harden. 'Turquine. At last.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 6),
            index: 5,
            name: "The Perilous Bridge",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 6),
                waves: [
                    BattleWave(
                        id: waveID(3, 6, 1),
                        encounter: Encounter(id: encounterID(3, 6, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: [EnemyCatalogBook1.rivalKnight.id, EnemyCatalogBook1.tournamentSquire.id]),
                        introText: "The bridge is narrow. They have the advantage.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The Sword Bridge cuts like a razor. Only true knights dare cross.",
                victoryNarrative: "Your hands are raw, but you cross. Nothing will stop you.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 7),
            index: 6,
            name: "The Queen's Defense",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 7),
                waves: [
                    BattleWave(
                        id: waveID(3, 7, 1),
                        encounter: Encounter(id: encounterID(3, 7, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: [EnemyCatalogBook1.rivalKnight.id]),
                        introText: "Knights who would harm Guinevere must fall.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The queen has been accused. Champions must fight for her honor.",
                victoryNarrative: "Honor demands sacrifice. Love demands more.",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot trembles. 'For her. Always for her.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 8),
            index: 7,
            name: "The Grail Castle",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 8),
                waves: [
                    BattleWave(
                        id: waveID(3, 8, 1),
                        encounter: Encounter(id: encounterID(3, 8, 1), primaryEnemyID: EnemyCatalogBook1.sirTurquine.id, supportEnemyIDs: []),
                        introText: "A shadow shaped like Turquine guards the way — the dream remembers your fears.",
                        outroText: nil
                    ),
                ],
                openingNarrative: nil,
                victoryNarrative: "The guardian fades. Light fills the hall — and a young knight steps out of it.",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot hesitates at the threshold. 'I am not sure the pure will have me.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 9),
            index: 8,
            name: "The Accusation",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 9),
                waves: [
                    BattleWave(
                        id: waveID(3, 9, 1),
                        encounter: Encounter(id: encounterID(3, 9, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: [EnemyCatalogBook1.rivalKnight.id, EnemyCatalogBook1.rivalKnight.id]),
                        introText: "Accusers swarm. Truth will not save you.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Whispers of Lancelot and the Queen. The court divides.",
                victoryNarrative: "You escape. But the damage is done. War comes.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(3, 10),
            index: 9,
            name: "The Knight of Ill-Making",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(3, 10),
                waves: [
                    BattleWave(
                        id: waveID(3, 10, 1),
                        encounter: Encounter(id: encounterID(3, 10, 1), primaryEnemyID: EnemyCatalogBook1.rivalKnight.id, supportEnemyIDs: [EnemyCatalogBook1.rivalKnight.id]),
                        introText: "Meliagrance's men attack.",
                        outroText: "Meliagrance himself appears. 'The Queen will be mine.'"
                    ),
                    BattleWave(
                        id: waveID(3, 10, 2),
                        encounter: Encounter(id: encounterID(3, 10, 2), primaryEnemyID: EnemyCatalogBook1.sirMeliagrance.id, supportEnemyIDs: []),
                        introText: "The treacherous knight draws his sword.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Meliagrance took the Queen. Now he pays.",
                victoryNarrative: nil,
                heroDialogue: [
                    CardCatalog.HeroIDs.galahad: "Galahad prays. 'Father, your sins are not mine. I forgive you.'",
                    CardCatalog.HeroIDs.escanor: "Escanor blazes with fury. 'This villain DARES touch the Queen?'"
                ]
            ),
            isBoss: true
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 4: The Candle in the Wind
    // Civil war, Mordred's rebellion, the fall of Camelot
    // ─────────────────────────────────────────────────────────────────────────

    private static let chapter4Stages: [Stage] = [
        Stage(
            id: stageID(4, 1),
            index: 0,
            name: "The Gathering Storm",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 1),
                waves: [
                    BattleWave(
                        id: waveID(4, 1, 1),
                        encounter: Encounter(id: encounterID(4, 1, 1), primaryEnemyID: EnemyCatalogBook1.mordredSoldier.id, supportEnemyIDs: [EnemyCatalogBook1.mordredSoldier.id]),
                        introText: "Mordred's scouts. The war has begun.",
                        outroText: nil
                    ),
                ],
                openingNarrative: nil,
                victoryNarrative: "The scouts scatter. In the silence, an old man steps through a tear in the air itself.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 2),
            index: 1,
            name: "The Traitor's March",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 2),
                waves: [
                    BattleWave(
                        id: waveID(4, 2, 1),
                        encounter: Encounter(id: encounterID(4, 2, 1), primaryEnemyID: EnemyCatalogBook1.mordredSoldier.id, supportEnemyIDs: [EnemyCatalogBook1.fallenKnight.id]),
                        introText: "More soldiers. Mordred's army grows.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Knights who once served Arthur now serve his son. His destroyer.",
                victoryNarrative: "Every victory feels like defeat. These were your brothers.",
                heroDialogue: [
                    CardCatalog.HeroIDs.merlin: "Merlyn sighs. 'I told him. I told him about Mordred. He wouldn't listen.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 3),
            index: 2,
            name: "The Broken Table",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 3),
                waves: [
                    BattleWave(
                        id: waveID(4, 3, 1),
                        encounter: Encounter(id: encounterID(4, 3, 1), primaryEnemyID: EnemyCatalogBook1.fallenKnight.id, supportEnemyIDs: [EnemyCatalogBook1.fallenKnight.id, EnemyCatalogBook1.mordredSoldier.id]),
                        introText: "In Camelot's great hall, knights fight knights.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The Round Table cracks. Brotherhood ends.",
                victoryNarrative: "The hall is silent now. Only ghosts remain.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 4),
            index: 3,
            name: "Agravaine's Ambush",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 4),
                waves: [
                    BattleWave(
                        id: waveID(4, 4, 1),
                        encounter: Encounter(id: encounterID(4, 4, 1), primaryEnemyID: EnemyCatalogBook1.sirAgravaine.id, supportEnemyIDs: [EnemyCatalogBook1.fallenKnight.id]),
                        introText: "Agravaine springs his trap!",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Agravaine exposed Lancelot and the Queen. Now he pays the price.",
                victoryNarrative: "Agravaine flees into the dark. But his damage is done.",
                heroDialogue: [
                    CardCatalog.HeroIDs.kay: "Kay spits. 'Agravaine was always rotten. Even as a boy.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 5),
            index: 4,
            name: "The Siege of Joyous Gard",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 5),
                waves: [
                    BattleWave(
                        id: waveID(4, 5, 1),
                        encounter: Encounter(id: encounterID(4, 5, 1), primaryEnemyID: EnemyCatalogBook1.mordredSoldier.id, supportEnemyIDs: [EnemyCatalogBook1.mordredSoldier.id, EnemyCatalogBook1.mordredSoldier.id]),
                        introText: "They assault Lancelot's castle.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Joyous Gard, once a place of celebration. Now besieged.",
                victoryNarrative: "The walls hold. For now.",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot defends his home. 'I never wanted this war.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 6),
            index: 5,
            name: "The French Campaign",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 6),
                waves: [
                    BattleWave(
                        id: waveID(4, 6, 1),
                        encounter: Encounter(id: encounterID(4, 6, 1), primaryEnemyID: EnemyCatalogBook1.fallenKnight.id, supportEnemyIDs: [EnemyCatalogBook1.fallenKnight.id]),
                        introText: "Arthur pursues Lancelot across the sea.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "While Arthur fights abroad, Mordred claims the throne.",
                victoryNarrative: "Word arrives: Mordred has declared himself king.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 7),
            index: 6,
            name: "The Return",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 7),
                waves: [
                    BattleWave(
                        id: waveID(4, 7, 1),
                        encounter: Encounter(id: encounterID(4, 7, 1), primaryEnemyID: EnemyCatalogBook1.mordredSoldier.id, supportEnemyIDs: [EnemyCatalogBook1.mordredSoldier.id, EnemyCatalogBook1.fallenKnight.id]),
                        introText: "Mordred's forces meet Arthur at the shore.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Arthur returns. His own son waits with an army.",
                victoryNarrative: "You break through. Dover burns behind you.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 8),
            index: 7,
            name: "The Eve of Camlann",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 8),
                waves: [
                    BattleWave(
                        id: waveID(4, 8, 1),
                        encounter: Encounter(id: encounterID(4, 8, 1), primaryEnemyID: EnemyCatalogBook1.fallenKnight.id, supportEnemyIDs: [EnemyCatalogBook1.fallenKnight.id, EnemyCatalogBook1.fallenKnight.id]),
                        introText: "The night before the final battle.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Tomorrow, everything ends. Tonight, there are still enemies to face.",
                victoryNarrative: "Sleep comes hard. Dreams of what might have been.",
                heroDialogue: [
                    CardCatalog.HeroIDs.bedivere: "Bedivere prays. 'Let me serve him to the end.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 9),
            index: 8,
            name: "The Battle of Camlann",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 9),
                waves: [
                    BattleWave(
                        id: waveID(4, 9, 1),
                        encounter: Encounter(id: encounterID(4, 9, 1), primaryEnemyID: EnemyCatalogBook1.sirAgravaine.id, supportEnemyIDs: [EnemyCatalogBook1.mordredSoldier.id, EnemyCatalogBook1.mordredSoldier.id]),
                        introText: "Chaos. Smoke. The end of an age.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "A hundred thousand fall. The flower of chivalry, destroyed.",
                victoryNarrative: "Through the smoke, you see Mordred. And Arthur.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(4, 10),
            index: 9,
            name: "Father and Son",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(4, 10),
                waves: [
                    BattleWave(
                        id: waveID(4, 10, 1),
                        encounter: Encounter(id: encounterID(4, 10, 1), primaryEnemyID: EnemyCatalogBook1.fallenKnight.id, supportEnemyIDs: [EnemyCatalogBook1.fallenKnight.id]),
                        introText: "Mordred's last guards.",
                        outroText: "They fall. Only Mordred remains."
                    ),
                    BattleWave(
                        id: waveID(4, 10, 2),
                        encounter: Encounter(id: encounterID(4, 10, 2), primaryEnemyID: EnemyCatalogBook1.mordred.id, supportEnemyIDs: []),
                        introText: "The son of Arthur. The doom of Camelot.",
                        outroText: nil
                    ),
                ],
                openingNarrative: nil,
                victoryNarrative: nil,
                heroDialogue: [
                    CardCatalog.HeroIDs.bedivere: "Bedivere grips his shield. 'Whatever the king asks of me today, I will do.'",
                    CardCatalog.HeroIDs.merlin: "Merlyn is silent. He already knows what comes next."
                ]
            ),
            isBoss: true
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 5: The Book of Merlyn
    // Final wisdom, confronting the dream's truth
    // ─────────────────────────────────────────────────────────────────────────

    private static let chapter5Stages: [Stage] = [
        Stage(
            id: stageID(5, 1),
            index: 0,
            name: "The Shore of Avalon",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 1),
                waves: [
                    BattleWave(
                        id: waveID(5, 1, 1),
                        encounter: Encounter(id: encounterID(5, 1, 1), primaryEnemyID: EnemyCatalogBook1.memoryFragment.id, supportEnemyIDs: [EnemyCatalogBook1.memoryFragment.id]),
                        introText: "Memories of battles past rise from the mist.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The final chapter. Merlyn waits on the shore of Avalon.",
                victoryNarrative: "'You've come far,' Merlyn says. 'But the hardest lesson remains.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 2),
            index: 1,
            name: "The Lesson of the Ants",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 2),
                waves: [
                    BattleWave(
                        id: waveID(5, 2, 1),
                        encounter: Encounter(id: encounterID(5, 2, 1), primaryEnemyID: EnemyCatalogBook1.memoryFragment.id, supportEnemyIDs: [EnemyCatalogBook1.memoryFragment.id, EnemyCatalogBook1.memoryFragment.id]),
                        introText: "EVERYTHING NOT FORBIDDEN IS COMPULSORY.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "War is what happens when we forget we're all the same species.",
                victoryNarrative: "'Good,' Merlyn nods. 'You remember.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 3),
            index: 2,
            name: "The Lesson of the Geese",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 3),
                waves: [
                    BattleWave(
                        id: waveID(5, 3, 1),
                        encounter: Encounter(id: encounterID(5, 3, 1), primaryEnemyID: EnemyCatalogBook1.memoryFragment.id, supportEnemyIDs: []),
                        introText: "Borders are imaginary lines.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "From above, there are no nations. Only one world.",
                victoryNarrative: "'We forget,' Merlyn says, 'that we made the things that divide us.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 4),
            index: 3,
            name: "The Lesson of the Badger",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 4),
                waves: [
                    BattleWave(
                        id: waveID(5, 4, 1),
                        encounter: Encounter(id: encounterID(5, 4, 1), primaryEnemyID: EnemyCatalogBook1.memoryFragment.id, supportEnemyIDs: [EnemyCatalogBook1.memoryFragment.id]),
                        introText: "Why do humans make war?",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Other animals fight. Only humans make war on purpose.",
                victoryNarrative: "'Because we can imagine,' Merlyn says. 'And imagination can be poison.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 5),
            index: 4,
            name: "The Weight of the Crown",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 5),
                waves: [
                    BattleWave(
                        id: waveID(5, 5, 1),
                        encounter: Encounter(id: encounterID(5, 5, 1), primaryEnemyID: EnemyCatalogBook1.dreamerDoubt.id, supportEnemyIDs: []),
                        introText: "Your own doubt attacks you.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Arthur doubted himself constantly. That's what made him great.",
                victoryNarrative: "Doubt defeated—but not destroyed. It will always be there.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 6),
            index: 5,
            name: "The Faces of Friends",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 6),
                waves: [
                    BattleWave(
                        id: waveID(5, 6, 1),
                        encounter: Encounter(id: encounterID(5, 6, 1), primaryEnemyID: EnemyCatalogBook1.memoryFragment.id, supportEnemyIDs: [EnemyCatalogBook1.memoryFragment.id]),
                        introText: "The ghosts of fallen companions.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Remember those who stood with you. Their sacrifice matters.",
                victoryNarrative: "They smile as they fade. They're proud of you.",
                heroDialogue: [
                    CardCatalog.HeroIDs.lancelot: "Lancelot sees ghosts of Gareth and Gaheris. 'I'm sorry. I'm so sorry.'"
                ]
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 7),
            index: 6,
            name: "The Dreamer's Fear",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 7),
                waves: [
                    BattleWave(
                        id: waveID(5, 7, 1),
                        encounter: Encounter(id: encounterID(5, 7, 1), primaryEnemyID: EnemyCatalogBook1.dreamerDoubt.id, supportEnemyIDs: [EnemyCatalogBook1.memoryFragment.id]),
                        introText: "What if the dream ends? What if you never wake?",
                        outroText: nil
                    ),
                ],
                openingNarrative: "The deepest fear: being trapped forever in a dream of your own making.",
                victoryNarrative: "'Dreams end,' Merlyn says gently. 'That's what makes them precious.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 8),
            index: 7,
            name: "The Once and Future",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 8),
                waves: [
                    BattleWave(
                        id: waveID(5, 8, 1),
                        encounter: Encounter(id: encounterID(5, 8, 1), primaryEnemyID: EnemyCatalogBook1.dreamerDoubt.id, supportEnemyIDs: [EnemyCatalogBook1.dreamerDoubt.id]),
                        introText: "Rex Quondam, Rexque Futurus. The Once and Future King.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "Arthur sleeps in Avalon. He will return when Britain needs him most.",
                victoryNarrative: "'And so will you,' Merlyn smiles. 'You're part of that story now.'",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 9),
            index: 8,
            name: "The Last Lesson",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 9),
                waves: [
                    BattleWave(
                        id: waveID(5, 9, 1),
                        encounter: Encounter(id: encounterID(5, 9, 1), primaryEnemyID: EnemyCatalogBook1.dreamerDoubt.id, supportEnemyIDs: [EnemyCatalogBook1.memoryFragment.id, EnemyCatalogBook1.memoryFragment.id]),
                        introText: "Everything you've learned. Everything you've lost.",
                        outroText: nil
                    ),
                ],
                openingNarrative: "'The best thing for sadness,' Merlyn says, 'is to learn something.'",
                victoryNarrative: "You have learned so much. You are ready.",
                heroDialogue: nil
            ),
            isBoss: false
        ),
        Stage(
            id: stageID(5, 10),
            index: 9,
            name: "The Awakening",
            encounter: nil,
            battle: MultistageBattle(
                id: battleID(5, 10),
                waves: [
                    BattleWave(
                        id: waveID(5, 10, 1),
                        encounter: Encounter(id: encounterID(5, 10, 1), primaryEnemyID: EnemyCatalogBook1.dreamerDoubt.id, supportEnemyIDs: [EnemyCatalogBook1.dreamerDoubt.id]),
                        introText: "Your doubt makes one last stand.",
                        outroText: "Light fills the world. The dream fights to end."
                    ),
                    BattleWave(
                        id: waveID(5, 10, 2),
                        encounter: Encounter(id: encounterID(5, 10, 2), primaryEnemyID: EnemyCatalogBook1.theAwakening.id, supportEnemyIDs: []),
                        introText: "Morning comes. Will you hold onto the dream?",
                        outroText: nil
                    ),
                ],
                openingNarrative: nil,
                victoryNarrative: nil,
                heroDialogue: nil
            ),
            isBoss: true
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - ID Generators
    // ─────────────────────────────────────────────────────────────────────────
    // UUID format: 8-4-4-4-12 hex characters
    // Schema: KKCCSSNN-WWWW-4000-8000-000000000001
    //   KK = kind (D1=chapter, D2=stage, D3=battle, D4=wave, D5=encounter)
    //   CC = chapter (01-99)
    //   SS = stage (01-99)
    //   NN = reserved
    //   WWWW = wave index for waves/encounters

    private static func chapterID(_ chapter: Int) -> UUID {
        UUID(uuidString: String(format: "D1%02d0000-0000-4000-8000-000000000001", chapter))!
    }

    private static func stageID(_ chapter: Int, _ stage: Int) -> UUID {
        UUID(uuidString: String(format: "D2%02d%02d00-0000-4000-8000-000000000001", chapter, stage))!
    }

    private static func battleID(_ chapter: Int, _ stage: Int) -> UUID {
        UUID(uuidString: String(format: "D3%02d%02d00-0000-4000-8000-000000000001", chapter, stage))!
    }

    private static func waveID(_ chapter: Int, _ stage: Int, _ wave: Int) -> UUID {
        UUID(uuidString: String(format: "D4%02d%02d00-%04d-4000-8000-000000000001", chapter, stage, wave))!
    }

    private static func encounterID(_ chapter: Int, _ stage: Int, _ wave: Int) -> UUID {
        UUID(uuidString: String(format: "D5%02d%02d00-%04d-4000-8000-000000000001", chapter, stage, wave))!
    }
}
