# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Lantern & Lullaby** — a native iOS single-player card-battler built in SwiftUI. A child (The Dreamer) duels a Nightmare across a landscape "storybook spread." The signature mechanic is **Lucidity**: an inverted resource where playing cards *raises* a 0–100 meter instead of spending points, and both extremes (Deep Sleep at 0, Awakening at 100) are instant-loss conditions.

This is an Xcode project (not SPM, not a JS/Expo app despite the repo name). Building and testing require **macOS with Xcode** — the tooling does not run on Windows even though the repo may be edited there.

## Commands

Build:
```
xcodebuild -project LanternLullaby.xcodeproj -scheme LanternLullaby -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Run all tests (Swift Testing framework, not XCTest, for unit tests):
```
xcodebuild -project LanternLullaby.xcodeproj -scheme LanternLullaby -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Run a single test / suite (Swift Testing supports filtering by name):
```
xcodebuild test -project LanternLullaby.xcodeproj -scheme LanternLullaby -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:LanternLullabyTests/LucidityZoneTests/zoneBoundariesMatchSpec
```

Day-to-day, opening `LanternLullaby.xcodeproj` in Xcode and using ⌘R / ⌘U is the normal workflow.

Toolchain: Swift 5 language mode, iOS 18.0 deployment target, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (everything is main-actor-isolated by default; types that must cross actor boundaries are explicitly marked `nonisolated` + `Sendable`).

## Architecture

MVVM with a strict separation between a pure, serializable rules layer and an observable engine that drives the UI.

- **`Models/`** — value types only, all `nonisolated`/`Codable`/`Sendable`. `GameState` is a complete serializable snapshot; anything derivable (zones, win/lose checks via `resolvedOutcome`) is **computed, not stored**, so a saved game can never hold contradictory values. `GameRules` is the single tuning file (all balance constants live here). `CardCatalog` holds all static content with **fixed UUIDs** (not random per launch) so references stay stable across sessions. `Effect` is the atomic unit — cards carry an *array* of effects so hybrid cards ("deal 4, then reduce Lucidity 3") are one card, not a special case.

- **`ViewModels/CampaignCoordinator.swift`** — campaign progress (persisted to `UserDefaults` as JSON), chapter/stage unlocking, the party roster, and the stage→battle seam: it builds a `BattleConfiguration` (party, waves, arena, deck) plus the merged `StageNarrative` and hands back a configured `BattleViewModel`. Victory is written back through `recordVictory`.

- **`ViewModels/EnemyBrain.swift`** — interprets an enemy's `AttackPattern` one turn at a time (skirmish / scripted / phased, with enrage and wind-up buffs). Plans on the player's turn so the intent chip matches what lands.

- **`ViewModels/BattleViewModel.swift`** — the entire battle engine and the only place that mutates state. It is `@Observable` and owns `state: GameState`. All rule enforcement (card play order, cost application, zone bonuses, turn flow, enemy AI) lives here. If you're changing *how the game behaves*, it's almost always this file. Async turn pacing (enemy "thinking" beats, auto-clearing banners/pulses/sound cues) is done with detached `Task { … Task.sleep … }` blocks that guard on identity before clearing, so overlapping events don't stomp each other.

- **`Views/`** — SwiftUI, read-only against the view model; they call intent methods and never mutate `GameState` directly. `ContentView` runs the bedroom→sleep→battle intro sequence on a single hand-tuned clock. `BattleView` composes the duel screen; `BattlefieldView`, `HandView`, `CardView`, `LanternView`, and the various `*OverlayView`s are the pieces.

### Key mechanics to preserve when editing the engine

