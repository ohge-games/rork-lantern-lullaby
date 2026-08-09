import Foundation

// MARK: - Book 1: The Once and Future King (Arthurian)

/// Arthurian enemies organized by chapter theme.
/// Art prompts included as comments for image generation.
enum EnemyCatalogBook1 {

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 1: The Sword in the Stone
    // Setting: The Forest Sauvage, young Wart's journey
    // ─────────────────────────────────────────────────────────────────────────

    /// Forest Wolf — basic minion, prowls the Forest Sauvage
    /// ART: Shadowy wolf with glowing amber eyes, dreamlike misty forest, watercolor
    static let forestWolf = Enemy(
        id: enemyID("C1-M01"),
        name: "Forest Wolf",
        tier: .minion,
        maxHealth: 35,
        pattern: .skirmish(range: 6...10, heavyEvery: 4, heavyDamage: 14),
        iconName: "pawprint.fill",
        artName: "forest_wolf_portrait",
        fullBodyArtName: "forest_wolf_full",
        passive: nil
    )

    /// Wayward Knight — dishonored knight turned bandit
    /// ART: Rusty armor, tattered cloak, broken heraldry, haunted expression, watercolor
    static let waywardKnight = Enemy(
        id: enemyID("C1-M02"),
        name: "Wayward Knight",
        tier: .minion,
        maxHealth: 45,
        pattern: .skirmish(range: 7...12, heavyEvery: 3, heavyDamage: 16),
        iconName: "shield.slash.fill",
        artName: "wayward_knight_portrait",
        fullBodyArtName: "wayward_knight_full",
        passive: nil
    )

    /// Forest Sprite — mischievous fey creature
    /// ART: Tiny glowing figure, moth wings, impish grin, forest backdrop, watercolor
    static let forestSprite = Enemy(
        id: enemyID("C1-M03"),
        name: "Forest Sprite",
        tier: .minion,
        maxHealth: 25,
        pattern: .scripted(cycle: [
            .attack(8),
            .brace(shield: 6),
            .attack(10),
        ]),
        iconName: "sparkles",
        artName: "forest_sprite_portrait",
        fullBodyArtName: "forest_sprite_full",
        passive: nil
    )

    /// Giant Boar — elite creature of the Forest Sauvage
    /// ART: Massive wild boar, foam at mouth, scarred hide, thundering charge, watercolor
    static let giantBoar = Enemy(
        id: enemyID("C1-E01"),
        name: "Giant Boar",
        tier: .elite,
        maxHealth: 70,
        pattern: .scripted(cycle: [
            .buff(.windUp(multiplier: 2)),
            .attack(20),  // Wind-up delivers double
            .brace(shield: 10),
            .attack(12),
        ]),
        iconName: "hare.fill",
        artName: "giant_boar_portrait",
        fullBodyArtName: "giant_boar_full",
        passive: nil
    )

    /// Sir Ector's Challenge — training bout (Chapter 1 Boss)
    /// ART: Kindly older knight in practice armor, wooden sword, castle yard, watercolor
    /// NOTE: Not a hostile enemy — a training challenge. Should have narrative.
    static let sirEctorChallenge = Enemy(
        id: enemyID("C1-B01"),
        name: "Sir Ector",
        tier: .boss,
        maxHealth: 100,
        pattern: .phased(phases: [
            EnemyPhase(healthThreshold: 1.0, cycle: [
                .attack(10),
                .brace(shield: 12),
            ]),
            EnemyPhase(healthThreshold: 0.5, cycle: [
                .attack(14),
                .attack(12),
                .brace(shield: 8),
            ]),
        ]),
        iconName: "person.fill",
        artName: "sir_ector_portrait",
        fullBodyArtName: "sir_ector_full",
        passive: PassiveAbility(
            name: "Training Master",
            text: "Attacks teach rather than harm — damage reduced by 25%.",
            kind: .none  // Flavor passive, actual reduction handled in encounter
        )
    )

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 2: The Queen of Air and Darkness
    // Setting: Morgause's dark magic, Orkney, fey creatures
    // ─────────────────────────────────────────────────────────────────────────

