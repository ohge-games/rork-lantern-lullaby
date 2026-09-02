import SwiftUI

/// The hand at the bottom of the battle screen.
///
/// Cards are played by dragging a *thread*, not the card: touch a card and
/// it lifts and enlarges in place so its text stays readable, while a
/// glowing line follows the finger to a target on the field.
/// - Attack cards: release on an enemy to strike it.
/// - Support cards (shields, heals, Relax, Step Forward): release on one
///   of your heroes.
/// - Dual-direction cards: release on either to open the branch picker.
/// Releasing anywhere else snaps the thread back.
///
/// Up to five cards fan out from the center; larger hands switch to a
/// horizontal scroll (hold a card briefly, then drag).
struct HandView: View {
    let viewModel: BattleViewModel

    @State private var draggingID: UUID?
    @State private var cardFrames: [UUID: CGRect] = [:]

    private let cardWidth: CGFloat = 100
    private let fanLimit = 5
    /// Enlargement while a card is held.
    private let dragScale: CGFloat = 1.28
    /// How far a held card lifts out of the fan.
    private let dragLift: CGFloat = -34

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
                        let lifted = isDragging || awaitsChoice

                        cardFace(instance: instance, card: card, isDragging: isDragging, isHighlighted: lifted)
                            .gesture(dragGesture(instance: instance, card: card))
                            .rotationEffect(.degrees(lifted ? 0 : fanAngle(index: index, count: count)))
                            .offset(
                                x: xOffset(index: index, count: count, width: geo.size.width),
                                y: isDragging ? dragLift : (awaitsChoice ? -26 : yOffset(index: index, count: count) + tappableLift)
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

                        cardFace(instance: instance, card: card, isDragging: isDragging, isHighlighted: isDragging || awaitsChoice)
                            .gesture(pressDragGesture(instance: instance, card: card))
                            .offset(y: isDragging ? dragLift : (awaitsChoice ? -18 : tappableLift))
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

    private func cardFace(instance: CardInstance, card: Card, isDragging: Bool, isHighlighted: Bool) -> some View {
        CardView(
            card: card,
            isSelected: isHighlighted,
            isBonusActive: viewModel.isBonusActive(for: card)
        )
        // Enlarged while held so art and rules text read clearly.
        .scaleEffect(isDragging ? dragScale : 1)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            cardFrames[instance.id] = frame
        }
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

    /// Played cards fly toward their side of the field: attacks launch to
    /// the right at the enemy, support plays hop left toward the party.
    private func removalTransition(for card: Card) -> AnyTransition {
        if viewModel.cardDealsDamage(card) && card.choices == nil {
            return AnyTransition.offset(x: 260, y: -220)
                .combined(with: .scale(scale: 0.4))
                .combined(with: .opacity)
        }
        return AnyTransition.offset(x: -220, y: -160)
            .combined(with: .scale(scale: 0.5))
            .combined(with: .opacity)
    }

    // MARK: - Drag gestures

    private func dragGesture(instance: CardInstance, card: Card) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
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
        guard viewModel.isDraggingCard else { return }

        // The thread starts at the top edge of the held card.
        let frame = cardFrames[instance.id] ?? CGRect(origin: value.startLocation, size: .zero)
        let anchor = CGPoint(x: frame.midX, y: frame.minY + 6)
        viewModel.updateCardDrag(anchor: anchor, point: value.location)
    }

    private func handleDragEnded(_ value: DragGesture.Value, instance: CardInstance, card: Card) {
        if viewModel.state.phase == .playerMain, viewModel.selectedInstanceID == instance.id {
            let enemyUnderFinger = viewModel.enemyID(at: value.location)
            let allyUnderFinger = viewModel.allyID(at: value.location)

            if card.choices != nil {
                // Dual-direction cards: the drop opens the branch picker and
                // remembers where the card landed.
                if let enemyUnderFinger {
                    viewModel.hoverEnemy(enemyUnderFinger)
                    viewModel.setPendingAllyTarget(nil)
                } else if let allyUnderFinger {
                    viewModel.setPendingAllyTarget(allyUnderFinger)
                } else {
                    viewModel.clearSelection()
                }
            } else if viewModel.cardDealsDamage(card) {
                if let enemyUnderFinger {
                    viewModel.hoverEnemy(enemyUnderFinger)
                    viewModel.playSelectedCard()
                } else {
                    viewModel.clearSelection()
                }
            } else if let allyUnderFinger {
                viewModel.playSelectedCard(allyTarget: allyUnderFinger)
            } else {
                viewModel.clearSelection()
            }
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            draggingID = nil
        }
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
                .offset(y: -60)
                .transition(.opacity)
                .allowsHitTesting(false)
        }
    }

    private var dragHint: String? {
        guard let draggingID,
              let instance = viewModel.state.player.hand.first(where: { $0.id == draggingID }),
              let card = viewModel.card(for: instance) else { return nil }

        if viewModel.hasDropTarget {
            return card.choices != nil ? "Release to choose a path" : "Release to play"
        }
        if card.choices != nil {
            return "Draw the thread to an enemy or a hero"
        }
        if viewModel.cardDealsDamage(card) {
            return "Draw the thread to an enemy"
        }
        return "Draw the thread to one of your heroes"
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
