import Foundation

// MARK: - Book 1 Narrative Catalog
// Story content linked to specific stages and battle events

enum NarrativeCatalogBook1 {
    
    // MARK: - Chapter 1: The Sword in the Stone
    
    static let chapter1Stage1Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_moonlit_forest",
            lines: [
                .narrator("In the beginning, there was a boy who didn't know he was a king."),
                .narrator("His name was Wart. He was small and overlooked and thought he would never be anyone special."),
                .narrator("He was wrong."),
                .narrator("This is his story. But now, it's also yours.")
            ],
            transitionStyle: .pageTurn
        ),
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                      text: "That was... you were incredible!"),
                .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                      text: "I've never seen anyone fight like that. Maybe we could train together?"),
                .mcThought("Did I really just do that? It felt like the book was... guiding me.")
            ]
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                          text: "Hey! Over here! I don't know how you got here, but I'm glad you did."),
                    .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                          text: "Something's wrong in the forest tonight. The wolves are acting strange."),
                    .mcThought("The lantern in my hand... it's warm. Like it knows where to go.")
                ]
            )
        ]
    )
    
    static let chapter1Stage5Narrative = StageNarrative(
        preStageScene: nil,
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "You fight well, young dreamer. Better than most knights I've known."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "I am Lancelot du Lac. The finest knight in Arthur's service."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "At least... that's what they say. Whether I deserve the title is another matter."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "But I see something in you. A flame that refuses to go out. I would follow that flame, if you'll have me."),
                .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                      text: "Lancelot? THE Lancelot? He's even more impressive than Merlyn's stories!")
            ]
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .heroUnlock(heroID: CardCatalogHeroes.HeroIDs.lancelot),
                lines: [
                    .mcThought("A knight. A real knight. And he wants to follow me?"),
                    .mcThought("I'm just a kid. I just moved here. I spend my lunches reading alone."),
                    .mcThought("But in the dream... I matter.")
                ]
            )
        ]
    )
    
    static let chapter1Stage8Narrative = StageNarrative(
        preStageScene: nil,
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "Wait. You're not one of them."),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "You're with Wart? Of course you are. That boy attracts trouble like honey attracts flies."),
                .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                      text: "Kay! You're okay!"),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "No thanks to you, running off into cursed forests."),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "I'm his brother. Well, foster brother. I'm also the better fighter, the better hunter, and the better everything."),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "But fine. If you're keeping this idiot alive, I suppose I'll help.")
            ]
        ),
        battleDialogues: []
    )
    
    static let chapter1Stage10Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_tournament_grounds",
            lines: [
                .narrator("The tournament grounds spread before you. Knights from every land have gathered."),
                .narrator("But there is only one sword that matters. One stone. One destiny."),
                .narrator("WHOSO PULLETH OUT THIS SWORD OF THIS STONE AND ANVIL IS RIGHTWISE KING BORN OF ALL ENGLAND.")
            ],
            transitionStyle: .dreamRipple
        ),
        postStageScene: StoryScene(
            backgroundImage: "bg_sword_in_stone",
            lines: [
                .narrator("The sword slides free like it was waiting for you. Like it was always yours."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "My king. I will serve you—in dreams and in waking."),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "I always knew. Even when I was terrible to you. I always knew."),
                .mcThought("The sword in the stone. I helped him pull it."),
                .mcThought("I helped make a king."),
                .narrator("You wake. The book is warm in your hands.")
            ],
            transitionStyle: .fade
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .villain(name: "Sir Ector", portrait: "portrait_ector",
                             text: "So. The woodland creatures have brought help."),
                    .villain(name: "Sir Ector", portrait: "portrait_ector",
                             text: "I raised Wart. I know his limits. He will never be more than a servant boy."),
                    .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                          text: "Father..."),
                    .villain(name: "Sir Ector", portrait: "portrait_ector",
                             text: "I am NOT your father. I never was. And I never will be.")
                ]
            ),
            BattleDialogue(
                trigger: .waveStart(waveIndex: 1),
                lines: [
                    .villain(name: "Sir Ector", portrait: "portrait_ector",
                             text: "You think yourself worthy of that sword? Prove it!"),
                    .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                          text: "I'm not fighting for the sword. I'm fighting for my friends.")
                ]
            )
        ]
    )
    
    // MARK: - Chapter 2: The Queen of Air and Darkness
    
    static let chapter2Stage3Narrative = StageNarrative(
        preStageScene: nil,
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "Hold. You're not Morgause's creatures."),
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "And that light... I haven't seen its like in many years."),
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "I am Bedivere. The king's man. The last of his original companions."),
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "I gave my arm for Arthur. I would give the rest if duty demanded."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "Old friend. It's been too long."),
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "The dreamer leads this company? Then so do I. One-armed or not, my shield is yours.")
            ]
        ),
        battleDialogues: []
    )
    
    static let chapter2Stage8Narrative = StageNarrative(
        preStageScene: nil,
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                      text: "You've come far, little dreamer. Farther than most who enter these pages."),
                .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                      text: "I am Morgana le Fay. Called witch by those who fear me. Called worse by those who should know better."),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "She's dangerous. Don't trust her."),
                .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                      text: "I have been many things. Villain. Victim. Villain again. The stories change depending on who tells them."),
                .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                      text: "But your light... it doesn't judge. It simply illuminates."),
                .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                      text: "Let me show you what I could be. If someone believed in me.")
            ]
        ),
        battleDialogues: []
    )
    
    static let chapter2Stage10Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_morgause_throne",
            lines: [
                .narrator("The throne room of Orkney. Shadows dance on the walls."),
                .narrator("She is beautiful. She is terrible. She knows things about Arthur's birth that could break the kingdom.")
            ],
            transitionStyle: .fade
        ),
        postStageScene: StoryScene(
            lines: [
                .villain(name: "Morgause", portrait: "portrait_morgause",
                         text: "You win nothing. The doom is already set. Mordred will come."),
                .narrator("You wake, cold with sweat."),
                .narrator("The book's pages rustle in a wind that isn't there.")
            ],
            transitionStyle: .dreamRipple
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .villain(name: "Morgause", portrait: "portrait_morgause",
                             text: "Little dreamer. You carry a lantern against the dark."),
                    .villain(name: "Morgause", portrait: "portrait_morgause",
                             text: "I AM the dark."),
                    .villain(name: "Morgause", portrait: "portrait_morgause",
                             text: "Join me. The darkness is so much warmer than you'd think.")
                ]
            ),
            BattleDialogue(
                trigger: .enemyHealthThreshold(percent: 50),
                lines: [
                    .villain(name: "Morgause", portrait: "portrait_morgause",
                             text: "You fight well... but you cannot defeat what you do not understand."),
                    .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                          text: "This ends, Morgause. Here. Sister.")
                ]
            )
        ]
    )
    
    // MARK: - Chapter 3: The Ill-Made Knight
    
    static let chapter3Stage5Narrative = StageNarrative(
        preStageScene: nil,
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                      text: "FINALLY! Sixty knights he imprisoned! SIXTY! And none with the courage to face him!"),
                .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                      text: "But you... you are small. Why would one so small dare Turquine's castle?"),
                .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                      text: "They came to help. They always help."),
                .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                      text: "Hmm. Bravery is not measured in inches."),
                .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                      text: "I am Escanor! My strength grows with the sun! I will GRACE this company with my magnificence!"),
                .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                      text: "Great. Another humble one.")
            ]
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                          text: "Turquine. At last. He hates me above all others."),
                    .mcThought("The prison tower looms ahead. Sixty knights wait for rescue.")
                ]
            )
        ]
    )
    
    static let chapter3Stage8Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_grail_castle",
            lines: [
                .narrator("Corbenic. The Grail Castle. Where only the pure may enter.")
            ],
            transitionStyle: .fade
        ),
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                      text: "The light told me you would come."),
                .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                      text: "I am Galahad. Son of Lancelot. Seeker of the Holy Grail."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "My... my son."),
                .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                      text: "Father. Your sins are known to me. And forgiven."),
                .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                      text: "The Grail calls only the pure. But your lantern burns with the same light."),
                .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                      text: "I would be honored to walk this path beside you.")
            ]
        ),
        battleDialogues: []
    )
    
    static let chapter3Stage10Narrative = StageNarrative(
        preStageScene: nil,
        postStageScene: StoryScene(
            lines: [
                .narrator("Justice is served. But at what cost?"),
                .narrator("You wake with tears on your cheeks."),
                .narrator("The book feels heavier now.")
            ],
            transitionStyle: .fade
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .villain(name: "Meliagrance", portrait: "portrait_meliagrance",
                             text: "The queen belongs to me! I claimed her fairly!"),
                    .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                          text: "You kidnapped her. There is nothing fair in that."),
                    .villain(name: "Meliagrance", portrait: "portrait_meliagrance",
                             text: "Fairness is for those too weak to take what they want!")
                ]
            ),
            BattleDialogue(
                trigger: .enemyHealthThreshold(percent: 25),
                lines: [
                    .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                          text: "This villain DARES touch the Queen? Feel the fury of the NOONDAY SUN!")
                ]
            )
        ]
    )
    
    // MARK: - Chapter 4: The Candle in the Wind
    
    static let chapter4Stage1Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_war_camp",
            lines: [
                .narrator("Arthur sails for France. Mordred seizes his chance."),
                .narrator("The war has begun.")
            ],
            transitionStyle: .pageTurn
        ),
        postStageScene: StoryScene(
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "Ah. There you are. I've been looking forward to this."),
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "Or backward to it. Time is rather complicated when you live in the wrong direction."),
                .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                      text: "Merlyn!"),
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "Wart. Still small. Still brave. Still terrible at your lessons."),
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "And you, dreamer. I've seen your future. All the books you'll read. All the dreams you'll dream."),
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "It's rather impressive.")
            ]
        ),
        battleDialogues: []
    )
    
    static let chapter4Stage10Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_camlann",
            lines: [
                .narrator("'In my end is my beginning.'"),
                .narrator("Arthur faces his fate. Father against son. Light against shadow.")
            ],
            transitionStyle: .dreamRipple
        ),
        postStageScene: StoryScene(
            backgroundImage: "bg_avalon_shore",
            lines: [
                .narrator("Mordred falls. But Arthur..."),
                .narrator("'Take me to the lake,' he whispers."),
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "The sword. He asked me to return Excalibur to the lake."),
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "..."),
                .narrator("You wake screaming."),
                .narrator("The book is cold in your hands. But not finished. One chapter remains.")
            ],
            transitionStyle: .fade
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .villain(name: "Mordred", portrait: "portrait_mordred",
                             text: "Do you know what I am?"),
                    .villain(name: "Mordred", portrait: "portrait_mordred",
                             text: "I am Arthur's son. Born of his sin. Hidden. Denied. Cast away."),
                    .villain(name: "Mordred", portrait: "portrait_mordred",
                             text: "He made me. His shame made me. And now his shame will unmake his kingdom."),
                    .villain(name: "Mordred", portrait: "portrait_mordred",
                             text: "You fight for a dream, lantern-bearer. But dreams end. Nightmares last forever.")
                ]
            ),
            BattleDialogue(
                trigger: .enemyHealthThreshold(percent: 30),
                lines: [
                    .villain(name: "Mordred", portrait: "portrait_mordred",
                             text: "Even now he refuses to strike! His own son! His own DOOM!"),
                    .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                          text: "Then I will strike for him. For the king I failed.")
                ]
            )
        ]
    )
    
    // MARK: - Chapter 5: The Book of Merlyn
    
    static let chapter5Stage10Narrative = StageNarrative(
        preStageScene: StoryScene(
            backgroundImage: "bg_avalon_dawn",
            lines: [
                .narrator("The lantern flickers. Dawn approaches."),
                .narrator("You must choose: wake, or sleep forever.")
            ],
            transitionStyle: .dreamRipple
        ),
        postStageScene: StoryScene(
            backgroundImage: "bg_bedroom_morning",
            lines: [
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "Well done. The dream is part of you now. Forever."),
                .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                      text: "Until we meet again, young dreamer. In another story."),
                .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                      text: "You gave us another chance. We won't forget."),
                .hero(CardCatalogHeroes.HeroIDs.bedivere, name: "Bedivere", portrait: "portrait_bedivere",
                      text: "The king would be proud."),
                .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                      text: "The Grail's blessing goes with you."),
                .narrator("You open your eyes."),
                .narrator("Sunlight streams through your window. The book rests on your pillow, closed."),
                .narrator("On the cover, new words have appeared:"),
                .narrator("THE END"),
                .narrator("...AND THE BEGINNING"),
                .mcThought("There are more books on the shelf.")
            ],
            transitionStyle: .fade
        ),
        battleDialogues: [
            BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .villain(name: "The Awakening", portrait: "portrait_awakening",
                             text: "Dreamer. You cannot stay here forever."),
                    .villain(name: "The Awakening", portrait: "portrait_awakening",
                             text: "Morning always comes. Let go. Wake up. Leave them behind."),
                    .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                          text: "Don't listen. The dream can be part of you. Forever."),
                    .mcThought("Not like this. Not until I'm ready.")
                ]
            ),
            BattleDialogue(
                trigger: .enemyHealthThreshold(percent: 25),
                lines: [
                    .villain(name: "The Awakening", portrait: "portrait_awakening",
                             text: "You... you're holding on. How?"),
                    .mcThought("Because they're worth fighting for. Because the story matters."),
                    .mcThought("Because I decide when to wake up.")
                ]
            )
        ]
    )
    
    // MARK: - Hero Combination Dialogues
    // These trigger based on party composition at battle start
    
    static let lancelotGalahadCombo = BattleDialogue(
        trigger: .firstTimeOnly(key: "combo_lancelot_galahad"),
        lines: [
            .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                  text: "Stay behind me. I won't lose you again."),
            .hero(CardCatalogHeroes.HeroIDs.galahad, name: "Galahad", portrait: "portrait_galahad",
                  text: "Father. I am not yours to protect. I am here to protect others."),
            .hero(CardCatalogHeroes.HeroIDs.lancelot, name: "Lancelot", portrait: "portrait_lancelot",
                  text: "I know. That's what makes it harder.")
        ],
        pausesBattle: true
    )
    
    static let kayWartCombo = BattleDialogue(
        trigger: .firstTimeOnly(key: "combo_kay_wart"),
        lines: [
            .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                  text: "Remember when I used to make you carry my armor?"),
            .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                  text: "Every day."),
            .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                  text: "...I'm sorry about that."),
            .hero(CardCatalogHeroes.HeroIDs.wart, name: "Wart", portrait: "portrait_wart",
                  text: "Kay?"),
            .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                  text: "Don't get used to it.")
        ],
        pausesBattle: true
    )
    
    static let morganaMerlinCombo = BattleDialogue(
        trigger: .firstTimeOnly(key: "combo_morgana_merlin"),
        lines: [
            .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                  text: "Old man. Still meddling."),
            .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                  text: "Young woman. Still grudging."),
            .hero(CardCatalogHeroes.HeroIDs.morgana, name: "Morgana", portrait: "portrait_morgana",
                  text: "I could have been your student."),
            .hero(CardCatalogHeroes.HeroIDs.merlin, name: "Merlin", portrait: "portrait_merlin",
                  text: "You could have been more than that. You still can.")
        ],
        pausesBattle: true
    )
    
    static let escanorKayCombo = BattleDialogue(
        trigger: .firstTimeOnly(key: "combo_escanor_kay"),
        lines: [
            .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                  text: "Your confidence is admirable!"),
            .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                  text: "Obviously."),
            .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                  text: "Though misplaced. MY confidence is superior!"),
            .hero(CardCatalogHeroes.HeroIDs.kay, name: "Kay", portrait: "portrait_kay",
                  text: "Is this a competition?"),
            .hero(CardCatalogHeroes.HeroIDs.escanor, name: "Escanor", portrait: "portrait_escanor",
                  text: "One I will WIN!")
        ],
        pausesBattle: true
    )
    
    // MARK: - Lookup
    
    /// Get narrative for a specific stage
    static func narrative(forChapter chapter: Int, stage: Int) -> StageNarrative {
        switch (chapter, stage) {
        case (1, 1): return chapter1Stage1Narrative
        case (1, 5): return chapter1Stage5Narrative
        case (1, 8): return chapter1Stage8Narrative
        case (1, 10): return chapter1Stage10Narrative
        case (2, 3): return chapter2Stage3Narrative
        case (2, 8): return chapter2Stage8Narrative
        case (2, 10): return chapter2Stage10Narrative
        case (3, 5): return chapter3Stage5Narrative
        case (3, 8): return chapter3Stage8Narrative
        case (3, 10): return chapter3Stage10Narrative
        case (4, 1): return chapter4Stage1Narrative
        case (4, 10): return chapter4Stage10Narrative
        case (5, 10): return chapter5Stage10Narrative
        default: return .empty
        }
    }
    
    /// Get hero combo dialogues based on party composition
    static func comboDialogues(forParty heroIDs: [UUID]) -> [BattleDialogue] {
        var dialogues: [BattleDialogue] = []
        let heroSet = Set(heroIDs)
        
        // Check each combo
        if heroSet.contains(CardCatalogHeroes.HeroIDs.lancelot) &&
           heroSet.contains(CardCatalogHeroes.HeroIDs.galahad) {
            dialogues.append(lancelotGalahadCombo)
        }
        
        if heroSet.contains(CardCatalogHeroes.HeroIDs.kay) &&
           heroSet.contains(CardCatalogHeroes.HeroIDs.wart) {
            dialogues.append(kayWartCombo)
        }
        
        if heroSet.contains(CardCatalogHeroes.HeroIDs.morgana) &&
           heroSet.contains(CardCatalogHeroes.HeroIDs.merlin) {
            dialogues.append(morganaMerlinCombo)
        }
        
        if heroSet.contains(CardCatalogHeroes.HeroIDs.escanor) &&
           heroSet.contains(CardCatalogHeroes.HeroIDs.kay) {
            dialogues.append(escanorKayCombo)
        }
        
        return dialogues
    }
}
