import Foundation

/// Whose turn it is and what they may do.
nonisolated enum TurnPhase: String, Codable, Sendable {
    case playerDraw
    case playerMain
    case enemyTurn
    case gameOver
}

/// Terminal result of a battle, including *why* it ended.
nonisolated enum GameOutcome: Codable, Hashable, Sendable {
    case ongoing
    /// Enemy hero health reached 0.
    case victory
    /// Player lucidity entered a lose-condition zone.
    case lostToLucidity(zone: LucidityZone)
    /// Player hero health reached 0.
    case defeated
}

/// The complete, serializable snapshot of a battle in progress.
///
/// Everything derivable (zones, lose checks) is computed, not stored, so a
/// saved game can never contain contradictory values.
nonisolated struct GameState: Codable, Sendable {
    var turnNumber: Int
    var phase: TurnPhase
    var player: CombatantState
    var enemy: CombatantState
    var outcome: GameOutcome

    /// Evaluates all end conditions in priority order. Lucidity lose
    /// conditions are checked before victory so overextending on the
    /// killing blow still costs the game.
    var resolvedOutcome: GameOutcome {
        if player.hasLostByLucidity {
            return .lostToLucidity(zone: player.zone)
        }
        if player.isDefeated {
            return .defeated
        }
        if enemy.isDefeated {
            return .victory
        }
        return .ongoing
    }

    /// Fresh battle with both sides at the Balanced center of the meter.
    static func newGame(
        playerHero: Hero,
        enemyHero: Hero,
        playerDeck: [CardInstance],
        enemyDeck: [CardInstance]
    ) -> GameState {
        GameState(
            turnNumber: 1,
            phase: .playerDraw,
            player: CombatantState(
                heroID: playerHero.id,
                currentHealth: playerHero.maxHealth,
                shield: 0,
                lucidity: GameRules.startingLucidity,
                hand: [],
                deck: playerDeck,
                discardPile: []
            ),
            enemy: CombatantState(
                heroID: enemyHero.id,
                currentHealth: enemyHero.maxHealth,
                shield: 0,
                lucidity: GameRules.startingLucidity,
                hand: [],
                deck: enemyDeck,
                discardPile: []
            ),
            outcome: .ongoing
        )
    }
}
