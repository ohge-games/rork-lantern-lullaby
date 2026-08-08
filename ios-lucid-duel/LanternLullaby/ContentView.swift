//
//  ContentView.swift
//  LanternLullaby
//

import SwiftUI

/// App flow for Lantern & Lullaby: bedroom → sleep transition → battle.
///
/// The sleep sequence runs on one clock here:
/// 1. Bedroom at rest (child in bed, book open, lantern on the nightstand)
/// 2. The flame flickers twice — the dream calling
/// 3. The camera slowly falls into the flame (2s)
/// 4. Black curtain (the loading breath between worlds)
/// 5. Fade in: the child standing in soft fog, lantern in hand
/// 6. The fog lifts (2s), revealing the arena behind them
/// 7. The battle UI settles in — the chapter begins
struct ContentView: View {
    @State private var viewModel = BattleViewModel()
    @State private var isInBattle = false
    @State private var sleepPhase: SleepPhase = .none
    /// Opacity of the black curtain between the bedroom and the dream.
    @State private var curtain: Double = 0

    var body: some View {
        ZStack {
            if isInBattle {
                BattleView(viewModel: viewModel) {
                    isInBattle = false
                }
            } else {
                StartScreenView(phase: sleepPhase) {
                    beginSleepSequence()
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
        .animation(.easeInOut(duration: 0.5), value: isInBattle)
    }

    private func beginSleepSequence() {
        guard sleepPhase == .none, !isInBattle else { return }
        Task { await runSleepSequence() }
    }

    @MainActor
    private func runSleepSequence() async {
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
        if viewModel.state.phase == .gameOver {
            viewModel.startNewDuel()
        }
        var noFade = Transaction()
        noFade.disablesAnimations = true
        withTransaction(noFade) {
            isInBattle = true
            sleepPhase = .fogChild
        }
        try? await Task.sleep(for: .milliseconds(600))

        // 5. Fade in: the child standing in the fog, lantern in hand.
        withAnimation(.easeOut(duration: 1.1)) { curtain = 0 }
        try? await Task.sleep(for: .milliseconds(1700))

        // 6. The fog gradually lifts (2s), revealing the arena.
        sleepPhase = .fogLift
        try? await Task.sleep(for: .milliseconds(2400))

        // 7. The last veil dissolves; the chapter begins.
        withAnimation(.easeOut(duration: 0.7)) { sleepPhase = .none }
    }
}

#Preview {
    ContentView()
}