    /// Shadow Wisp — dark fey creature summoned by Morgause
    /// ART: Writhing black smoke with two pale eyes, trailing dark tendrils, watercolor
    static let shadowWisp = Enemy(
        id: enemyID("C2-M01"),
        name: "Shadow Wisp",
        tier: .minion,
        maxHealth: 30,
        pattern: .scripted(cycle: [
            .attack(9),
            .attack(7),
            .brace(shield: 8),
        ]),
        iconName: "smoke.fill",
        artName: "shadow_wisp_portrait",
        fullBodyArtName: "shadow_wisp_full",
        passive: nil
    )

    /// Orkney Guard — soldiers loyal to Queen Morgause
    /// ART: Northern warrior, fur-lined armor, Orkney heraldry, stern face, watercolor
    static let orkneyGuard = Enemy(
        id: enemyID("C2-M02"),
        name: "Orkney Guard",
        tier: .minion,
        maxHealth: 50,
        pattern: .skirmish(range: 8...12, heavyEvery: 3, heavyDamage: 18),
        iconName: "figure.stand",
        artName: "orkney_guard_portrait",
        fullBodyArtName: "orkney_guard_full",
        passive: nil
    )

    /// Enchanted Hound — Morgause's hunting beast
    /// ART: Spectral hound, chains around neck, ghostly blue-green glow, watercolor
    static let enchantedHound = Enemy(
        id: enemyID("C2-E01"),
        name: "Enchanted Hound",
        tier: .elite,
        maxHealth: 65,
        pattern: .scripted(cycle: [
            .attack(14),
            .attack(10),
            .buff(.enrage(amount: 3)),
            .attack(12),
        ]),
        iconName: "dog.fill",
        artName: "enchanted_hound_portrait",
        fullBodyArtName: "enchanted_hound_full",
        passive: nil
    )

    /// Queen Morgause — Chapter 2 Boss
    /// ART: Beautiful but cold queen, dark crown, pale skin, knowing smile, watercolor
    static let queenMorgause = Enemy(
        id: enemyID("C2-B01"),
        name: "Queen Morgause",
        tier: .boss,
        maxHealth: 140,
        pattern: .phased(phases: [
            EnemyPhase(healthThreshold: 1.0, cycle: [
                .attack(12),
                .brace(shield: 15),
                .attack(14),
            ]),
            EnemyPhase(healthThreshold: 0.6, cycle: [
                .buff(.enrage(amount: 4)),
                .attack(16),
                .attack(14),
                .brace(shield: 10),
            ]),
            EnemyPhase(healthThreshold: 0.3, cycle: [
                .attack(20),
                .attack(18),
                .attack(16),
            ]),
        ]),
        iconName: "crown.fill",
        artName: "queen_morgause_portrait",
        fullBodyArtName: "queen_morgause_full",
        passive: PassiveAbility(
            name: "Dark Enchantment",
            text: "At 30% HP, Morgause's attacks ignore 5 shield.",
            kind: .none  // Flavor, handled in combat
        )
    )

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 3: The Ill-Made Knight
    // Setting: Tournaments, rival knights, Lancelot's trials
    // ─────────────────────────────────────────────────────────────────────────

    /// Tournament Squire — young challenger
    /// ART: Eager young squire, borrowed armor, nervous grip on lance, watercolor
    static let tournamentSquire = Enemy(
        id: enemyID("C3-M01"),
        name: "Tournament Squire",
        tier: .minion,
        maxHealth: 35,
        pattern: .skirmish(range: 6...10, heavyEvery: 4, heavyDamage: 14),
        iconName: "person.crop.square",
        artName: "tournament_squire_portrait",
        fullBodyArtName: "tournament_squire_full",
        passive: nil
    )

    /// Rival Knight — skilled tournament competitor
    /// ART: Polished armor, confident stance, jousting lance, tournament grounds, watercolor
    static let rivalKnight = Enemy(
        id: enemyID("C3-M02"),
        name: "Rival Knight",
        tier: .minion,
        maxHealth: 55,
        pattern: .scripted(cycle: [
            .attack(11),
            .brace(shield: 8),
            .attack(13),
            .attack(9),
        ]),
        iconName: "figure.fencing",
        artName: "rival_knight_portrait",
        fullBodyArtName: "rival_knight_full",
        passive: nil
    )

    /// Sir Turquine — brutal knight who captures Round Table members
    /// ART: Massive knight, blood-stained armor, cruel helmet, dark castle, watercolor
    static let sirTurquine = Enemy(
        id: enemyID("C3-E01"),
        name: "Sir Turquine",
        tier: .elite,
        maxHealth: 80,
        pattern: .scripted(cycle: [
            .attack(14),
            .buff(.enrage(amount: 2)),
            .attack(16),
            .brace(shield: 12),
        ]),
        iconName: "bolt.shield.fill",
        artName: "sir_turquine_portrait",
        fullBodyArtName: "sir_turquine_full",
        passive: nil
    )

