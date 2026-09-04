import SwiftUI

/// Small chip telegraphing what an enemy will do next turn, and at whom.
struct IntentChip: View {
    let intent: EnemyIntent
    var targetName: String? = nil
    /// A foresight chip: the move after next, seen from the Drifting zone.
    /// Drawn quieter so it never competes with the imminent one.
    var isPreview: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            switch intent {
            case .attack(let amount):
                Label("\(amount)", systemImage: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(DreamTheme.danger)
                if let targetName {
                    Text("→ \(targetName)")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }
            case .brace(let amount):
                Label("\(amount)", systemImage: "shield.fill")
                    .font(.system(size: 10, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(DreamTheme.shieldBlue)
            case .buff(let label):
                Label(label, systemImage: "arrow.up.circle.fill")
                    .font(.system(size: 9, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(DreamTheme.gold)
            case .push(let amount):
                Label(amount > 0 ? "Lantern +\(amount)" : "Lantern \(amount)", systemImage: "flame.fill")
                    .font(.system(size: 9, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .foregroundStyle(amount > 0 ? DreamTheme.goldDeep : DreamTheme.shieldBlue)
            case .stunned:
                Label("Hushed", systemImage: "zzz")
                    .font(.system(size: 9, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Capsule().fill(.black.opacity(isPreview ? 0.25 : 0.35)))
        .overlay(
            Capsule().stroke(
                isPreview ? DreamTheme.shieldBlue.opacity(0.35) : .white.opacity(0.12),
                lineWidth: 1
            )
        )
        .opacity(isPreview ? 0.65 : 1)
        .scaleEffect(isPreview ? 0.85 : 1)
    }
}
