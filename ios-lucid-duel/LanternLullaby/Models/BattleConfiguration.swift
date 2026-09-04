import Foundation

/// The enemies that stand together in one wave. The first entry is the
/// primary (front) enemy; the rest fill the support slots behind it.
nonisolated struct WaveSpec: Hashable, Sendable {
    let enemies: [Enemy]

    /// Shield each enemy starts the wave with, parallel to `enemies`.
    /// Missing entries mean zero.
    let openingShields: [Int]

    /// A hero who joins the party when this wave arrives.
    let allyReinforcement: Hero?

    init(enemies: [Enemy], openingShields: [Int] = [], allyReinforcement: Hero? = nil) {
        self.enemies = enemies
        self.openingShields = openingShields
        self.allyReinforcement = allyReinforcement
    }

    func openingShield(at index: Int) -> Int {
        openingShields.indices.contains(index) ? openingShields[index] : 0
    }
}

/// Everything the battle engine needs to stage one fight: who is in the
/// party, which enemies arrive in which waves, what the arena looks like,
/// and which cards go in the deck.
///
/// Built by `CampaignCoordinator` for campaign stages, and by
/// `legacyDuel` for the original Dreamer-vs-Nightmare sandbox that the unit
/// tests and previews still use.
nonisolated struct BattleConfiguration: Sendable {
    let title: String

    /// Heroes in the party, lead hero first. Never empty.
    let party: [Hero]

    /// Waves in order. Never empty; every wave has at least one enemy.
    let waves: [WaveSpec]

    /// Bundled painting behind the battlefield.
    let arenaArtName: String

    /// How far the lantern pulls Lucidity toward Balanced at the start of
    /// each player turn. The campaign uses this in place of the Dreamer's
    /// "Slow Wave" passive, which only the sandbox hero carries.
    let lanternDrift: Int

    /// Card definitions in the deck, one entry per physical copy.
    let deckCardIDs: [Card.ID]

    /// Campaign bookkeeping; `nil` for the sandbox duel.
    let stageID: Stage.ID?
    let chapterIndex: Int

    /// A scripted lesson layered over this battle, if any.
    let tutorial: TutorialScript?

    init(
        title: String,
        party: [Hero],
        waves: [WaveSpec],
        arenaArtName: String,
        lanternDrift: Int,
        deckCardIDs: [Card.ID],
        stageID: Stage.ID? = nil,
        chapterIndex: Int = 0,
        tutorial: TutorialScript? = nil
    ) {
        self.title = title
        self.party = party.isEmpty ? [CardCatalog.dreamer] : party
        // A wave with nobody in it would trap the fight (or index past the
        // end of an empty line), so empty waves are dropped here.
        let filled = waves.filter { !$0.enemies.isEmpty }
        self.waves = filled.isEmpty ? [WaveSpec(enemies: [Self.nightmareEnemy])] : filled
        self.arenaArtName = arenaArtName
        self.lanternDrift = lanternDrift
        self.deckCardIDs = deckCardIDs
        self.stageID = stageID
        self.chapterIndex = chapterIndex
        self.tutorial = tutorial
    }

    var waveCount: Int { waves.count }

    /// Fresh, unshuffled deck instances for this configuration.
    func freshDeck() -> [CardInstance] {
        deckCardIDs.map { CardInstance(cardID: $0) }
    }

    // MARK: - Sandbox duel (the original MVP roster)

    /// The Nightmare as an `Enemy`: the MVP's random 8–15 attacks with a
    /// telegraphed heavy blow every third turn, exactly as before.
    static let nightmareEnemy = Enemy(
        id: CardCatalog.nightmare.id,
        name: CardCatalog.nightmare.name,
        tier: .boss,
        maxHealth: CardCatalog.nightmare.maxHealth,
        pattern: .skirmish(
            range: GameRules.enemyAttackRange,
            heavyEvery: GameRules.enemyHeavyTurnInterval,
            heavyDamage: GameRules.enemyHeavyAttackDamage
        ),
        iconName: "theatermasks.fill",
        artName: "nightmare_shadow_mask",
        fullBodyArtName: "shadow_villain_cloak",
        passive: CardCatalog.nightmare.passive
    )

    static let nightShade = Enemy(
        id: UUID(uuidString: "EE000000-0000-0000-0000-000000000001")!,
        name: "Night Shade",
        tier: .minion,
        maxHealth: 30,
        pattern: .scripted(cycle: [.attack(6)]),
        iconName: "cloud.fog.fill",
        artName: "shadow_creature_fog",
        fullBodyArtName: "night_shade_fog_creature",
        passive: nil
    )

    static let dreadWisp = Enemy(
        id: UUID(uuidString: "EE000000-0000-0000-0000-000000000002")!,
        name: "Dread Wisp",
        tier: .minion,
        maxHealth: 22,
        pattern: .scripted(cycle: [.brace(shield: 5), .attack(5)]),
        iconName: "wind",
        artName: "dread_wisp_spirit",
        fullBodyArtName: "dread_wisp_spirit_2",
        passive: nil
    )

    static let sleepwalker = Hero(
        id: UUID(uuidString: "AA000000-0000-0000-0000-000000000001")!,
        name: "Sleepwalker",
        title: "The Wandering Child",
        maxHealth: 48,
        passive: PassiveAbility(
            name: "Light Step",
            text: "Takes 15% less damage while Balanced.",
            kind: .balancedResilience(percent: 15)
        ),
        storyText: "A child who walks the dream without waking.",
        cardIDs: []
    )

    static let emberMuse = Hero(
        id: UUID(uuidString: "AA000000-0000-0000-0000-000000000002")!,
        name: "Ember Muse",
        title: "Spark of the Lantern",
        maxHealth: 52,
        passive: PassiveAbility(
            name: "Kindled Verse",
            text: "Offensive cards deal 2 extra damage while Vivid.",
            kind: .vividFury(amount: 2)
        ),
        storyText: "A flicker of the lantern's flame given a voice.",
        cardIDs: []
    )

    /// The original sandbox: the Dreamer and two placeholder teammates
    /// against the Nightmare and two minions, in the enchanted forest.
    static let legacyDuel = BattleConfiguration(
        title: "The First Nightmare",
        party: [CardCatalog.dreamer, sleepwalker, emberMuse],
        waves: [
            WaveSpec(
                enemies: [nightmareEnemy, nightShade, dreadWisp],
                openingShields: [0, 0, 5]
            ),
        ],
        arenaArtName: "enchanted_forest_night",
        lanternDrift: 0,
        deckCardIDs: CardCatalog.starterDeck().map(\.cardID)
    )
}