    /// Sir Meliagrance — treacherous knight, Chapter 3 Boss
    /// ART: Handsome but untrustworthy knight, gold armor, false smile, watercolor
    static let sirMeliagrance = Enemy(
        id: enemyID("C3-B01"),
        name: "Sir Meliagrance",
        tier: .boss,
        maxHealth: 150,
        pattern: .phased(phases: [
            EnemyPhase(healthThreshold: 1.0, cycle: [
                .attack(13),
                .brace(shield: 14),
                .attack(15),
            ]),
            EnemyPhase(healthThreshold: 0.5, cycle: [
                .attack(18),
                .attack(14),
                .buff(.windUp(multiplier: 2)),
                .attack(22),
            ]),
        ]),
        iconName: "theatermasks.fill",
        artName: "sir_meliagrance_portrait",
        fullBodyArtName: "sir_meliagrance_full",
        passive: PassiveAbility(
            name: "Treacherous Strike",
            text: "Wind-up attacks deal triple damage instead of double.",
            kind: .none
        )
    )

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 4: The Candle in the Wind
    // Setting: Civil war, Mordred's rebellion, tragic finale
    // ─────────────────────────────────────────────────────────────────────────

    /// Mordred's Soldier — troops of the usurper
    /// ART: Dark-armored soldier, Mordred's black dragon banner, grim expression, watercolor
    static let mordredSoldier = Enemy(
        id: enemyID("C4-M01"),
        name: "Mordred's Soldier",
        tier: .minion,
        maxHealth: 45,
        pattern: .skirmish(range: 9...13, heavyEvery: 3, heavyDamage: 18),
        iconName: "figure.stand.line.dotted.figure.stand",
        artName: "mordred_soldier_portrait",
        fullBodyArtName: "mordred_soldier_full",
        passive: nil
    )

    /// Fallen Knight — former Round Table member turned traitor
    /// ART: Once-noble knight, cracked armor, shame in eyes, torn heraldry, watercolor
    static let fallenKnight = Enemy(
        id: enemyID("C4-M02"),
        name: "Fallen Knight",
        tier: .minion,
        maxHealth: 55,
        pattern: .scripted(cycle: [
            .attack(12),
            .attack(10),
            .brace(shield: 10),
            .attack(14),
        ]),
        iconName: "person.fill.xmark",
        artName: "fallen_knight_portrait",
        fullBodyArtName: "fallen_knight_full",
        passive: nil
    )

    /// Sir Agravaine — Mordred's chief conspirator
    /// ART: Bitter knight, sharp features, calculating eyes, Orkney colors, watercolor
    static let sirAgravaine = Enemy(
        id: enemyID("C4-E01"),
        name: "Sir Agravaine",
        tier: .elite,
        maxHealth: 85,
        pattern: .scripted(cycle: [
            .attack(15),
            .buff(.enrage(amount: 3)),
            .attack(17),
            .attack(13),
            .brace(shield: 8),
        ]),
        iconName: "eye.fill",
        artName: "sir_agravaine_portrait",
        fullBodyArtName: "sir_agravaine_full",
        passive: nil
    )

    /// Mordred — Chapter 4 Boss, Arthur's doom
    /// ART: Young knight in black armor, pale with dark eyes, dragon helm, tragic beauty, watercolor
    static let mordred = Enemy(
        id: enemyID("C4-B01"),
        name: "Mordred",
        tier: .boss,
        maxHealth: 180,
        pattern: .phased(phases: [
            EnemyPhase(healthThreshold: 1.0, cycle: [
                .attack(14),
                .attack(12),
                .brace(shield: 16),
            ]),
            EnemyPhase(healthThreshold: 0.6, cycle: [
                .buff(.enrage(amount: 3)),
                .attack(18),
                .attack(16),
                .brace(shield: 12),
            ]),
            EnemyPhase(healthThreshold: 0.3, cycle: [
                .attack(24),
                .attack(20),
                .attack(22),
                .buff(.windUp(multiplier: 2)),
                .attack(30),
            ]),
        ]),
        iconName: "crown.fill",
        artName: "mordred_portrait",
        fullBodyArtName: "mordred_full",
        passive: PassiveAbility(
            name: "Fate's Burden",
            text: "Below 30% HP, Mordred gains +5 damage on all attacks.",
            kind: .none
        )
    )

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Chapter 5: The Book of Merlyn
    // Setting: Final wisdom, confronting the dream's truth
    // ─────────────────────────────────────────────────────────────────────────

