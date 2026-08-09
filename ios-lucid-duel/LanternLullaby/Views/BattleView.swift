import SwiftUI

/// The main duel screen of Lantern & Lullaby, staged in landscape like a
/// storybook spread: enemies stand on the left page, heroes on the right,
/// the card hand fans at the bottom center, and the living lantern keeps
/// watch in the bottom-right corner.
struct BattleView: View {
    let viewModel: BattleViewModel
    let onExit: () -> Void

    var body: some View {
        ZStack {
            DreamBackground(zone: viewModel.state.player.zone)

            BattlefieldView(viewModel: viewModel)
                .padding(.bottom, 60)

            topChrome

            bottomChrome

            // Standard cards play straight from the drag-and-drop; only
            // dual-direction cards open the branch picker after the drop.
            if let card = viewModel.selectedCard, card.choices != nil, !viewModel.isDraggingCard {
                confirmPanel(for: card)
            }

            if viewModel.state.phase == .gameOver {
                GameOverOverlayView(
                    outcome: viewModel.state.outcome,
                    finalLucidity: viewModel.state.player.lucidity,
                    onRestart: { viewModel.startNewDuel() },
                    onContinue: onExit
                )
                .transition(.opacity)
            }
            
            // MARK: - Narrative Overlays
            
            // Pre-battle story scene
            if let preScene = viewModel.preStageScene,
               viewModel.narrativePhase == .showingPreScene {
                StorySceneView(
                    scene: preScene,
                    onComplete: { viewModel.dismissPreScene() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
            
            // In-battle dialogue overlay (appears in card zone area)
            if let dialogue = viewModel.activeDialogue,
               viewModel.narrativePhase == .showingDialogue {
                DialogueOverlayView(
                    dialogue: dialogue,
                    onDismiss: { viewModel.dismissDialogue() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(99)
            }
            
            // Post-battle story scene
            if let postScene = viewModel.postStageScene,
               viewModel.narrativePhase == .showingPostScene {
                StorySceneView(
                    scene: postScene,
                    onComplete: { viewModel.dismissPostScene() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.playImpactTrigger)
        .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.enemyActionTrigger)
        .sensoryFeedback(.selection, trigger: viewModel.selectedInstanceID)
        .sensoryFeedback(.selection, trigger: viewModel.targetedEnemyID)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.heroSwitchTrigger)
        .animation(.easeInOut(duration: 0.3), value: viewModel.state.phase)
    }

    // MARK: - Top chrome

    /// Sound chip (left) · turn banner + zone notification (center) ·
    /// restart (right).
    private var topChrome: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top) {
                soundChip
                    .frame(width: 110, alignment: .leading)

                Spacer()

                turnBanner

                Spacer()

                restartButton
                    .frame(width: 110, alignment: .trailing)
            }

            if let notification = viewModel.zoneNotification {
                ZoneNotificationView(notification: notification)
                    .transition(
                        .move(edge: .top)
                            .combined(with: .opacity)
                            .combined(with: .scale(scale: 0.92))
                    )
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .animation(.easeInOut(duration: 0.25), value: viewModel.soundCue?.id)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.zoneNotification?.id
        )
    }

    private var turnBanner: some View {
        Text(bannerText)
            .font(.caption.weight(.semibold))
            .tracking(2)
            .foregroundStyle(.white.opacity(0.75))
            .contentTransition(.opacity)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(.black.opacity(0.35)))
            .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private var bannerText: String {
        switch viewModel.state.phase {
        case .playerDraw, .playerMain:
            return "TURN \(viewModel.state.turnNumber) · YOUR MOVE"
        case .enemyTurn:
            return viewModel.isEnemyThinking ? "ENEMY THINKING…" : "THE NIGHTMARE STRIKES"
        case .gameOver:
            return "DUEL OVER"
        }
    }

    /// Placeholder for audio: flashes "♪ <cue>" wherever a sound would play.
    @ViewBuilder
    private var soundChip: some View {
        if let cue = viewModel.soundCue {
            HStack(spacing: 3) {
                Text("♪")
                    .font(.system(size: 11, weight: .bold))
                Text(cue.label)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(DreamTheme.gold.opacity(0.85))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(.black.opacity(0.35)))
            .transition(.opacity.combined(with: .scale(scale: 0.85)))
        }
    }

    private var restartButton: some View {
        Button {
            viewModel.startNewDuel()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 32, height: 32)
                .background(Circle().fill(.black.opacity(0.3)))
                .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Restart duel")
    }

    // MARK: - Bottom chrome

    /// Deck counts (left) · card fan (center) · lantern + End Turn (right).
    private var bottomChrome: some View {
        ZStack(alignment: .bottom) {
            HandView(viewModel: viewModel)
                .frame(maxWidth: 470)
                .opacity(viewModel.state.phase == .playerMain ? 1 : 0.55)

            HStack(alignment: .bottom) {
                pileCounters

                Spacer()

                lanternCorner
            }
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 6)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedInstanceID)
    }

    private var pileCounters: some View {
        VStack(alignment: .leading, spacing: 6) {
            pileChip(count: viewModel.state.player.deck.count, icon: "square.stack.fill", label: "Deck")
            pileChip(count: viewModel.state.player.discardPile.count, icon: "tray.full.fill", label: "Discard")

            Text("Tap a teammate\nto switch heroes")
                .font(.system(size: 8))
                .foregroundStyle(.white.opacity(0.4))
                .lineLimit(2)
        }
    }

    private func pileChip(count: Int, icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .monospacedDigit()
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.45))
        }
        .foregroundStyle(.white.opacity(0.75))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(.black.opacity(0.35)))
        .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
    }

    /// The living lantern, compact in the corner, with End Turn beneath it.
    private var lanternCorner: some View {
        VStack(spacing: 2) {
            LanternView(
                lucidity: viewModel.state.player.lucidity,
                zone: viewModel.state.player.zone,
                pulse: viewModel.lucidityPulse
            )
            .scaleEffect(0.68, anchor: .bottom)
            .frame(width: 96, height: 158, alignment: .bottom)

            endTurnButton
        }
    }

    private var endTurnButton: some View {
        Button {
            viewModel.endTurn()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 11))
                Text("End Turn")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.4)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(viewModel.state.phase != .playerMain)
        .opacity(viewModel.state.phase == .playerMain ? 1 : 0.4)
    }

    // MARK: - Card confirmation

    /// The play-confirmation panel floats above the fan, centered, so the
    /// battlefield stays visible while aiming.
    private func confirmPanel(for card: Card) -> some View {
        VStack {
            Spacer()
            PlayCardPanelView(viewModel: viewModel, card: card)
                .frame(maxWidth: 520)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.07, green: 0.06, blue: 0.17).opacity(0.88))
                )
                .padding(.bottom, 170)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedInstanceID)
    }
}

#Preview(traits: .landscapeLeft) {
    BattleView(viewModel: BattleViewModel(), onExit: {})
}
