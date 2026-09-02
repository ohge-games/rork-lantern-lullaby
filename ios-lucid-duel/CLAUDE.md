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

- **`ViewModels/BattleViewModel.swift`** — the entire battle engine and the only place that mutates state. It is `@Observable` and owns `state: GameState`. All rule enforcement (card play order, cost application, zone bonuses, turn flow, enemy AI) lives here. If you're changing *how the game behaves*, it's almost always this file. Async turn pacing (enemy "thinking" beats, auto-clearing banners/pulses/sound cues) is done with detached `Task { … Task.sleep … }` blocks that guard on identity before clearing, so overlapping events don't stomp each other.

- **`Views/`** — SwiftUI, read-only against the view model; they call intent methods and never mutate `GameState` directly. `ContentView` runs the bedroom→sleep→battle intro sequence on a single hand-tuned clock. `BattleView` composes the duel screen; `BattlefieldView`, `HandView`, `CardView`, `LanternView`, and the various `*OverlayView`s are the pieces.

### Key mechanics to preserve when editing the engine

- **Lucidity is the core loop.** `setPlayerLucidity` is the single write path — it clamps, fires the sharpen/soften pulse, and announces zone transitions. Route all meter changes through it. `projectedLucidity(after:)` must mirror the exact application order of `playSelectedCard` (cost first, then base effects, then chosen branch) or previews will lie.
- **Zone bonuses lock in at moment of play** (`zoneAtPlay`), captured *before* the cost moves the meter — the badge's promise is what resolves. Vivid gives offensive +20%, Drifting gives defensive +20%; `lucidityModify`/`lucidityCenter`/`drawCards` are never scaled (see `Effect.resolvedValue`).
- **Lose-by-lucidity is checked before victory** (`resolvedOutcome` priority) — overextending on the killing blow still loses the game.
- **Team roster is a layout mockup, partially live.** Slot one (The Dreamer) mirrors real engine state; the support allies/enemies keep *local* placeholder health and use fixed hardcoded UUIDs. Only the primary enemy/Dreamer decide the duel; the duel is lost only when the Dreamer falls. Hero switching is a free action (no turn, no Lucidity). Treat the extra combatants as not-yet-wired-up.
- **Audio is a placeholder.** `emitSound(_:)` flashes a "♪" chip naming the sound that *would* play; there is no real audio yet.

## Assets

Art lives in `LanternLullaby/Assets.xcassets/` as named imagesets. Model/view-model code references them by string name (e.g. `artName: "dreamer_child_portrait"`); when adding a combatant or card, the asset name string must match the imageset folder name exactly.
