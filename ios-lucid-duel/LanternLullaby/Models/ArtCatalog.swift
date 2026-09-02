import Foundation

/// Maps content to bundled imageset names.
///
/// Heroes and enemies keep their art out of the model structs so the
/// catalogs stay pure data; this is the one place that knows which painting
/// belongs to whom. Every name here must match an imageset folder in
/// `Assets.xcassets` exactly.
enum ArtCatalog {

    // MARK: - Heroes

    private static let heroFullBodyNames: [UUID: String] = [
        CardCatalog.HeroIDs.wart: "hero_wart_full",
        CardCatalog.HeroIDs.archimedes: "hero_archimedes_full",
        CardCatalog.HeroIDs.lancelot: "hero_lancelot_full",
        CardCatalog.HeroIDs.kay: "hero_kay_full",
        CardCatalog.HeroIDs.bedivere: "hero_bedivere_full",
        CardCatalog.HeroIDs.morgana: "hero_morgana_full",
        CardCatalog.HeroIDs.escanor: "hero_escanor_full",
        CardCatalog.HeroIDs.galahad: "hero_galahad_full",
        CardCatalog.HeroIDs.merlin: "hero_merlin_full",
        CardCatalog.dreamer.id: "child_with_lantern",
        BattleConfiguration.sleepwalker.id: "sleepwalker_child_2",
        BattleConfiguration.emberMuse.id: "ember_fire_spirit_child",
    ]

    private static let heroPortraitNames: [UUID: String] = [
        CardCatalog.dreamer.id: "dreamer_child_portrait",
        BattleConfiguration.sleepwalker.id: "sleepwalker_child",
        BattleConfiguration.emberMuse.id: "ember_muse_portrait",
    ]

    private static let heroIconNames: [UUID: String] = [
        CardCatalog.HeroIDs.wart: "figure.child",
        CardCatalog.HeroIDs.archimedes: "bird.fill",
        CardCatalog.HeroIDs.lancelot: "shield.lefthalf.filled",
        CardCatalog.HeroIDs.kay: "shield.fill",
        CardCatalog.HeroIDs.bedivere: "shield.righthalf.filled",
        CardCatalog.HeroIDs.morgana: "moon.stars.fill",
        CardCatalog.HeroIDs.escanor: "sun.max.fill",
        CardCatalog.HeroIDs.galahad: "sparkles",
        CardCatalog.HeroIDs.merlin: "wand.and.stars",
        CardCatalog.dreamer.id: "moon.stars.fill",
        BattleConfiguration.sleepwalker.id: "figure.walk",
        BattleConfiguration.emberMuse.id: "flame.fill",
    ]

    static func heroFullBody(for hero: Hero) -> String {
        heroFullBodyNames[hero.id] ?? "child_with_lantern"
    }

    /// Heroes stand on the left and should face right; these paintings
    /// were drawn facing left, so the battlefield mirrors them.
    private static let mirroredHeroes: Set<UUID> = [
        CardCatalog.HeroIDs.archimedes,
        CardCatalog.HeroIDs.bedivere,
        CardCatalog.HeroIDs.galahad,
        CardCatalog.HeroIDs.merlin,
    ]

    /// Enemies stand on the right and should face left; these were drawn
    /// facing right.
    private static let mirroredEnemyArt: Set<String> = [
        "enchanted_hound_full",
        "forest_wolf_full",
        "giant_boar_full",
        "sir_ector_full",
        "shadow_villain_cloak",
    ]

    static func isHeroMirrored(_ hero: Hero) -> Bool {
        mirroredHeroes.contains(hero.id)
    }

    static func isEnemyMirrored(_ enemy: Enemy) -> Bool {
        mirroredEnemyArt.contains(enemy.fullBodyArtName)
    }

    static func heroPortrait(for hero: Hero) -> String {
        if let name = heroPortraitNames[hero.id] { return name }
        return PortraitRegistry.heroPortrait(for: hero.id)
    }

    static func heroIcon(for hero: Hero) -> String {
        heroIconNames[hero.id] ?? "person.fill"
    }

    // MARK: - Enemies

    /// Bosses have dedicated dialogue portraits; everyone else is shown
    /// with a crop of their battlefield painting.
    static func enemyPortrait(for enemy: Enemy) -> String {
        let bossPortrait = PortraitRegistry.enemyPortrait(for: enemy.id)
        if bossPortrait != "portrait_enemy_generic" { return bossPortrait }
        return enemy.fullBodyArtName
    }

    // MARK: - Chapters

    /// Painting behind the battlefield for each chapter (0-based index).
    static func arena(forChapterIndex index: Int) -> String {
        switch index {
        case 0: return "bg_moonlit_forest"
        case 1: return "arena_orkney_moor"
        case 2: return "bg_tournament_grounds"
        case 3: return "bg_camlann"
        case 4: return "arena_dream_void"
        default: return "enchanted_forest_night"
        }
    }

    /// Illustration shown on the campaign page for each chapter.
    static func chapterCover(forChapterIndex index: Int) -> String {
        switch index {
        case 0: return "bg_sword_in_stone"
        case 1: return "bg_morgause_throne"
        case 2: return "bg_grail_castle"
        case 3: return "bg_war_camp"
        case 4: return "bg_avalon_shore"
        default: return "enchanted_forest_night"
        }
    }
}
