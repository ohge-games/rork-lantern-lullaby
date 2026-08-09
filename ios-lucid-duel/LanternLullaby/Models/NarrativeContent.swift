import Foundation

// MARK: - Narrative Content Models

/// A single line of dialogue with speaker and optional portrait
struct DialogueLine: Identifiable, Codable {
    let id: UUID
    let speakerName: String
    let speakerPortrait: String  // Asset name for portrait image
    let text: String
    let isPlayerThought: Bool    // Italicized internal monologue vs spoken
    
    init(
        id: UUID = UUID(),
        speakerName: String,
        speakerPortrait: String,
        text: String,
        isPlayerThought: Bool = false
    ) {
        self.id = id
        self.speakerName = speakerName
        self.speakerPortrait = speakerPortrait
        self.text = text
        self.isPlayerThought = isPlayerThought
    }
    
    // Convenience for MC internal thoughts
    static func mcThought(_ text: String) -> DialogueLine {
        DialogueLine(
            speakerName: "",
            speakerPortrait: "portrait_mc",
            text: text,
            isPlayerThought: true
        )
    }
    
    // Convenience for hero dialogue
    static func hero(_ heroID: UUID, name: String, portrait: String, text: String) -> DialogueLine {
        DialogueLine(
            speakerName: name,
            speakerPortrait: portrait,
            text: text,
            isPlayerThought: false
        )
    }
    
    // Convenience for villain dialogue
    static func villain(name: String, portrait: String, text: String) -> DialogueLine {
        DialogueLine(
            speakerName: name,
            speakerPortrait: portrait,
            text: text,
            isPlayerThought: false
        )
    }
    
    // Convenience for narrator (no portrait)
    static func narrator(_ text: String) -> DialogueLine {
        DialogueLine(
            speakerName: "Narrator",
            speakerPortrait: "",
            text: text,
            isPlayerThought: false
        )
    }
}

/// A full story scene shown between battles (cutscene)
struct StoryScene: Identifiable, Codable {
    let id: UUID
    let backgroundImage: String?        // Optional scene background
    let backgroundMusic: String?        // Optional music track name
    let lines: [DialogueLine]
    let transitionStyle: TransitionStyle
    
    enum TransitionStyle: String, Codable {
        case fade           // Gentle fade in/out
        case pageTurn       // Book page turning effect
        case dreamRipple    // Wavy dream transition
        case instant        // Hard cut
    }
    
    init(
        id: UUID = UUID(),
        backgroundImage: String? = nil,
        backgroundMusic: String? = nil,
        lines: [DialogueLine],
        transitionStyle: TransitionStyle = .fade
    ) {
        self.id = id
        self.backgroundImage = backgroundImage
        self.backgroundMusic = backgroundMusic
        self.lines = lines
        self.transitionStyle = transitionStyle
    }
}

/// Triggers for when dialogue appears in battle
enum DialogueTrigger: Codable, Equatable {
    case battleStart                        // Before first turn
    case battleEnd                          // After victory
    case waveStart(waveIndex: Int)          // Before a specific wave
    case waveEnd(waveIndex: Int)            // After a specific wave
    case enemyHealthThreshold(percent: Int) // Boss at 50%, 25%, etc.
    case turnNumber(turn: Int)              // On specific turn
    case heroUnlock(heroID: UUID)           // When a hero joins
    case firstTimeOnly(key: String)         // One-time tutorial/story beat
}

/// In-battle dialogue sequence
struct BattleDialogue: Identifiable, Codable {
    let id: UUID
    let trigger: DialogueTrigger
    let lines: [DialogueLine]
    let pausesBattle: Bool      // If true, battle pauses until dialogue dismissed
    
    init(
        id: UUID = UUID(),
        trigger: DialogueTrigger,
        lines: [DialogueLine],
        pausesBattle: Bool = true
    ) {
        self.id = id
        self.trigger = trigger
        self.lines = lines
        self.pausesBattle = pausesBattle
    }
}

/// Container for all narrative content in a stage
struct StageNarrative: Codable {
    let preStageScene: StoryScene?          // Cutscene before battle starts
    let postStageScene: StoryScene?         // Cutscene after victory
    let battleDialogues: [BattleDialogue]   // In-battle dialogue triggers
    
    init(
        preStageScene: StoryScene? = nil,
        postStageScene: StoryScene? = nil,
        battleDialogues: [BattleDialogue] = []
    ) {
        self.preStageScene = preStageScene
        self.postStageScene = postStageScene
        self.battleDialogues = battleDialogues
    }
    
    static let empty = StageNarrative()
}

// MARK: - Portrait Registry

/// Maps hero/enemy IDs to portrait asset names
enum PortraitRegistry {
    
    static func heroPortrait(for heroID: UUID) -> String {
        // Map known hero IDs to portrait assets
        switch heroID {
        case CardCatalogHeroes.HeroIDs.wart:
            return "portrait_wart"
        case CardCatalogHeroes.HeroIDs.archimedes:
            return "portrait_archimedes"
        case CardCatalogHeroes.HeroIDs.lancelot:
            return "portrait_lancelot"
        case CardCatalogHeroes.HeroIDs.kay:
            return "portrait_kay"
        case CardCatalogHeroes.HeroIDs.bedivere:
            return "portrait_bedivere"
        case CardCatalogHeroes.HeroIDs.morgana:
            return "portrait_morgana"
        case CardCatalogHeroes.HeroIDs.escanor:
            return "portrait_escanor"
        case CardCatalogHeroes.HeroIDs.galahad:
            return "portrait_galahad"
        case CardCatalogHeroes.HeroIDs.merlin:
            return "portrait_merlin"
        default:
            return "portrait_unknown"
        }
    }
    
    static func enemyPortrait(for enemyID: UUID) -> String {
        // Map known enemy IDs to portrait assets
        // Using enemy catalog IDs
        switch enemyID {
        case EnemyCatalogBook1.sirEctor.id:
            return "portrait_ector"
        case EnemyCatalogBook1.queenMorgause.id:
            return "portrait_morgause"
        case EnemyCatalogBook1.sirMeliagrance.id:
            return "portrait_meliagrance"
        case EnemyCatalogBook1.mordred.id:
            return "portrait_mordred"
        case EnemyCatalogBook1.theAwakening.id:
            return "portrait_awakening"
        default:
            return "portrait_enemy_generic"
        }
    }
    
    static let mcPortrait = "portrait_mc"
    static let shopkeeperPortrait = "portrait_shopkeeper"
    static let narratorPortrait = ""  // No portrait for narrator
}