- **Lucidity is the core loop.** `setPlayerLucidity` is the single write path — it clamps, fires the sharpen/soften pulse, and announces zone transitions. Route all meter changes through it. `projectedLucidity(after:)` must mirror the exact application order of `playSelectedCard` (cost first, then base effects, then chosen branch) or previews will lie.
- **Zone bonuses lock in at moment of play** (`zoneAtPlay`), captured *before* the cost moves the meter — the badge's promise is what resolves. Vivid gives offensive +20% and is the only zone that scales anything; `lucidityModify`/`lucidityCenter`/`drawCards` are never scaled (see `Effect.resolvedValue`).
- **Lose-by-lucidity is checked before victory** (`resolvedOutcome` priority) — overextending on the killing blow still loses the game.
- **The two ends of the meter do different jobs.** Vivid is power: `LucidityZone.offensiveMultiplier` is the only scaling in the game. Drifting is tempo: `GameRules.driftingCostReduction` and `driftingBonusDraw` make cards cheaper and hands deeper, and `EnemyBrain.previewNextIntent` reveals each enemy's move-after-next. Nothing scales defensive cards any more — if you are tempted to add a defensive multiplier back, the zones lose their separate identities.
- **Hero abilities** live in `Models/HeroAbility.swift`, keyed by hero id the way `ArtCatalog` keys paintings, so the hero catalogs stay pure data. Charge accrues in `resonance` when a card whose `heroID` matches a party member is played, from the bench as well as the front. `fireAbility` resolves the effects through `abilityCarrier` (a zero-cost offensive stand-in) so Vivid still applies, and costs no Lucidity by design — it is the answer to a turn that is otherwise unplayable.
- **Letting a card go**: dropping any card on the lantern calls `releaseSelectedCard`, which **burns** it (into `burnedCards`, never the discard pile) and lowers Lucidity by `safeReleaseRelief` — at most `GameRules.releaseRelief`, and never far enough to enter Deep Sleep. It resolves no effects and accrues no strain. It is the guaranteed out when a hand holds no Relax card, and it costs the card permanently, which is what keeps the meter a resource rather than free arithmetic. `isOverLantern` gives a figure under the finger priority over the lantern's slop zone.
- **The enemy fights over the meter too.** `EnemyMove.lucidityPush(Int)` moves the player's lantern (positive brightens toward Awakening, negative dims toward Deep Sleep) and shows on the intent chip as `EnemyIntent.push`. Shadow Wisps whisper it down; Morgause pushes it both ways across her phases. This is what makes both ends of the meter contested — before it existed, Deep Sleep was unreachable and Awakening was arithmetic.
- **Answering an intent.** `Models/CardCatalog+Answers.swift` adds four cards and `EffectType` gains `.stun`, `.weaken`, `.shieldBreak`, `.calm`. Hush queues a skip (`EnemyCombatant.stunTurns`; the plan stays, so the threat is delayed, not erased), Wooden Feint sets `weaken` on the next attack, Cut the Straps zeroes the shield before its damage, Snuffed Wick calls `EnemyBrain.calm()` to blow out a wind-up and enrage. Any card carrying one of these is aimed at an enemy — use `cardTargetsEnemy(_:)`, not `cardDealsDamage(_:)`, whenever the question is "where does this drop?".
- **Enemies are desynced by slot.** `EnemyBrain(pattern:turn:healthFraction:slot:)` seeds `actionsTaken` with the slot and offsets skirmish heavies by it, so two copies of the same enemy never brace or spike in lockstep. Every figure has its own intent, which is what makes picking a target a decision.
- **Guests bring cards.** A `WaveSpec.allyReinforcement` hero joins with `welcomeGuestCards`: two of their cheapest cards into hand, the rest shuffled in, and their ability charged to `chargeRequired − 2`. The field seats `BattleViewModel.maxFieldedHeroes` (4); a fifth guest is refused rather than standing unrendered.
- **One enemy turn at a time.** `endTurn` cancels the outstanding `enemyTurnTask` and bumps `turnGeneration`; every sleep inside `resolveEnemyTurn(generation:)` re-checks `isCurrentEnemyTurn`. It iterates enemies by **id**, re-looking-up the index, because a restart can replace the line mid-turn. `instantEnemyTurns` runs the same steps with no pacing — that is how `BalanceSimulationTests` plays thousands of battles headlessly.
- **The three piles are readable.** `BattleViewModel.CardPile` (`deck`/`discard`/`burned`) plus `count(of:)` and `contents(of:)` back the tappable chips in `BattleView.pileCounters` and the `CardPileView` sheet. The deck comes back **sorted by cost, never in draw order** — printing the order would hand the player the future — while the discard and the burned pile keep their order, newest first.
- **The lantern is the meter's whole interface.** `LanternView` draws a five-band zone ladder beside the glass with a gold mark at the current value and a ghost mark at `projected` (the meter after the selected card, from `projectedLucidity(after:)`), and the base plate prints `→ N` in danger red when that lands in a lose zone. `isReleaseTarget` makes the lantern itself glow as a drop target instead of a dashed rectangle drawn over it.
- **Press and hold a figure for the full record.** `BattlefieldCharacterView.onInspect` (a `simultaneousGesture` long press, so it never steals the tap that targets or the drag that aims) opens `CombatantInspectorView`: passive, ability and charge for heroes; both telegraphed intents and the tier for enemies. Tap still does the quick thing.
- **Aim snaps.** `enemyID(at:)` and `allyID(at:)` both go through `target(at:among:frames:)`: containment first, then the nearest frame *edge* within `snapRadius`. Do not go back to requiring containment — overlapping figures made survivors untargetable twice.
- **Focus Strain** (`GameRules.focusStrainPerRepeat`) adds cost per repeat of a card *type* within a turn, tracked in `cardsPlayedThisTurn` and cleared in `beginPlayerTurn`. It is the soft ceiling on burst; `effectiveCost` folds it in, so previews and card faces pick it up for free.
- **Cards are aimed with a thread, not dragged.** `HandView` lifts the held card in place and calls `updateCardDrag(anchor:point:)`; `TargetingThreadView` draws the line in global coordinates above the battle. Attacks drop on enemies, everything else drops on a hero (`allyID(at:)` via reported ally frames); dual-direction cards drop on either and open the branch picker with `pendingAllyTarget` remembered. `.swapLead` (Step Forward) is the only effect that reads the dropped-on hero.
- **Party order is set before battle.** Heroes stand on the LEFT, enemies on the RIGHT; the lead stands front-center on the lowest ground line (`BattlefieldView.planted`). Tapping a hero only shows their passive. `switchActiveHero` still exists but is reached through Step Forward (and the fall-through when the lead drops), not by tapping.
- **Tutorial.** `BattleConfiguration.tutorial` carries a `TutorialScript`; the coordinator attaches `.firstBattle` to chapter 1 page 1. Tap steps block play (`isTutorialBlocking`), action steps advance on `tutorialEvent`. Rendered by `TutorialCalloutView`.
- **The party fights as a unit.** One shared hand, deck, shield and Lucidity meter; each hero keeps their own health in `party` (`PartyMember`). The lead hero takes the hits and is the only hero whose passive applies; switching leads is free. When the lead falls the next living hero steps forward; the battle is lost when nobody is standing. `GameState.player` mirrors the lead, `GameState.enemy` mirrors the primary enemy — keep `syncLeadMirror`/`syncPrimaryMirror` calls after every health write.
- **Enemies arrive in waves.** `enemyLine` holds the current wave; every living enemy acts on the enemy turn. When the last enemy of a wave falls and more waves remain, `beginNextWave` spawns the next one mid player-turn. The original Dreamer-vs-Nightmare sandbox lives on as `BattleConfiguration.legacyDuel` (the default `BattleViewModel()` init), which is what the unit tests exercise.
- **Narrative gating.** `configureNarrative` stores the stage's scenes/dialogues; `startStage()` (called by `ContentView` once the fog lifts) opens the pre-scene or fires the battle-start dialogue. The game-over card waits until `narrativePhase == .none`.
- **Balance is measured, not guessed.** `LanternLullabyTests/BalanceSimulationTests.swift` auto-plays every Chapter 1–2 page 30 times under two policies (`sensible`, `naive`) and prints one `SIM|` line per stage. Run it after any tuning change: the shape to keep is early pages ~100% for a sensible player, mid pages 85–100%, the Questing Beast and the chapter bosses below that, and a naive player losing to the lantern at the Chapter 2 boss.
- **Audio is a placeholder.** `emitSound(_:)` flashes a "♪" chip naming the sound that *would* play; there is no real audio yet.

## Assets

Art lives in `LanternLullaby/Assets.xcassets/` as named imagesets. `Models/ArtCatalog.swift` maps heroes, enemies and chapters to imageset names (`hero_<name>_full`, `portrait_<name>`, `<enemy>_full`, `bg_*` / `arena_*`); when adding a combatant, add its mapping there and make sure the string matches the imageset folder name exactly. The generated art was made with Magnific (Freepik project "Lantern") in a storybook watercolor-gouache style: heroes face left, enemies face right, cutouts on transparent PNG.
