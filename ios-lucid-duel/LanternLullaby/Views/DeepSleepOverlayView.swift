import SwiftUI

/// Deep Sleep loss: gentle, slow, dark — drifting away.
///
/// The screen sinks into deep blue-black over several seconds. "Lost in
/// Dreams" surfaces late and softly, motes sink downward, and everything
/// moves like it's underwater. The opposite of Awakening in every way.
struct DeepSleepOverlayView: View {
    /// What just happened, and the one thing to try next time.
    var note: DefeatNote? = nil
    let onRetry: () -> Void
    /// Back to the book. Losing must never be a room with one door.
    var onLeave: (() -> Void)? = nil

    @State private var sunk = false
    @State private var surfaced = false

    var body: some View {
        ZStack {
            // The world slowly going under.
            Color(red: 0.015, green: 0.015, blue: 0.07)
                .opacity(sunk ? 0.97 : 0)
                .ignoresSafeArea()

            // The painted page: the child sinking through the deep,
            // their lantern's last ember drifting out of reach.
            Color.clear
                .overlay {
                    Image("child_sinking_dream")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
                .ignoresSafeArea()
                .opacity(sunk ? 0.45 : 0)

            // Dark scrim keeping the words legible over the painting.
            LinearGradient(
                colors: [.black.opacity(0.35), .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(sunk ? 1 : 0)

            sinkingMotes
                .opacity(sunk ? 1 : 0)

            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LucidityZone.deepSleep.color.opacity(0.9))
                    .shadow(color: LucidityZone.deepSleep.color.opacity(0.6), radius: 14)

                Text("Lost in Dreams")
                    .font(.system(size: 34, weight: .medium))
                    .fontDesign(.serif)
                    .italic()
                    .foregroundStyle(.white.opacity(0.85))

                Text(note?.line ?? "You slipped too deep to return")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))

                Button {
                    onRetry()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 36)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(LucidityZone.deepSleep.color.opacity(0.22))
                        )
                        .overlay(
                            Capsule().stroke(LucidityZone.deepSleep.color.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 16)

                if let advice = note?.advice {
                    DefeatAdviceView(advice: advice, tint: LucidityZone.deepSleep.color)
                        .padding(.top, 4)
                }

                if let onLeave {
                    Button(action: onLeave) {
                        Text("Close the book")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.top, 2)
                }
            }
            .opacity(surfaced ? 1 : 0)
            .offset(y: surfaced ? 0 : -16)
            .blur(radius: surfaced ? 0 : 3)
        }
        .onAppear {
            // Slow submersion first; the words arrive later, like a thought
            // fading in from very far away.
            withAnimation(.easeInOut(duration: 2.4)) {
                sunk = true
            }
            withAnimation(.easeInOut(duration: 1.8).delay(1.1)) {
                surfaced = true
            }
        }
    }

    /// Pale motes sinking slowly downward — the drift into the deep.
    private var sinkingMotes: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                ForEach(0..<14, id: \.self) { index in
                    let speed = 0.03 + Double(index % 3) * 0.015
                    let progress = (time * speed + Double(index) * 0.27).truncatingRemainder(dividingBy: 1)
                    let x = (Double(index) * 0.53 + 0.11).truncatingRemainder(dividingBy: 1)
                    let sway = sin(time * 0.35 + Double(index) * 1.7) * 10
                    Circle()
                        .fill(LucidityZone.deepSleep.color.opacity((1 - progress) * 0.35))
                        .frame(width: index % 4 == 0 ? 4 : 2.5)
                        .position(
                            x: x * geo.size.width + sway,
                            y: geo.size.height * (progress * 1.1 - 0.05)
                        )
                        .blur(radius: 0.8)
                }
            }
            .allowsHitTesting(false)
        }
    }
}