    /// Memory Fragment — echoes of past battles
    /// ART: Ghostly silhouette of a knight, dissolving at edges, dream-like, watercolor
    static let memoryFragment = Enemy(
        id: enemyID("C5-M01"),
        name: "Memory Fragment",
        tier: .minion,
        maxHealth: 40,
        pattern: .skirmish(range: 8...12, heavyEvery: 3, heavyDamage: 16),
        iconName: "brain.head.profile",
        artName: "memory_fragment_portrait",
        fullBodyArtName: "memory_fragment_full",
        passive: nil
    )

    /// The Dreamer's Doubt — manifestation of fear
    /// ART: Shadowy child figure, mirror of the protagonist, uncertainty made visible, watercolor
    static let dreamerDoubt = Enemy(
        id: enemyID("C5-E01"),
        name: "The Dreamer's Doubt",
        tier: .elite,
        maxHealth: 75,
        pattern: .scripted(cycle: [
            .attack(14),
            .brace(shield: 16),
            .attack(12),
            .buff(.enrage(amount: 2)),
            .attack(16),
        ]),
        iconName: "person.fill.questionmark",
        artName: "dreamers_doubt_portrait",
        fullBodyArtName: "dreamers_doubt_full",
        passive: nil
    )

    /// The Awakening — Final Boss, the pull of consciousness
    /// ART: Brilliant light taking human form, overwhelming brightness, dream ending, watercolor
    static let theAwakening = Enemy(
        id: enemyID("C5-B01"),
        name: "The Awakening",
        tier: .boss,
        maxHealth: 200,
        pattern: .phased(phases: [
            EnemyPhase(healthThreshold: 1.0, cycle: [
                .attack(12),
                .brace(shield: 18),
                .attack(14),
            ]),
            EnemyPhase(healthThreshold: 0.7, cycle: [
                .attack(16),
                .attack(14),
                .brace(shield: 14),
                .buff(.enrage(amount: 2)),
            ]),
            EnemyPhase(healthThreshold: 0.4, cycle: [
                .attack(20),
                .attack(18),
                .attack(16),
                .brace(shield: 10),
            ]),
            EnemyPhase(healthThreshold: 0.15, cycle: [
                .attack(25),
                .attack(22),
                .attack(28),
            ]),
        ]),
        iconName: "sun.max.fill",
        artName: "the_awakening_portrait",
        fullBodyArtName: "the_awakening_full",
        passive: PassiveAbility(
            name: "Inevitable Dawn",
            text: "Each phase grants +2 damage permanently.",
            kind: .none
        )
    )

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Helper
    // ─────────────────────────────────────────────────────────────────────────

    private static func enemyID(_ shortCode: String) -> UUID {
        // Generate stable UUIDs from short codes for consistent saves
        let hash = shortCode.utf8.reduce(0) { $0 &+ UInt64($1) }
        let uuidString = String(format: "E1%06X00-0000-4000-8000-000000000001", hash % 0xFFFFFF)
        return UUID(uuidString: uuidString) ?? UUID()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Collections
    // ─────────────────────────────────────────────────────────────────────────

    static let chapter1Enemies: [Enemy] = [
        forestWolf, waywardKnight, forestSprite, giantBoar, sirEctorChallenge,
    ]

    static let chapter2Enemies: [Enemy] = [
        shadowWisp, orkneyGuard, enchantedHound, queenMorgause,
    ]

    static let chapter3Enemies: [Enemy] = [
        tournamentSquire, rivalKnight, sirTurquine, sirMeliagrance,
    ]

    static let chapter4Enemies: [Enemy] = [
        mordredSoldier, fallenKnight, sirAgravaine, mordred,
    ]

    static let chapter5Enemies: [Enemy] = [
        memoryFragment, dreamerDoubt, theAwakening,
    ]

    static let allEnemies: [Enemy] = 
        chapter1Enemies + chapter2Enemies + chapter3Enemies + chapter4Enemies + chapter5Enemies
}
