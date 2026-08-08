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
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Capsule().fill(.black.opacity(0.3)))
        .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
    }
}
