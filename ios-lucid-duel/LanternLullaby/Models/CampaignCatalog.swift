import Foundation

/// Static enemy and chapter content, mirroring `CardCatalog`.
///
/// IDs are fixed so saved progress references stay stable across sessions.
/// The sample content below shows one enemy per tier, each exercising a
/// different `AttackPattern`, plus a first chapter that sequences them.
nonisolated enum CampaignCatalog {
    private static func stableID(_ uuidString: String) -> UUID {
        UUID(uuidString: uuidString) ?? UUID()
    }

    // MARK: - Enemies

    /// Minion — the current MVP behavior, expressed as data.
    static let dozingWisp = Enemy(
        id: stableID("C1000000-0000-4000-8000-000000000001"),
        name: "Dozing Wisp",
        tier: .minion,
        maxHealth: 60,
        pattern: .skirmish(range: 8...15, heavyEvery: 3, heavyDamage: 20),
        iconName: "moon.zzz.fill",
        artName: "dozing_wisp",
        fullBodyArtName: "dozing_wisp_full",
        passive: nil
    )

    /// Elite — a readable four-beat rhythm.
    static let hollowKnight = Enemy(
        id: stableID("C2000000-0000-4000-8000-000000000001"),
        name: "Hollow Knight",
        tier: .elite,
        maxHealth: 120,
        pattern: .scripted(cycle: [
            .attack(14),
            .brace(shield: 12),
            .attack(18),
            .buff(.enrage(amount: 3)),
        ]),
        iconName: "shield.righthalf.filled",
        artName: "hollow_knight",
        fullBodyArtName: "hollow_knight_full",
        passive: nil
    )

    /// Boss — escalates as it loses health, with a passive.
    static let theInsomniac = Enemy(
        id: stableID("C3000000-0000-4000-8000-000000000001"),
        name: "The Insomniac",
        tier: .boss,
        maxHealth: 220,
        pattern: .phased(phases: [
            EnemyPhase(healthThreshold: 1.0, cycle: [
                .attack(12), .attack(16), .brace(shield: 15),
            ]),
            EnemyPhase(healthThreshold: 0.5, cycle: [
                .buff(.windUp(multiplier: 2)), .attack(28), .attack(20),
            ]),
        ]),
        iconName: "eye.fill",
        artName: "the_insomniac",
        fullBodyArtName: "the_insomniac_full",
        passive: PassiveAbility(
            name: "Sleepless Dread",
            text: "Grows more aggressive below half health.",
            kind: .vividFury(amount: 4)
        )
    )

    static let allEnemies: [Enemy] = [dozingWisp, hollowKnight, theInsomniac]

    static func enemy(withID id: Enemy.ID) -> Enemy? {
        allEnemies.first { $0.id == id }
    }

    // MARK: - Chapters

    static let chapterOne = Chapter(
        id: stableID("D1000000-0000-4000-8000-000000000001"),
        index: 0,
        title: "The Fading Light",
        stages: [
            Stage(
                id: stableID("E1000000-0000-4000-8000-000000000001"),
                index: 0,
                name: "Restless Woods",
                encounter: Encounter(
                    id: stableID("F1000000-0000-4000-8000-000000000001"),
                    primaryEnemyID: dozingWisp.id,
                    supportEnemyIDs: []
                ),
                battle: nil,
                isBoss: false
            ),
            Stage(
                id: stableID("E1000000-0000-4000-8000-000000000002"),
                index: 1,
                name: "The Broken Vigil",
                encounter: Encounter(
                    id: stableID("F1000000-0000-4000-8000-000000000002"),
                    primaryEnemyID: hollowKnight.id,
                    supportEnemyIDs: [dozingWisp.id]
                ),
                battle: nil,
                isBoss: false
            ),
            Stage(
                id: stableID("E1000000-0000-4000-8000-000000000003"),
                index: 2,
                name: "The Sleepless Throne",
                encounter: Encounter(
                    id: stableID("F1000000-0000-4000-8000-000000000003"),
                    primaryEnemyID: theInsomniac.id,
                    supportEnemyIDs: []
                ),
                battle: nil,
                isBoss: true
            ),
        ]
    )

    static let allChapters: [Chapter] = [chapterOne]

    static func chapter(withID id: Chapter.ID) -> Chapter? {
        allChapters.first { $0.id == id }
    }
}
