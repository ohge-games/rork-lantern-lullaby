import SwiftUI

/// Title screen of Lantern & Lullaby: a storybook illustration of the
/// child asleep in bed, book still open, the lantern keeping watch on the
/// nightstand.
///
/// The scene is composited from three painterly assets: the bedroom
/// background, the sleeping child cutout, and the lantern cutout — with a
/// live glow layered onto the painted flame so it can gasp and flicker.
///
/// "Drift to Sleep" begins the sleep transition: the flame flickers twice
/// as the dream calls, then the camera slowly falls into the flame and the
/// world goes dark. The `phase` is driven from outside so the whole
/// sequence stays on one clock.
struct StartScreenView: View {
    let phase: SleepPhase
    /// Label on the call-to-action; the title screen opens the book, the
    /// campaign page drifts to sleep.
    var buttonTitle: String = "Drift to Sleep"
    /// Hidden while the scene is only being used for the sleep transition.
    var showsChrome: Bool = true
    let onBegin: () -> Void

    @State private var breathe = false
    /// Flame vitality multiplier: 1 at rest, dipping and surging while the
    /// dream flickers the lantern.
    @State private var flameLife: Double = 1

    // MARK: - Scene geometry (positions inside the 340x227 illustration)

    private let sceneSize = CGSize(width: 340, height: 227)
    /// Center of the painted lantern on the nightstand.
    private let lanternCenter = CGPoint(x: 248, y: 80)
    /// The flame inside the lantern glass — the camera dives into this point.
    private let flamePoint = CGPoint(x: 248, y: 88)
    /// Where the sleeping child rests on the painted pillow.
    private let childCenter = CGPoint(x: 146, y: 112)

    /// Zoom anchor expressed in the scene's unit space.
    private var flameAnchor: UnitPoint {
        UnitPoint(x: flamePoint.x / sceneSize.width, y: flamePoint.y / sceneSize.height)
    }

    private var isZooming: Bool { phase == .zoom }

    /// Title and button stay visible only while the bedroom is at rest.
    private var chromeOpacity: Double {
        showsChrome && (phase == .none || phase == .flicker) ? 1 : 0
    }

    var body: some View {
        ZStack {
            DreamBackground(zone: .balanced)

            // Landscape spread: title and call-to-action on the left page,
            // the painted bedroom on the right page.
            HStack(spacing: 36) {
                VStack(spacing: 0) {
                    Spacer()

                    Text("Lantern & Lullaby")
                        .font(.system(size: 34, weight: .bold))
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .opacity(chromeOpacity)

                    Text("Tend the flame. Stay in the dream.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 6)
                        .opacity(chromeOpacity)

                    Spacer(minLength: 20)

                    Button {
                        onBegin()
                    } label: {
                        Text(buttonTitle)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 44)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [DreamTheme.gold, DreamTheme.goldDeep],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            )
                            .shadow(color: DreamTheme.gold.opacity(breathe ? 0.55 : 0.3), radius: 16)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(phase != .none)
                    .opacity(chromeOpacity)

                    Text("Enter the book — but never let the flame\nburn out, nor flare into waking.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                        .opacity(chromeOpacity)

                    Spacer()
                }
                .frame(maxWidth: 340)

                bedroomScene
                    .scaleEffect(isZooming ? 12 : 1, anchor: flameAnchor)
                    .animation(.easeInOut(duration: 2.0), value: isZooming)
            }
            .padding(.horizontal, 30)

            // The flame's warmth swelling to fill the world as we fall in.
            RadialGradient(
                colors: [
                    DreamTheme.gold.opacity(0.85),
                    DreamTheme.goldDeep.opacity(0.35),
                    .clear,
                ],
                center: UnitPoint(x: 0.72, y: 0.48),
                startRadius: 10,
                endRadius: 440
            )
            .ignoresSafeArea()
            .opacity(isZooming ? 0.9 : 0)
            .animation(.easeIn(duration: 1.9), value: isZooming)
            .allowsHitTesting(false)
        }
        .animation(.easeOut(duration: 0.5), value: chromeOpacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .flicker { runFlicker() }
        }
    }

    /// The dream calling: two distinct dips and surges of the flame.
    private func runFlicker() {
        Task {
            for _ in 0..<2 {
                withAnimation(.easeOut(duration: 0.13)) { flameLife = 0.3 }
                try? await Task.sleep(for: .milliseconds(150))
                withAnimation(.easeIn(duration: 0.2)) { flameLife = 1.25 }
                try? await Task.sleep(for: .milliseconds(260))
                withAnimation(.easeInOut(duration: 0.18)) { flameLife = 1 }
                try? await Task.sleep(for: .milliseconds(280))
            }
        }
    }

    // MARK: - Storybook bedroom scene

    /// Painted background + child cutout + lantern cutout, with a live
    /// glow riding on the painted flame so the flicker reads through.
    private var bedroomScene: some View {
        Color(red: 0.10, green: 0.09, blue: 0.22)
            .frame(width: sceneSize.width, height: sceneSize.height)
            .overlay {
                Image("bedroom_night_storybook")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .allowsHitTesting(false)
            }
            .overlay { sceneFigures }
            .clipShape(.rect(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
    }

    private var sceneFigures: some View {
        ZStack {
            // The sleeping child, head on the painted pillow, gently
            // rising and falling with breath.
            Image("sleeping_child_blanket")
                .resizable()
                .scaledToFit()
                .frame(width: 132)
                .scaleEffect(breathe ? 1.012 : 0.988, anchor: .bottom)
                .position(childCenter)

            floatingZs

            // Pool of lantern light on the wall — alive with the flame.
            Circle()
                .fill(DreamTheme.gold.opacity(0.22 * flameLife))
                .frame(width: 120)
                .blur(radius: 24)
                .position(lanternCenter)

            // The lantern itself, keeping watch on the nightstand.
            Image("bedside_lantern")
                .resizable()
                .scaledToFit()
                .frame(height: 62)
                .position(lanternCenter)
                .shadow(color: DreamTheme.gold.opacity(0.35 * flameLife), radius: 8)

            // Live flame riding on the painted one, so it can gasp.
            FlameShape()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.95), DreamTheme.gold, DreamTheme.goldDeep.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 7, height: 13)
                .scaleEffect(x: max(0.4, flameLife * 0.9), y: flameLife, anchor: .bottom)
                .blur(radius: 1.1)
                .position(flamePoint)
                .shadow(color: DreamTheme.gold.opacity(0.7 * flameLife), radius: 5)
        }
        .allowsHitTesting(false)
    }

    private var floatingZs: some View {
        ForEach(0..<3, id: \.self) { index in
            Text("z")
                .font(.system(size: [10, 13, 16][index], weight: .semibold, design: .serif))
                .italic()
                .foregroundStyle(.white.opacity(breathe ? [0.55, 0.4, 0.28][index] : [0.28, 0.45, 0.55][index]))
                .position(
                    x: 176 + CGFloat(index) * 13,
                    y: 62 - CGFloat(index) * 15
                )
        }
    }
}

#Preview {
    StartScreenView(phase: .none) {}
}
