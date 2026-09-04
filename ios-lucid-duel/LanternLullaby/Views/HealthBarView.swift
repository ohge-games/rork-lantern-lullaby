import SwiftUI

/// Animated capsule health bar shared by both combatant panels.
struct HealthBarView: View {
    let current: Int
    let maximum: Int
    let tint: Color

    private var fraction: CGFloat {
        guard maximum > 0 else { return 0 }
        return CGFloat(max(0, current)) / CGFloat(maximum)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.08))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.75), tint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geo.size.width * fraction))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: current)
    }
}

/// Small capsule chip showing active shield points.
struct ShieldChip: View {
    let amount: Int

    var body: some View {
        Label("\(amount)", systemImage: "shield.fill")
            .font(.system(size: 10, weight: .bold))
            .monospacedDigit()
            .foregroundStyle(DreamTheme.shieldBlue)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(DreamTheme.shieldBlue.opacity(0.15)))
    }
}
