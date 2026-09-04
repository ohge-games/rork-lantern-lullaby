import SwiftUI

/// The heart of Lantern & Lullaby: a hanging dream-lantern whose flame IS
/// the Lucidity meter.
///
/// The brass frame, glass, and base never change — only the flame lives.
/// It grows continuously with Lucidity (a guttering ember at 0, a white-hot
/// flare at 100) while the current zone shapes its character:
/// - Deep Sleep: nearly out — a pulsing ember, slow 3.2s breath
/// - Drifting: small dim flame, gentle flicker
/// - Balanced: steady warm flame, subtle breathing
/// - Vivid: bright sharp flame, fast flicker
/// - Awakening: white-hot, erratic jitter, sparks rising off the tip
///
/// Meter movement answers through the flame too: a sharpening flare when
/// Lucidity rises, a dimming sigh when it falls.
struct LanternView: View {
    let lucidity: Int
    let zone: LucidityZone
    var pulse: LucidityPulse?
    /// Where the meter would land if the held card were played — drawn as
    /// a ghost mark on the ladder so the flame can be aimed, not guessed.
    var projected: Int? = nil
    /// True while a card is held over the lantern, about to be let go.
    var isReleaseTarget: Bool = false

    private let glassWidth: CGFloat = 62
    private let glassHeight: CGFloat = 108

