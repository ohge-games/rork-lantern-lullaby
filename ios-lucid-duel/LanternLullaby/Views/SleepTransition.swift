import SwiftUI

/// Stages of the sleep transition that carries the child from the bedroom
/// into the dream battle.
enum SleepPhase {
    /// Bedroom idle, or battle already running.
    case none
    /// The lantern flame flickers twice — the dream calling.
    case flicker
    /// The camera slowly falls into the flame (2s).
    case zoom
    /// The black curtain lifts on the child standing in fog.
    case fogChild
    /// The fog rises (2s), revealing the battle arena behind.
    case fogLift
}

/// The dream-side of the transition, layered over the battle screen:
/// the child stands in soft fog holding their lantern; when `lifting`
/// turns true the fog rises and thins over two seconds, the child
/// dissolves into the dream, and the arena appears beneath.
struct FogRevealView: View {
    let lifting: Bool

    @State private var childBreath = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dense dream-veil hiding the arena until the fog lifts.
                LinearGradient(
                    colors: [
                        Color(red: 0.17, green: 0.16, blue: 0.34),
                        Color(red: 0.10, green: 0.09, blue: 0.24),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(lifting ? 0 : 1)
                .animation(.easeInOut(duration: 2.0), value: lifting)

                fogBank(size: geo.size)

                chapterTitle(size: geo.size)

                child(size: geo.size)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                childBreath = true
            }
        }
    }

    // MARK: - Fog

    /// Eight overlapping blurred banks; each rises and thins on its own
    /// slightly staggered schedule so the lift feels like weather, not a wipe.
    private func fogBank(size: CGSize) -> some View {
        let xs: [CGFloat] = [0.20, 0.75, 0.45, 0.90, 0.10, 0.60, 0.35, 0.80]
        let ys: [CGFloat] = [0.25, 0.18, 0.50, 0.55, 0.70, 0.78, 0.92, 0.86]
        return ForEach(0..<8, id: \.self) { index in
            let width = size.width * (0.55 + CGFloat(index % 4) * 0.18)
            Ellipse()
                .fill(
                    Color(red: 0.58, green: 0.58, blue: 0.78)
                        .opacity(lifting ? 0 : (index % 2 == 0 ? 0.30 : 0.20))
                )
                .frame(width: width, height: width * 0.42)
                .position(x: size.width * xs[index], y: size.height * ys[index])
                .blur(radius: 30)
                .offset(y: lifting ? -size.height * 0.28 - CGFloat(index) * 14 : 0)
                .animation(
                    .easeInOut(duration: 2.0).delay(Double(index) * 0.08),
                    value: lifting
                )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Chapter

    private func chapterTitle(size: CGSize) -> some View {
        VStack(spacing: 7) {
            Text("CHAPTER ONE")
                .font(.system(size: 11, weight: .bold))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.55))
            Text("The First Nightmare")
                .font(.title3)
                .fontDesign(.serif)
                .italic()
                .foregroundStyle(.white.opacity(0.9))
        }
        .position(x: size.width / 2, y: size.height * 0.24)
        .opacity(lifting ? 0 : 1)
        .animation(.easeInOut(duration: 0.8), value: lifting)
    }

    // MARK: - Child

    /// The dreamer: the painted child standing in the fog, lantern in
    /// hand — the only warm light. They breathe gently, then dissolve as
    /// the fog lifts.
    private func child(size: CGSize) -> some View {
        ZStack {
            // Ground shadow.
            Ellipse()
                .fill(.black.opacity(0.35))
                .frame(width: 96, height: 16)
                .blur(radius: 5)
                .offset(y: 92)

            // The lantern's pool of light.
            Circle()
                .fill(DreamTheme.gold.opacity(childBreath ? 0.40 : 0.26))
                .frame(width: 130)
                .blur(radius: 28)
                .offset(x: 36, y: -14)

            // The painted child, lantern raised against the dark.
            Image("child_holding_lantern")
                .resizable()
                .scaledToFit()
                .frame(height: 185)
                .shadow(color: DreamTheme.gold.opacity(childBreath ? 0.35 : 0.2), radius: 14)
        }
        .scaleEffect(childBreath ? 1.015 : 0.985, anchor: .bottom)
        .opacity(lifting ? 0 : 1)
        .animation(.easeInOut(duration: 1.0).delay(1.0), value: lifting)
        .position(x: size.width / 2, y: size.height * 0.55)
    }
}
