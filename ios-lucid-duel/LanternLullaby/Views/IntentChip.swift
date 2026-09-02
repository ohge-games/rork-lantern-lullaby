import SwiftUI

/// Small chip telegraphing what an enemy will do next turn.
struct IntentChip: View {
    let intent: EnemyIntent

    var body: some View {
        HStack(spacing: 3) {
            switch intent {
            case .attack(let amount):
                Label("\(amount)", systemImage: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(DreamTheme.danger)
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
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Capsule().fill(.black.opacity(0.3)))
        .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
    }
}
