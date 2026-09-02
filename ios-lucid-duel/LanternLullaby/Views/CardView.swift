import SwiftUI

/// A single card face in the hand: cost, name, rules text, effect icons,
/// selection glow, and the pulsing "+20%" zone-bonus badge.
struct CardView: View {
    let card: Card
    let isSelected: Bool
    let isBonusActive: Bool

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                costChip
                Spacer()
                Image(systemName: card.cardType.iconName)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer(minLength: 2)

            Text(card.name)
                .font(.system(size: 13, weight: .bold))
                .fontDesign(.serif)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(card.text)
                .font(.system(size: 9.5))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 2)

            effectIcons
        }
        .padding(8)
        .frame(width: 100, height: 148)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(card.cardType.faceGradient)
                .overlay(
                    // Subtle top-left sheen: catches "light" like lacquered card stock.
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.12), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ? DreamTheme.gold : .white.opacity(0.15),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .overlay(alignment: .topTrailing) {
            if isBonusActive {
                BonusBadge()
                    .offset(x: 6, y: -8)
            }
        }
        .shadow(
            color: isSelected ? DreamTheme.gold.opacity(0.45) : .black.opacity(0.45),
            radius: isSelected ? 12 : 6,
            y: isSelected ? 8 : 4
        )
        .scaleEffect(isSelected ? 1.04 : 1)
    }

    private var costChip: some View {
        Text(card.lucidityCost > 0 ? "+\(card.lucidityCost)" : "0")
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(DreamTheme.gold)
            .frame(width: 26, height: 26)
            .background(Circle().fill(.black.opacity(0.35)))
            .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
    }

    private var effectIcons: some View {
        HStack(spacing: 7) {
            if card.choices != nil {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 8))
                    Text("Choice")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(DreamTheme.gold.opacity(0.9))
            }
            ForEach(Array(card.effects.enumerated()), id: \.offset) { _, effect in
                HStack(spacing: 2) {
                    Image(systemName: effect.type.iconName)
                        .font(.system(size: 8))
                    Text(effectValueLabel(effect))
                        .font(.system(size: 9, weight: .bold))
                        .monospacedDigit()
                }
                .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private func effectValueLabel(_ effect: Effect) -> String {
        if effect.type == .swapLead { return "Lead" }
        if effect.type == .lucidityModify {
            return effect.value > 0 ? "+\(effect.value)" : "\(effect.value)"
        }
        return "\(effect.value)"
    }
}

/// Pulsing gold badge shown when a zone bonus applies to this card.
struct BonusBadge: View {
    @State private var pulse = false

    var body: some View {
        Text("+20%")
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .foregroundStyle(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [DreamTheme.gold, DreamTheme.goldDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .shadow(color: DreamTheme.gold.opacity(0.7), radius: pulse ? 8 : 3)
            .scaleEffect(pulse ? 1.08 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
