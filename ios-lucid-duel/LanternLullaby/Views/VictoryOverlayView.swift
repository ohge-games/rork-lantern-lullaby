import SwiftUI

/// Victory: "Dream Conquered" — celebratory but dreamy. Golden motes drift
/// upward through a soft glow while the final Lucidity position is shown.
struct VictoryOverlayView: View {
    let finalLucidity: Int
    var subtitle: String = "The Nightmare dissolves into morning light."
    let onContinue: () -> Void

    @State private var appeared = false

    private var finalZone: LucidityZone {
        LucidityZone.zone(for: finalLucidity)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.78 : 0)
                .ignoresSafeArea()

            // The painted final page: the child holding the lantern high
            // as the Nightmare dissolves into golden motes.
            Color.clear
                .overlay {
                    Image("child_lantern_moonlit_dream")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
                .ignoresSafeArea()
                .opacity(appeared ? 0.55 : 0)

            // Readability scrim over the painting.
            LinearGradient(
                colors: [.black.opacity(0.25), .black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(appeared ? 1 : 0)

            RadialGradient(
                colors: [DreamTheme.gold.opacity(appeared ? 0.22 : 0), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 340
            )
            .ignoresSafeArea()

            particles

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(DreamTheme.gold)
                    .shadow(color: DreamTheme.gold.opacity(0.8), radius: 12)
                    .symbolEffect(.bounce, options: .nonRepeating, value: appeared)

                Text("Dream Conquered")
                    .font(.system(size: 34, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)

                luciditySummary
                    .padding(.top, 4)

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [DreamTheme.gold, DreamTheme.goldDeep],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        )
                        .shadow(color: DreamTheme.gold.opacity(0.5), radius: 14)
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 10)
            }
            .padding(.horizontal, 36)
            .scaleEffect(appeared ? 1 : 0.92)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appeared = true
            }
        }
    }

    /// Where the meter ended: number, zone chip, and a mini spectrum.
    private var luciditySummary: some View {
        VStack(spacing: 8) {
            Text("FINAL LUCIDITY")
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.45))

            HStack(spacing: 8) {
                Text("\(finalLucidity)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(finalZone.displayName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(finalZone.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(finalZone.color.opacity(0.16)))
            }

            miniSpectrum
                .frame(width: 180, height: 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private var miniSpectrum: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                HStack(spacing: 2) {
                    ForEach(LucidityZone.allCases, id: \.self) { segment in
                        Capsule()
                            .fill(segment.color.opacity(segment == finalZone ? 0.95 : 0.3))
                            .frame(width: (geo.size.width - 8) * CGFloat(segment.range.count) / 101)
                    }
                }
                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .shadow(color: finalZone.color, radius: 4)
                    .offset(x: (geo.size.width - 8) * CGFloat(finalLucidity) / 100)
            }
        }
    }

    /// Slow golden motes rising through the dark — the dream celebrating.
    private var particles: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                ForEach(0..<16, id: \.self) { index in
                    let speed = 0.05 + Double(index % 4) * 0.02
                    let progress = (time * speed + Double(index) * 0.31).truncatingRemainder(dividingBy: 1)
                    let x = (Double(index) * 0.43 + 0.08).truncatingRemainder(dividingBy: 1)
                    let sway = sin(time * 0.6 + Double(index)) * 14
                    Circle()
                        .fill(DreamTheme.gold.opacity((1 - progress) * 0.55))
                        .frame(width: index % 3 == 0 ? 5 : 3)
                        .position(
                            x: x * geo.size.width + sway,
                            y: geo.size.height * (1.05 - progress * 1.1)
                        )
                        .blur(radius: 0.5)
                }
            }
            .allowsHitTesting(false)
        }
        .opacity(appeared ? 1 : 0)
    }
}
