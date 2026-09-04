import SwiftUI

/// Awakening loss: harsh, sudden, bright — being jolted awake.
///
/// The screen flashes pure white, then settles into a washed-out daylight
/// glare. "You Awoke" slams in oversized and shakes like an alarm. Dark
/// text on a bright background inverts the game's entire palette — the
/// dream is gone.
struct AwakeningOverlayView: View {
    /// What just happened, and the one thing to try next time.
    var note: DefeatNote? = nil
    let onRetry: () -> Void
    /// Back to the book. Losing must never be a room with one door.
    var onLeave: (() -> Void)? = nil

    @State private var flashFaded = false
    @State private var slammed = false

    /// Animatable state for the jarring title entrance.
    private struct SlamState {
        var offsetX: CGFloat = 0
        var scale: CGFloat = 1.4
    }

    var body: some View {
        ZStack {
            // Washed-out daylight — the bright world outside the dream.
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.98, blue: 0.94),
                    Color(red: 0.96, green: 0.91, blue: 0.78),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // The painted page: harsh morning light flooding the bedroom,
            // the lantern tipped over and gone out.
            Color.clear
                .overlay {
                    Image("child_waking_morning_light")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
                .ignoresSafeArea()
                .opacity(0.5)

            // Bright scrim keeping the dark text readable on the painting.
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.98, blue: 0.94).opacity(0.55),
                    Color(red: 0.96, green: 0.91, blue: 0.78).opacity(0.8),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(Color(red: 0.95, green: 0.6, blue: 0.1))

                Text("You Awoke")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.05))
                    .keyframeAnimator(
                        initialValue: SlamState(),
                        trigger: slammed
                    ) { content, value in
                        content
                            .scaleEffect(value.scale)
                            .offset(x: value.offsetX)
                    } keyframes: { _ in
                        KeyframeTrack(\.offsetX) {
                            LinearKeyframe(-11, duration: 0.05)
                            LinearKeyframe(10, duration: 0.05)
                            LinearKeyframe(-7, duration: 0.05)
                            LinearKeyframe(5, duration: 0.05)
                            LinearKeyframe(-2, duration: 0.05)
                            SpringKeyframe(0, duration: 0.12)
                        }
                        KeyframeTrack(\.scale) {
                            CubicKeyframe(1.0, duration: 0.18)
                        }
                    }

                Text(note?.line ?? "The dream shattered before victory")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.12))

                Button {
                    onRetry()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.3, blue: 0.2),
                                        Color(red: 0.65, green: 0.18, blue: 0.12),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        )
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 14)

                if let advice = note?.advice {
                    DefeatAdviceView(advice: advice, tint: Color(red: 0.55, green: 0.30, blue: 0.12))
                        .padding(.top, 4)
                }

                if let onLeave {
                    Button(action: onLeave) {
                        Text("Close the book")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.12).opacity(0.75))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.top, 2)
                }
            }

            // The jolt itself: a full-screen white flash that burns off fast.
            Color.white
                .opacity(flashFaded ? 0 : 1)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .sensoryFeedback(.error, trigger: slammed)
        .onAppear {
            slammed = true
            withAnimation(.easeOut(duration: 0.55)) {
                flashFaded = true
            }
        }
    }
}
