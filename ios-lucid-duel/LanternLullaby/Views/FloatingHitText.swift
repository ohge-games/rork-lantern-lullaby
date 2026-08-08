import SwiftUI

/// A combat number that rises and fades above a combatant panel.
struct FloatingHitText: View {
    let hit: HitEvent

    @State private var rise = false

    private var label: String {
        hit.healthDamage > 0 ? "−\(hit.healthDamage)" : "Blocked"
    }

    private var tint: Color {
        hit.healthDamage > 0 ? Color(red: 1, green: 0.45, blue: 0.4) : DreamTheme.shieldBlue
    }

    var body: some View {
        Text(label)
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(tint)
            .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
            .offset(y: rise ? -38 : -6)
            .opacity(rise ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    rise = true
                }
            }
            .id(hit.id)
            .allowsHitTesting(false)
    }
}
