import SwiftUI

/// A look inside one of the three piles: the deck you will draw from, the
/// discard you will shuffle back, and the cards you fed to the lantern.
///
/// The deck is deliberately shown **sorted by cost, not in order** — it is
/// shuffled, and printing the order would hand the player the future. The
/// discard reads most-recent-first, which is the order it will reshuffle in.
/// Burned cards are shown last and dimmed: they are not coming back.
struct CardPileView: View {
    let pile: BattleViewModel.CardPile
    let entries: [PileEntry]
    let onClose: () -> Void

    /// One row: a card and how many copies of it are in this pile.
    struct PileEntry: Identifiable {
        let card: Card
        let count: Int
        var id: Card.ID { card.id }
    }

    private var total: Int { entries.reduce(0) { $0 + $1.count } }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                header

                if entries.isEmpty {
                    Text(emptyText)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(entries) { entry in
                                pileCard(entry)
                            }
                        }
                        .padding(14)
                    }
                }
            }
            .frame(maxWidth: 560, maxHeight: 330)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.09, green: 0.08, blue: 0.20).opacity(0.98))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DreamTheme.gold.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.55), radius: 22, y: 8)
            .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 88, maximum: 110), spacing: 10)]
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: pile.iconName)
                .font(.system(size: 13))
                .foregroundStyle(DreamTheme.gold)

            VStack(alignment: .leading, spacing: 1) {
                Text(pile.title)
                    .font(.system(size: 14, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(.white.opacity(0.08)))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.04))
    }

    private var subtitle: String {
        switch pile {
        case .deck: return "\(total) cards left · shown by cost, not by order"
        case .discard: return "\(total) cards · newest first, reshuffled when the deck runs out"
        case .burned: return "\(total) cards · given to the flame, gone for this battle"
        }
    }

    private var emptyText: String {
        switch pile {
        case .deck: return "The deck is empty. Your discard reshuffles on the next draw."
        case .discard: return "Nothing discarded yet."
        case .burned: return "You have not let any card go."
        }
    }

    private func pileCard(_ entry: PileEntry) -> some View {
        VStack(spacing: 4) {
            CardView(
                card: entry.card,
                isSelected: false,
                isBonusActive: false,
                displayCost: entry.card.lucidityCost,
                strain: 0
            )
            .scaleEffect(0.78)
            .frame(width: 80, height: 118)
            .opacity(pile == .burned ? 0.55 : 1)
            .saturation(pile == .burned ? 0.4 : 1)

            if entry.count > 1 {
                Text("×\(entry.count)")
                    .font(.system(size: 11, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(DreamTheme.gold)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.card.name), \(entry.count) \(entry.count == 1 ? "copy" : "copies")")
    }
}
