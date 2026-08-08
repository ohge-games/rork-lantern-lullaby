import SwiftUI

/// The hand at the bottom of the battle screen — cards are played by
/// dragging them out of the fan.
///
/// Up to five cards fan out from the center. Larger hands switch to a
/// horizontal scroll (hold a card briefly, then drag). Pulling a card up
/// enlarges it so its art and rules text stay readable mid-drag:
/// - Attack cards: drop directly onto an enemy to strike it.
/// - Support cards: pull up past the hand and release to play.
/// - Choice cards: release up high (or on an enemy) to pick a branch.
/// Releasing anywhere else snaps the card back into the fan.
struct HandView: View {
    let viewModel: BattleViewModel

    @State private var draggingID: UUID?
    @State private var dragTranslation: CGSize = .zero
    @State private var hoveredEnemyID: UUID?

    private let cardWidth: CGFloat = 100
    private let fanLimit = 5
    /// How far up a support card must travel to play on release.
    private let playLift: CGFloat = -90
    /// Enlargement while a card is held mid-drag.
    private let dragScale: CGFloat = 1.6
    /// The held card floats above the finger so it stays readable.
    private let fingerClearance: CGFloat = 46

    /// Cards sit slightly lifted while they can be played.
    private var tappableLift: CGFloat {
        viewModel.state.phase == .playerMain ? -5 : 0
    }

