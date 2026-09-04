import SwiftUI

/// How a battle screen was left: a recorded victory, or the player closing
/// the book on a fight (lost or abandoned).
enum BattleExit: Equatable {
    case victory
    case retreat
}

/// The main duel screen of Lantern & Lullaby, staged in landscape like a
/// storybook spread: enemies stand on the left page, heroes on the right,
/// the card hand fans at the bottom center, and the living lantern keeps
/// watch in the bottom-right corner.
struct BattleView: View {
    let viewModel: BattleViewModel
    /// Where this stage sits in the book, for the victory card.
    var summary: VictorySummary? = nil
    let onExit: (BattleExit) -> Void

    @State private var confirmLeave = false

    var body: some View {
        ZStack {
            DreamBackground(zone: viewModel.state.player.zone, artName: viewModel.arenaArtName)
                .dynamicTypeSize(...DynamicTypeSize.large)

            BattlefieldView(viewModel: viewModel)

            topChrome

            bottomChrome

            // The targeting thread from the held card to the finger.
            if let from = viewModel.dragAnchor, let to = viewModel.dragPoint, viewModel.isDraggingCard {
                TargetingThreadView(from: from, to: to, isOnTarget: viewModel.hasDropTarget)
                    .zIndex(60)
            }

            // The first battle's lesson, pinned to whatever it explains.
            if let step = viewModel.activeTutorialStep,
               viewModel.narrativePhase == .none,
               viewModel.state.phase != .gameOver,
               !viewModel.isDraggingCard {
                TutorialCalloutView(step: step) {
                    viewModel.advanceTutorial()
                }
                .transition(.opacity)
                .zIndex(70)
            }

            // Standard cards play straight from the drag-and-drop; only
            // dual-direction cards open the branch picker after the drop.
            if let card = viewModel.selectedCard, card.choices != nil, !viewModel.isDraggingCard {
                confirmPanel(for: card)
            }

            // The ending card waits until the stage's last lines are read.
            if viewModel.state.phase == .gameOver, viewModel.narrativePhase == .none {
                GameOverOverlayView(
                    outcome: viewModel.state.outcome,
                    summary: summary,
                    victorySubtitle: "\(viewModel.configuration.title) — the page turns.",
                    onRestart: { viewModel.startNewDuel() },
                    onContinue: {
                        onExit(viewModel.state.outcome == .victory ? .victory : .retreat)
                    }
                )
                .transition(.opacity)
                .zIndex(80)
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
                    onDismiss: { viewModel.dismissDialogue(dialogue.id) }
                )
                .id(dialogue.id)
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
        .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.waveTrigger)
        .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.abilityTrigger)
        .animation(.easeInOut(duration: 0.3), value: viewModel.state.phase)
        .animation(.easeInOut(duration: 0.3), value: viewModel.narrativePhase)
        .animation(.easeInOut(duration: 0.25), value: viewModel.tutorialIndex)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isDraggingCard)
        .confirmationDialog("Close the book?", isPresented: $confirmLeave, titleVisibility: .visible) {
            Button("Leave the dream", role: .destructive) { onExit(.retreat) }
            Button("Keep dreaming", role: .cancel) {}
        } message: {
            Text("Progress on this page will be lost.")
        }
    }

    // MARK: - Top chrome

    /// Leave + sound chip (left) · turn banner + wave chip (center) ·
    /// restart (right), with zone and battle notices beneath.
    private var topChrome: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        leaveButton
                        soundChip
                    }
                    pileCounters
                }
                .frame(width: 170, alignment: .leading)

                Spacer()

                VStack(spacing: 4) {
                    turnBanner
                    if viewModel.waveCount > 1 {
                        waveChip
                    }
                }

                Spacer()

                restartButton
                    .frame(width: 150, alignment: .trailing)
            }

            if let notification = viewModel.zoneNotification {
                ZoneNotificationView(notification: notification)
                    .transition(
                        .move(edge: .top)
                            .combined(with: .opacity)
                            .combined(with: .scale(scale: 0.92))
                    )
            }

            if let notice = viewModel.battleNotice {
                Text(notice.text)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(DreamTheme.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.black.opacity(0.5)))
                    .overlay(Capsule().stroke(DreamTheme.gold.opacity(0.35), lineWidth: 1))
                    .transition(.move(edge: .top).combined(with: .opacity))
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
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.battleNotice?.id
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

    private var waveChip: some View {
        Text("WAVE \(viewModel.waveIndex + 1) OF \(viewModel.waveCount)")
            .font(.system(size: 9, weight: .heavy))
            .tracking(1.5)
            .foregroundStyle(DreamTheme.gold.opacity(0.9))
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(Capsule().fill(.black.opacity(0.35)))
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: viewModel.waveIndex)
    }

    private var bannerText: String {
        switch viewModel.state.phase {
        case .playerDraw, .playerMain:
            return "TURN \(viewModel.state.turnNumber) · YOUR MOVE"
        case .enemyTurn:
            if viewModel.isEnemyThinking { return "ENEMY THINKING…" }
            let name = viewModel.primaryEnemy?.name ?? "THE NIGHTMARE"
            return "\(name.uppercased()) STRIKES"
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

    private var leaveButton: some View {
        Button {
            confirmLeave = true
        } label: {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 32, height: 32)
                .background(Circle().fill(.black.opacity(0.3)))
                .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Close the book")
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
        // Restarting mid-beat would strand the enemy turn or a story line.
        .disabled(viewModel.state.phase == .enemyTurn || viewModel.narrativePhase != .none)
        .opacity(viewModel.state.phase == .enemyTurn || viewModel.narrativePhase != .none ? 0.4 : 1)
        .accessibilityLabel("Restart duel")
    }

    // MARK: - Bottom chrome

    /// Deck counts (left) · card fan (center) · lantern + End Turn (right).
    private var bottomChrome: some View {
        ZStack(alignment: .bottom) {
            HandView(viewModel: viewModel)
                .frame(maxWidth: 420)
                .opacity(viewModel.state.phase == .playerMain ? 1 : 0.55)

            HStack(alignment: .bottom) {
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
        HStack(spacing: 6) {
            pileChip(count: viewModel.state.player.deck.count, icon: "square.stack.fill", label: "Deck")
            pileChip(count: viewModel.state.player.discardPile.count, icon: "tray.full.fill", label: "Discard")
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
            // Dropping a card here lets it go and calms the flame.
            .overlay {
                if viewModel.isDraggingCard {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            viewModel.isReleaseTargeted ? DreamTheme.gold : .white.opacity(0.35),
                            style: StrokeStyle(lineWidth: viewModel.isReleaseTargeted ? 2.5 : 1.5, dash: [6, 5])
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(DreamTheme.gold.opacity(viewModel.isReleaseTargeted ? 0.18 : 0))
                        )
                        .overlay(alignment: .top) {
                            Text(viewModel.isReleaseTargeted ? "LET IT GO" : "RELEASE")
                                .font(.system(size: 8, weight: .heavy))
                                .tracking(1)
                                .foregroundStyle(viewModel.isReleaseTargeted ? DreamTheme.gold : .white.opacity(0.5))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.black.opacity(0.5)))
                                .offset(y: -10)
                        }
                        .transition(.opacity)
                }
            }
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { frame in
                viewModel.reportLanternFrame(frame)
            }

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
        .disabled(viewModel.state.phase != .playerMain || viewModel.isBattlePausedForDialogue || viewModel.isTutorialBlocking)
        .opacity(viewModel.state.phase == .playerMain && !viewModel.isBattlePausedForDialogue && !viewModel.isTutorialBlocking ? 1 : 0.4)
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
    BattleView(viewModel: BattleViewModel(), onExit: { _ in })
}
