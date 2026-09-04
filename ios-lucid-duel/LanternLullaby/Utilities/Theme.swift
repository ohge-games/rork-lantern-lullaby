import SwiftUI

/// Shared visual language for the duel screens.
enum DreamTheme {
    static let backgroundTop = Color(red: 0.05, green: 0.05, blue: 0.13)
    static let backgroundBottom = Color(red: 0.12, green: 0.09, blue: 0.27)
    static let gold = Color(red: 0.96, green: 0.84, blue: 0.55)
    static let goldDeep = Color(red: 0.9, green: 0.65, blue: 0.35)
    static let danger = Color(red: 0.96, green: 0.35, blue: 0.33)
    static let healthGreen = Color(red: 0.45, green: 0.82, blue: 0.55)
    static let shieldBlue = Color(red: 0.45, green: 0.75, blue: 0.95)
}

extension LucidityZone {
    /// Signature color for meter segments, chips, and warnings.
    var color: Color {
        switch self {
        case .deepSleep: return Color(red: 0.42, green: 0.42, blue: 0.85)
        case .drifting: return Color(red: 0.32, green: 0.66, blue: 0.82)
        case .balanced: return Color(red: 0.55, green: 0.78, blue: 0.62)
        case .vivid: return Color(red: 0.95, green: 0.62, blue: 0.25)
        case .awakening: return Color(red: 0.95, green: 0.32, blue: 0.32)
        }
    }

    /// Sky gradient top color while the player sits in this zone.
    var ambientTop: Color {
        switch self {
        case .deepSleep: return Color(red: 0.02, green: 0.02, blue: 0.10)
        case .drifting: return Color(red: 0.03, green: 0.06, blue: 0.14)
        case .balanced: return Color(red: 0.05, green: 0.05, blue: 0.13)
        case .vivid: return Color(red: 0.10, green: 0.05, blue: 0.09)
        case .awakening: return Color(red: 0.15, green: 0.10, blue: 0.05)
        }
    }

    /// Sky gradient bottom color while the player sits in this zone.
    var ambientBottom: Color {
        switch self {
        case .deepSleep: return Color(red: 0.08, green: 0.05, blue: 0.22)
        case .drifting: return Color(red: 0.07, green: 0.14, blue: 0.28)
        case .balanced: return Color(red: 0.12, green: 0.09, blue: 0.27)
        case .vivid: return Color(red: 0.24, green: 0.11, blue: 0.09)
        case .awakening: return Color(red: 0.32, green: 0.22, blue: 0.09)
        }
    }
}

extension CardType {
    var iconName: String {
        switch self {
        case .offensive: return "flame.fill"
        case .defensive: return "shield.lefthalf.filled"
        case .utility: return "sparkles"
        }
    }

    /// Card face gradient, dark and saturated per type.
    var faceGradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .offensive:
            colors = [Color(red: 0.45, green: 0.13, blue: 0.21), Color(red: 0.24, green: 0.06, blue: 0.14)]
        case .defensive:
            colors = [Color(red: 0.09, green: 0.27, blue: 0.34), Color(red: 0.05, green: 0.14, blue: 0.23)]
        case .utility:
            colors = [Color(red: 0.26, green: 0.17, blue: 0.42), Color(red: 0.13, green: 0.08, blue: 0.27)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension EffectType {
    var iconName: String {
        switch self {
        case .damage: return "bolt.fill"
        case .heal: return "heart.fill"
        case .shield: return "shield.fill"
        case .lucidityModify: return "moon.zzz.fill"
        case .lucidityCenter: return "scope"
        case .drawCards: return "square.stack.fill"
        case .swapLead: return "arrow.left.arrow.right"
        case .stun: return "zzz"
        case .weaken: return "arrow.down.circle.fill"
        case .shieldBreak: return "shield.slash.fill"
        case .calm: return "wind"
        }
    }
}

/// Standard translucent panel treatment used by all HUD elements.
struct DreamPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.06)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}

extension View {
    func dreamPanel() -> some View {
        modifier(DreamPanelModifier())
    }
}

/// Springy press-down feedback for all tappable elements.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
