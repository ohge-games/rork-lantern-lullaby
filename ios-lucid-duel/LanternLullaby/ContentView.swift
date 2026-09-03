//
//  ContentView.swift
//  LanternLullaby
//

import SwiftUI

/// App flow for Lantern & Lullaby:
/// title (bedroom) → prologue (first run) → campaign page → sleep
/// transition → battle → back to the campaign page with progress saved.
///
/// The sleep sequence runs on one clock here:
/// 1. Bedroom at rest (child in bed, book open, lantern on the nightstand)
/// 2. The flame flickers twice — the dream calling
/// 3. The camera slowly falls into the flame (2s)
/// 4. Black curtain (the loading breath between worlds)
/// 5. Fade in: the child standing in soft fog, lantern in hand
/// 6. The fog lifts (2s), revealing the arena behind them
/// 7. The battle UI settles in — the stage's story begins
struct ContentView: View {
    enum Screen: Equatable {
        case title
        case prologue
        case campaign
        case sleeping
        case battle
    }

    @State private var coordinator = CampaignCoordinator()
    @State private var battleViewModel: BattleViewModel?
    @State private var screen: Screen = .title
    @State private var sleepPhase: SleepPhase = .none
    /// Opacity of the black curtain between the bedroom and the dream.
    @State private var curtain: Double = 0
    /// The stage being fought, so victory can be written back.
    @State private var activeStage: Stage?
    /// Where that stage sits in the book, captured before the win is
    /// recorded so the victory card can name the heroes about to join.
    @State private var activeSummary: VictorySummary?

    var body: some View {
        ZStack {
            switch screen {
            case .title:
                StartScreenView(phase: .none, buttonTitle: "Open the Book") {
                    openBook()
                }
                .transition(.opacity)

            case .prologue:
                PrologueView(scenes: NarrativeCatalogBook1.prologueScenes) {
                    coordinator.markPrologueSeen()
                    withAnimation(.easeInOut(duration: 0.6)) { screen = .campaign }
                }
                .transition(.opacity)

            case .campaign:
                CampaignMapView(coordinator: coordinator) { stage in
                    beginStage(stage)
                }
                .transition(.opacity)

            case .sleeping:
                StartScreenView(phase: sleepPhase, showsChrome: false) {}
                    .transition(.opacity)

            case .battle:
                if let viewModel = battleViewModel {
                    BattleView(viewModel: viewModel, summary: activeSummary) { result in
                        finishBattle(result)
                    }
                    .transition(.opacity)
                }
            }

            if sleepPhase == .fogChild || sleepPhase == .fogLift {
                FogRevealView(lifting: sleepPhase == .fogLift)
                    .transition(.opacity)
            }

            // The loading breath between the bedroom and the dream.
            Color.black
                .ignoresSafeArea()
                .opacity(curtain)
                .allowsHitTesting(curtain > 0.1)
        }
        .animation(.easeInOut(duration: 0.5), value: screen)
    }

    // MARK: - Flow

    private func openBook() {
        if coordinator.hasSeenPrologue {
            screen = .campaign
        } else {
            screen = .prologue
        }
    }

    private func beginStage(_ stage: Stage) {
        guard screen == .campaign else { return }
        activeStage = stage
        activeSummary = coordinator.victorySummary(for: stage)
        battleViewModel = coordinator.makeBattle(for: stage)
        Task { await runSleepSequence() }
    }

    private func finishBattle(_ result: BattleExit) {
        if result == .victory, let stage = activeStage {
            coordinator.recordVictory(stageID: stage.id)
        }
        activeStage = nil
        activeSummary = nil
        withAnimation(.easeInOut(duration: 0.6)) {
            screen = .campaign
        }
        battleViewModel = nil
    }

    @MainActor
    private func runSleepSequence() async {
        // 1. Back to the bedroom; the child closes the book.
        sleepPhase = .none
        screen = .sleeping
        try? await Task.sleep(for: .milliseconds(700))

        // 2. The flame flickers twice (StartScreenView performs the gasps).
        sleepPhase = .flicker
        try? await Task.sleep(for: .milliseconds(1500))

        // 3. The camera slowly falls into the flame (2s ease-in-out,
        //    animated inside StartScreenView).
        sleepPhase = .zoom
        try? await Task.sleep(for: .milliseconds(1200))

        // 4. The flame's light swallows everything; fade to black while
        //    the zoom finishes underneath.
        withAnimation(.easeIn(duration: 0.9)) { curtain = 1 }
        try? await Task.sleep(for: .milliseconds(1100))

        // The loading moment: swap worlds behind the curtain.
        var noFade = Transaction()
        noFade.disablesAnimations = true
        withTransaction(noFade) {
            screen = .battle
            sleepPhase = .fogChild
        }
        try? await Task.sleep(for: .milliseconds(600))

        // 5. Fade in: the party standing in the fog.
        withAnimation(.easeOut(duration: 1.1)) { curtain = 0 }
        try? await Task.sleep(for: .milliseconds(1700))

        // 6. The fog gradually lifts (2s), revealing the arena.
        sleepPhase = .fogLift
        try? await Task.sleep(for: .milliseconds(2400))

        // 7. The last veil dissolves; the chapter begins.
        withAnimation(.easeOut(duration: 0.7)) { sleepPhase = .none }
        try? await Task.sleep(for: .milliseconds(400))
        battleViewModel?.startStage()
    }
}

#Preview {
    ContentView()
}