    var body: some View {
        Group {
            if viewModel.state.player.hand.count > fanLimit {
                scrollLayout
            } else {
                fanLayout
            }
        }
        .frame(height: 168)
        .overlay(alignment: .top) { dragHintLabel }
        .animation(.spring(response: 0.42, dampingFraction: 0.75), value: viewModel.state.player.hand)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.selectedInstanceID)
    }

    // MARK: - Fanned layout (≤ 5 cards)

    private var fanLayout: some View {
        GeometryReader { geo in
            let hand = viewModel.state.player.hand
            let count = hand.count

            ZStack {
                if hand.isEmpty {
                    Text("No cards — end your turn to draw")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.45))
                }

                ForEach(Array(hand.enumerated()), id: \.element.id) { index, instance in
                    if let card = viewModel.card(for: instance) {
                        let isDragging = draggingID == instance.id
                        let awaitsChoice = !isDragging && viewModel.selectedInstanceID == instance.id

                        cardFace(card: card, isDragging: isDragging, isHighlighted: isDragging || awaitsChoice)
                            .gesture(dragGesture(instance: instance, card: card))
                            .rotationEffect(
                                .degrees(isDragging || awaitsChoice ? 0 : fanAngle(index: index, count: count))
                            )
                            .offset(
                                x: xOffset(index: index, count: count, width: geo.size.width)
                                    + (isDragging ? dragTranslation.width : 0),
                                y: isDragging
                                    ? dragTranslation.height - fingerClearance
                                    : (awaitsChoice ? -26 : yOffset(index: index, count: count) + tappableLift)
                            )
                            .zIndex(isDragging ? 300 : (awaitsChoice ? 100 : Double(index)))
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // MARK: - Scrollable layout (6+ cards)

    private var scrollLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.state.player.hand) { instance in
                    if let card = viewModel.card(for: instance) {
                        let isDragging = draggingID == instance.id
                        let awaitsChoice = !isDragging && viewModel.selectedInstanceID == instance.id

                        cardFace(card: card, isDragging: isDragging, isHighlighted: isDragging || awaitsChoice)
                            .gesture(pressDragGesture(instance: instance, card: card))
                            .offset(
                                x: isDragging ? dragTranslation.width : 0,
                                y: isDragging
                                    ? dragTranslation.height - fingerClearance
                                    : (awaitsChoice ? -18 : tappableLift)
                            )
                            .zIndex(isDragging ? 300 : 0)
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 12)
        }
        .contentMargins(.horizontal, 4, for: .scrollContent)
        .scrollClipDisabled()
    }

    // MARK: - Shared card face

    private func cardFace(card: Card, isDragging: Bool, isHighlighted: Bool) -> some View {
        CardView(
            card: card,
            isSelected: isHighlighted,
            isBonusActive: viewModel.isBonusActive(for: card)
        )
        // Enlarged while held so art and rules text read clearly mid-drag.
        .scaleEffect(isDragging ? dragScale : 1)
        .transition(
            .asymmetric(
                // Drawn cards slide in from the deck counter (bottom-left).
                insertion: AnyTransition.offset(x: -170, y: 40)
                    .combined(with: .scale(scale: 0.5))
                    .combined(with: .opacity),
                removal: removalTransition(for: card)
            )
        )
    }

    /// Played cards fly toward their target: attacks and utility launch far
    /// up at the enemy; defensive plays hop a short distance before fading.
    private func removalTransition(for card: Card) -> AnyTransition {
        switch card.cardType {
        case .offensive, .utility:
            return AnyTransition.offset(y: -320)
                .combined(with: .scale(scale: 0.45))
                .combined(with: .opacity)
        case .defensive:
            return AnyTransition.offset(y: -110)
                .combined(with: .scale(scale: 0.7))
                .combined(with: .opacity)
        }
    }

    // MARK: - Drag gestures

    private func dragGesture(instance: CardInstance, card: Card) -> some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .onChanged { value in
                handleDragChanged(value, instance: instance, card: card)
            }
            .onEnded { value in
                handleDragEnded(value, instance: instance, card: card)
            }
    }

    /// Inside the scroll layout a bare drag would fight the scroll view,
    /// so a short press lifts the card first, then the drag takes over.
    private func pressDragGesture(instance: CardInstance, card: Card) -> some Gesture {
        LongPressGesture(minimumDuration: 0.15)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { value in
                guard case .second(true, let drag?) = value else { return }
                handleDragChanged(drag, instance: instance, card: card)
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                handleDragEnded(drag, instance: instance, card: card)
            }
    }

    private func handleDragChanged(_ value: DragGesture.Value, instance: CardInstance, card: Card) {
        guard viewModel.state.phase == .playerMain else { return }

        if draggingID != instance.id {
            draggingID = instance.id
            viewModel.beginCardDrag(of: instance)
        }
        dragTranslation = value.translation

        // Aim at whichever living enemy the card is hovering over.
        if viewModel.cardDealsDamage(card), let enemyID = viewModel.enemyID(at: value.location) {
            if hoveredEnemyID != enemyID {
                hoveredEnemyID = enemyID
                viewModel.hoverEnemy(enemyID)
            }
        } else {
            hoveredEnemyID = nil
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value, instance: CardInstance, card: Card) {
        let overEnemyID = viewModel.enemyID(at: value.location)
        let liftedEnough = value.translation.height < playLift

        if viewModel.state.phase == .playerMain, viewModel.selectedInstanceID == instance.id {
            if card.choices != nil {
                // Dual-direction cards: the drop opens the branch picker.
                if let overEnemyID { viewModel.hoverEnemy(overEnemyID) }
                if overEnemyID == nil && !liftedEnough {
                    viewModel.clearSelection()
                }
            } else if viewModel.cardDealsDamage(card) {
                // Attacks resolve on the enemy they were dropped onto.
                if let overEnemyID {
                    viewModel.hoverEnemy(overEnemyID)
                    viewModel.playSelectedCard()
                } else {
                    viewModel.clearSelection()
                }
            } else if liftedEnough {
                // Support cards play once pulled clear of the hand.
                viewModel.playSelectedCard()
            } else {
                viewModel.clearSelection()
            }
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            draggingID = nil
            dragTranslation = .zero
        }
        hoveredEnemyID = nil
        viewModel.endCardDrag()
    }

    // MARK: - Drag hint

    @ViewBuilder
    private var dragHintLabel: some View {
        if let hint = dragHint {
            Text(hint)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(DreamTheme.gold.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(.black.opacity(0.45)))
                .offset(y: -26)
                .transition(.opacity)
                .allowsHitTesting(false)
        }
    }

    private var dragHint: String? {
        guard let draggingID,
              let instance = viewModel.state.player.hand.first(where: { $0.id == draggingID }),
              let card = viewModel.card(for: instance) else { return nil }

        if card.choices != nil {
            return "Release up high to choose a path"
        }
        if viewModel.cardDealsDamage(card) {
            return hoveredEnemyID == nil ? "Drop onto an enemy" : "Release to strike"
        }
        return dragTranslation.height < playLift ? "Release to play" : "Drag up to play"
    }

    // MARK: - Fan math

    private func mid(_ count: Int) -> Double {
        Double(count - 1) / 2
    }

    private func fanAngle(index: Int, count: Int) -> Double {
        (Double(index) - mid(count)) * 3
    }

    private func xOffset(index: Int, count: Int, width: CGFloat) -> CGFloat {
        guard count > 1 else { return 0 }
        let spread = min(cardWidth * 0.72, (width - cardWidth) / CGFloat(count - 1))
        return (CGFloat(index) - CGFloat(mid(count))) * spread
    }

    private func yOffset(index: Int, count: Int) -> CGFloat {
        abs(CGFloat(index) - CGFloat(mid(count))) * 6
    }
}