    /// Danger range per spec: above 75 or below 25.
    private var isDanger: Bool {
        lucidity > 75 || lucidity < 25
    }

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            VStack(spacing: 4) {
                hangingRing
                cap
                HStack(alignment: .bottom, spacing: 5) {
                    glass(time: time)
                    zoneLadder
                }
                basePlate
                zoneChip
                warningLabel(time: time)
            }
            .background(ambientGlow(time: time))
            .overlay(releaseHalo(time: time))
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: lucidity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lucidity \(lucidity), \(zone.displayName) zone")
    }

    // MARK: - Frame (constant)

    private var hangingRing: some View {
        Circle()
            .stroke(metalColor, lineWidth: 2.5)
            .frame(width: 13, height: 13)
    }

    private var cap: some View {
        VStack(spacing: 1.5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(metalGradient)
                .frame(width: 30, height: 7)
            RoundedRectangle(cornerRadius: 2)
                .fill(metalGradient)
                .frame(width: 48, height: 6)
        }
    }

    /// The five bands of the meter drawn as a strip beside the glass, with
    /// a gold mark where the flame stands now and a hollow mark where the
    /// held card would leave it. The two lose-bands are drawn in danger red
    /// so "how close am I" is a glance, not arithmetic.
    private var zoneLadder: some View {
        GeometryReader { geo in
            let height = geo.size.height
            ZStack(alignment: .top) {
                VStack(spacing: 1) {
                    ForEach(Self.ladderBands) { band in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(band.zone.color.opacity(band.zone == zone ? 0.95 : 0.35))
                            .frame(height: max(2, height * band.share - 1))
                    }
                }
                .frame(width: 5)

                if let projected, projected != lucidity {
                    ladderMark(at: projected, in: height)
                        .foregroundStyle(.white.opacity(0.75))
                        .opacity(0.9)
                }

                ladderMark(at: lucidity, in: height)
                    .foregroundStyle(DreamTheme.gold)
                    .shadow(color: DreamTheme.gold.opacity(0.7), radius: 3)
            }
            .frame(width: 12, alignment: .leading)
        }
        .frame(width: 12, height: glassHeight)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: lucidity)
        .animation(.easeOut(duration: 0.2), value: projected)
        .accessibilityHidden(true)
    }

    /// The meter runs bottom-to-top: 0 at the base of the glass, 100 at the cap.
    private func ladderMark(at value: Int, in height: CGFloat) -> some View {
        let clamped = CGFloat(min(max(value, 0), 100)) / 100
        return Capsule()
            .frame(width: 11, height: 2)
            .offset(x: -3, y: height * (1 - clamped) - 1)
    }

    /// One band of the ladder: a zone and how much of the meter it owns.
    private struct LadderBand: Identifiable {
        let zone: LucidityZone
        let share: CGFloat
        var id: LucidityZone { zone }
    }

    /// Each band's share of the ladder, top of the meter first.
    private static let ladderBands: [LadderBand] = [
        LadderBand(zone: .awakening, share: 0.15),
        LadderBand(zone: .vivid, share: 0.20),
        LadderBand(zone: .balanced, share: 0.30),
        LadderBand(zone: .drifting, share: 0.20),
        LadderBand(zone: .deepSleep, share: 0.15),
    ]

    /// A card is held over the lantern: the glass takes a gold ring and the
    /// flame breathes, so the drop target is the lantern itself rather than
    /// a dashed rectangle drawn over it.
    @ViewBuilder
    private func releaseHalo(time: TimeInterval) -> some View {
        if isReleaseTarget {
            let breath = 0.5 + 0.5 * sin(time * (2 * .pi / 0.9))
            RoundedRectangle(cornerRadius: 20)
                .stroke(DreamTheme.gold.opacity(0.55 + 0.35 * breath), lineWidth: 2)
                .shadow(color: DreamTheme.gold.opacity(0.5 + 0.3 * breath), radius: 14)
                .padding(-6)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
    }

    private var basePlate: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(metalGradient)
            .frame(width: 56, height: 30)
            .overlay(
                VStack(spacing: -1) {
                    Text("\(lucidity)")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(DreamTheme.gold)
                        .contentTransition(.numericText(value: Double(lucidity)))
                        .shadow(color: DreamTheme.gold.opacity(0.5), radius: 4)

                    if let projected, projected != lucidity {
                        Text("→ \(projected)")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(
                                LucidityZone.zone(for: projected).isLoseCondition
                                    ? DreamTheme.danger
                                    : .white.opacity(0.75)
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }

    private var metalColor: Color {
        Color(red: 0.36, green: 0.30, blue: 0.22)
    }

    private var metalGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.45, green: 0.38, blue: 0.27), Color(red: 0.24, green: 0.19, blue: 0.13)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Glass & flame

    private func glass(time: TimeInterval) -> some View {
        ZStack {
            // Inner atmosphere lit by the flame.
            RoundedRectangle(cornerRadius: 13)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.35),
                            flameOuterColor.opacity(0.10 + glowStrength(time: time) * 0.16),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            flameGroup(time: time)

            // Glass highlight streak.
            RoundedRectangle(cornerRadius: 13)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.10), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .allowsHitTesting(false)
        }
        .frame(width: glassWidth, height: glassHeight)
        .clipShape(.rect(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(metalColor.opacity(0.9), lineWidth: 2)
        )
        .overlay(
            // Red frame glow while inside a danger range.
            RoundedRectangle(cornerRadius: 13)
                .stroke(DreamTheme.danger.opacity(dangerEdgeOpacity(time: time)), lineWidth: 1.5)
                .shadow(color: DreamTheme.danger.opacity(dangerEdgeOpacity(time: time) * 0.8), radius: 8)
        )
    }

    /// Flame layers + wick + ember + sparks, anchored to the wick.
    private func flameGroup(time: TimeInterval) -> some View {
        let height = flameHeight * flickerScaleY(time: time)
        let width = flameWidth
        let sway = flickerOffsetX(time: time)
        let wickY = glassHeight - 12
        let flameCenterY = wickY - 4 - height / 2

        return ZStack {
            // Halo cast by the flame onto the glass.
            Circle()
                .fill(flameOuterColor.opacity(glowStrength(time: time) * 0.55))
                .frame(width: 46 + flameHeight * 0.6)
                .blur(radius: 16)
                .position(x: glassWidth / 2, y: flameCenterY)

            if zone == .deepSleep {
                ember(time: time, wickY: wickY)
            } else {
                // Outer tongue.
                FlameShape()
                    .fill(flameOuterColor.opacity(0.85))
                    .frame(width: width, height: height)
                    .blur(radius: 3.5)
                    .position(x: glassWidth / 2 + sway, y: flameCenterY)

                // Mid body.
                FlameShape()
                    .fill(flameMidColor)
                    .frame(width: width * 0.62, height: height * 0.74)
                    .blur(radius: 1.2)
                    .position(x: glassWidth / 2 + sway * 0.7, y: wickY - 4 - height * 0.74 / 2)

                // Hot core.
                FlameShape()
                    .fill(flameCoreColor)
                    .frame(width: width * 0.30, height: height * 0.42)
                    .blur(radius: 0.6)
                    .position(x: glassWidth / 2 + sway * 0.4, y: wickY - 4 - height * 0.42 / 2)
            }

            // Wick.
            Capsule()
                .fill(Color(red: 0.16, green: 0.12, blue: 0.10))
                .frame(width: 3, height: 8)
                .position(x: glassWidth / 2, y: wickY)

            if zone == .awakening || lucidity > 75 {
                sparks(time: time, originY: flameCenterY - height / 2)
            }
        }
        // The flame answers meter movement: flare on rise, sigh on fall.
        .brightness(pulse?.direction == .sharpen ? 0.16 : (pulse?.direction == .soften ? -0.06 : 0))
        .saturation(pulse?.direction == .soften ? 0.75 : 1)
        .scaleEffect(
            pulse?.direction == .sharpen ? 1.12 : (pulse?.direction == .soften ? 0.93 : 1),
            anchor: .bottom
        )
        .animation(.easeOut(duration: 0.45), value: pulse?.id)
    }

    /// Deep Sleep: the flame is nearly out — a breathing ember on the wick.
    private func ember(time: TimeInterval, wickY: CGFloat) -> some View {
        // Slow, heavy 3.2s pulse.
        let breath = 0.5 + 0.5 * sin(time * (2 * .pi / 3.2))
        return ZStack {
            Circle()
                .fill(Color(red: 0.85, green: 0.30, blue: 0.10).opacity(0.35 + 0.30 * breath))
                .frame(width: 16 + 5 * breath)
                .blur(radius: 5)
            Circle()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.25).opacity(0.75 + 0.25 * breath))
                .frame(width: 5 + 2 * breath)
                .blur(radius: 0.8)
            // The faintest tongue, barely holding on.
            FlameShape()
                .fill(Color(red: 0.95, green: 0.45, blue: 0.15).opacity(0.35 + 0.35 * breath))
                .frame(width: 6, height: 10 + 3 * breath)
                .blur(radius: 1.4)
                .offset(y: -8)
        }
        .position(x: glassWidth / 2, y: wickY - 5)
    }

    /// Sparks spitting off the flame tip while it flares toward waking.
    private func sparks(time: TimeInterval, originY: CGFloat) -> some View {
        ForEach(0..<6, id: \.self) { index in
            let speed = 0.55 + Double(index % 3) * 0.22
            let progress = (time * speed + Double(index) * 0.37).truncatingRemainder(dividingBy: 1)
            let sway = CGFloat(sin(time * 3.3 + Double(index) * 2.1)) * 7
            Circle()
                .fill(
                    (index % 2 == 0 ? Color.white : DreamTheme.gold)
                        .opacity((1 - progress) * 0.85)
                )
                .frame(width: index % 3 == 0 ? 3 : 2)
                .position(
                    x: glassWidth / 2 + sway * CGFloat(progress),
                    y: originY - CGFloat(progress) * (originY - 6)
                )
                .blur(radius: 0.3)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Labels

    private var zoneChip: some View {
        Text(zone.displayName)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(zone.color)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(Capsule().fill(zone.color.opacity(0.15)))
            .overlay(Capsule().stroke(zone.color.opacity(0.35), lineWidth: 1))
            .contentTransition(.interpolate)
    }

    /// The warning line keeps its height even when silent, so the lantern
    /// above it never hops when the flame crosses into danger.
    private func warningLabel(time: TimeInterval) -> some View {
        ZStack {
            if let warning = warningText {
                // Pulsing danger warning — a 1.1s opacity cycle.
                Label(warning, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DreamTheme.danger)
                    .multilineTextAlignment(.center)
                    .frame(width: 92)
                    .opacity(0.65 + 0.35 * sin(time * (2 * .pi / 1.1)))
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .frame(width: 92, height: 24)
    }

    private var warningText: String? {
        if lucidity > 75 { return "Approaching Awakening" }
        if lucidity < 25 { return "Drifting Toward Sleep" }
        return nil
    }

    // MARK: - Flame character

    /// The flame IS the meter: it grows continuously with Lucidity,
    /// from a 10pt gutter at 0 to a 60pt blaze at 100.
    private var flameHeight: CGFloat {
        10 + CGFloat(lucidity) * 0.5
    }

    private var flameWidth: CGFloat {
        12 + CGFloat(lucidity) * 0.12
    }

    private var flameOuterColor: Color {
        switch zone {
        case .deepSleep: return Color(red: 0.60, green: 0.20, blue: 0.08)
        case .drifting: return Color(red: 0.82, green: 0.42, blue: 0.14)
        case .balanced: return Color(red: 0.96, green: 0.60, blue: 0.20)
        case .vivid: return Color(red: 1.0, green: 0.72, blue: 0.24)
        case .awakening: return Color(red: 1.0, green: 0.42, blue: 0.22)
        }
    }

    private var flameMidColor: Color {
        switch zone {
        case .deepSleep: return Color(red: 0.85, green: 0.38, blue: 0.12)
        case .drifting: return Color(red: 0.95, green: 0.62, blue: 0.24)
        case .balanced: return Color(red: 1.0, green: 0.78, blue: 0.38)
        case .vivid: return Color(red: 1.0, green: 0.88, blue: 0.50)
        case .awakening: return Color(red: 1.0, green: 0.82, blue: 0.55)
        }
    }

    private var flameCoreColor: Color {
        switch zone {
        case .deepSleep: return Color(red: 1.0, green: 0.60, blue: 0.30)
        case .drifting: return Color(red: 1.0, green: 0.85, blue: 0.55)
        case .balanced: return Color(red: 1.0, green: 0.94, blue: 0.72)
        case .vivid: return .white
        case .awakening: return .white
        }
    }

    /// Horizontal sway: still → gentle → breathing → fast → erratic.
    private func flickerOffsetX(time: TimeInterval) -> CGFloat {
        switch zone {
        case .deepSleep:
            return 0
        case .drifting:
            return CGFloat(sin(time * 2.3)) * 1.2
        case .balanced:
            return CGFloat(sin(time * 3.0) + 0.4 * sin(time * 7.1)) * 0.9
        case .vivid:
            return CGFloat(sin(time * 6.3) + 0.6 * sin(time * 11.7)) * 1.7
        case .awakening:
            // Incommensurate frequencies — never settles, reads as erratic.
            return CGFloat(sin(time * 13.7) + sin(time * 7.3 + 1.4) + 0.7 * sin(time * 23.1)) * 2.1
        }
    }

    /// Vertical breathing of the flame body.
    private func flickerScaleY(time: TimeInterval) -> CGFloat {
        switch zone {
        case .deepSleep:
            return 1 + 0.10 * sin(time * (2 * .pi / 3.2))
        case .drifting:
            return 1 + 0.06 * sin(time * 2.6)
        case .balanced:
            return 1 + 0.05 * sin(time * (2 * .pi / 1.8))
        case .vivid:
            return 1 + 0.09 * sin(time * 6.0) + 0.04 * sin(time * 13.0)
        case .awakening:
            return 1 + 0.13 * sin(time * 11.3) + 0.08 * sin(time * 19.7 + 0.8)
        }
    }

    /// How strongly the flame lights its surroundings right now.
    private func glowStrength(time: TimeInterval) -> Double {
        let base: Double
        switch zone {
        case .deepSleep: base = 0.18
        case .drifting: base = 0.32
        case .balanced: base = 0.52
        case .vivid: base = 0.75
        case .awakening: base = 0.92
        }
        return base + 0.07 * sin(time * (zone == .awakening ? 9.0 : 2.2))
    }

    private func dangerEdgeOpacity(time: TimeInterval) -> Double {
        guard isDanger else { return 0 }
        return 0.35 + 0.30 * sin(time * (2 * .pi / 1.2))
    }

    /// Warm light the lantern casts onto the battle screen around it.
    private func ambientGlow(time: TimeInterval) -> some View {
        Circle()
            .fill(flameOuterColor.opacity(glowStrength(time: time) * 0.30))
            .frame(width: 190, height: 190)
            .blur(radius: 42)
            .allowsHitTesting(false)
    }
}

/// Classic teardrop flame: pointed tip, round belly. The two halves mirror
/// so the shape stays symmetric while offsets and scaling supply the life.
struct FlameShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX + rect.width * 0.12, y: rect.minY + rect.height * 0.55),
            control2: CGPoint(x: rect.maxX - rect.width * 0.10, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.maxY),
            control2: CGPoint(x: rect.minX - rect.width * 0.12, y: rect.minY + rect.height * 0.55)
        )
        return path
    }
}
