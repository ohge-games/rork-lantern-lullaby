import SwiftUI

/// A full-body character standing on the battlefield stage.
///
/// Used for both sides of the field: enemies carry an intent chip overhead,
/// the current player hero carries an "ACTIVE" tag. Every character shows a
/// health bar above their head, breathes gently in place, and casts a soft
/// ground shadow so they sit on the dream-forest floor.
///
/// Targeting states (offensive card selected):
/// - targetable: warm gold rim glow
/// - targeted: rotating dashed ground reticle + damage preview chip
/// - defeated/fallen: dimmed, desaturated, untappable
struct BattlefieldCharacterView: View {
    let artName: String
    let name: String
    let health: Int
    let maxHealth: Int
    let shield: Int
    let healthTint: Color
    let bodyHeight: CGFloat
    var intent: EnemyIntent? = nil
    /// The move after next, revealed while the player is Drifting.
    var nextIntent: EnemyIntent? = nil
    /// Who an attack intent is aimed at ("→ Wart").
    var intentTargetName: String? = nil
    /// Paintings drawn facing the wrong way are mirrored so both sides
    /// face the center of the field.
    var isMirrored: Bool = false
    /// Reticle and preview colour: danger red for enemies, gold for heroes.
    var targetTint: Color = DreamTheme.danger
    var showsActiveTag: Bool = false
    var isTargeted: Bool = false
    var isTargetable: Bool = false
    var previewDamage: Int? = nil
    var hit: HitEvent? = nil
    /// Staggers the idle breath so the row never moves in lockstep.
    var breathDelay: Double = 0
    /// Reports this figure's frame (global space) for card-drop hit-testing.
    var onFrameChange: ((CGRect) -> Void)? = nil
    let onTap: () -> Void

    @State private var breathe = false
    @State private var reticleAngle: Double = 0

    private var isDown: Bool { health <= 0 }

    private var barWidth: CGFloat { max(64, bodyHeight * 0.42) }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                overhead
                figure
            }
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isDown)
        .opacity(isDown ? 0.38 : 1)
        .saturation(isDown ? 0.15 : 1)
        .overlay(alignment: .top) {
            if let hit {
                FloatingHitText(hit: hit)
            }
        }
        .overlay(alignment: .top) {
            if isTargeted, let previewDamage, previewDamage > 0 {
                damagePreviewChip(previewDamage)
                    .offset(y: -16)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isTargeted)
        .animation(.easeInOut(duration: 0.3), value: isTargetable)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            onFrameChange?(frame)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.3)
                    .repeatForever(autoreverses: true)
                    .delay(breathDelay)
            ) {
                breathe = true
            }
        }
    }

    // MARK: - Overhead plate

    /// Three short rows on a dark backing: what they will do, who they are,
    /// how they are doing. Kept compact so nothing stacks into a column.
    private var overhead: some View {
        VStack(spacing: 3) {
            if showsActiveTag {
                Text("LEAD")
                    .font(.system(size: 8, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(DreamTheme.gold))
                    .shadow(color: DreamTheme.gold.opacity(0.6), radius: 6)
            } else if let intent, !isDown {
                HStack(spacing: 4) {
                    if let nextIntent {
                        IntentChip(intent: nextIntent, isPreview: true)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    IntentChip(intent: intent, targetName: intentTargetName)
                }
                .transition(.opacity)
            }

            HStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if shield > 0 {
                    ShieldChip(amount: shield)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            HStack(spacing: 5) {
                HealthBarView(current: health, maximum: maxHealth, tint: healthTint)
                    .frame(width: barWidth, height: 6)
                Text(isDown ? "Down" : "\(health)/\(maxHealth)")
                    .font(.system(size: 8, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 10).fill(.black.opacity(0.42)))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: shield)
    }

    // MARK: - Figure

    private var figure: some View {
        ZStack(alignment: .bottom) {
            // Ground contact: a wide, soft shadow pooling under the feet.
            Ellipse()
                .fill(.black.opacity(0.5))
                .frame(width: bodyHeight * 0.62, height: bodyHeight * 0.11)
                .blur(radius: 7)
                .offset(y: bodyHeight * 0.03)

            if isTargeted {
                groundReticle
                    .transition(.scale(scale: 1.4).combined(with: .opacity))
            }

            Image(artName)
                .resizable()
                .scaledToFit()
                .frame(height: bodyHeight)
                .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
                .shadow(
                    color: (isTargeted ? targetTint : DreamTheme.gold).opacity(isTargetable ? 0.65 : 0),
                    radius: 14
                )
                .shadow(
                    color: DreamTheme.gold.opacity(showsActiveTag ? 0.30 : 0),
                    radius: 18
                )
                // Idle breath: a slow rise and settle from the feet.
                .scaleEffect(x: 1, y: breathe ? 1.014 : 0.986, anchor: .bottom)
                .rotationEffect(.degrees(isDown ? 6 : 0), anchor: .bottom)
        }
    }

    /// Ground-plane target marker: a stable flattened ring lying under the
    /// character's feet. The dashes orbit around the ring (the rotation is
    /// applied before the perspective flatten, so the ellipse itself never
    /// tumbles) while four fixed ticks anchor the crosshair.
    private var groundReticle: some View {
        let ringSize = bodyHeight * 0.56
        return ZStack {
            // Soft danger glow pooling on the ground.
            Circle()
                .stroke(targetTint.opacity(0.30), lineWidth: 7)
                .blur(radius: 5)

            // Dashes traveling around the ring.
            Circle()
                .stroke(
                    targetTint.opacity(0.95),
                    style: StrokeStyle(lineWidth: 2.2, dash: [10, 8])
                )
                .rotationEffect(.degrees(reticleAngle))

            // Fixed crosshair ticks at the diagonals.
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(targetTint)
                    .frame(width: 3, height: 11)
                    .offset(y: -ringSize / 2)
                    .rotationEffect(.degrees(Double(index) * 90 + 45))
            }
        }
        .frame(width: ringSize, height: ringSize)
        // Lay the ring flat onto the ground plane.
        .scaleEffect(x: 1, y: 0.30, anchor: .center)
        .offset(y: ringSize * 0.5)
        .onAppear {
            reticleAngle = 0
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                reticleAngle = 360
            }
        }
    }

    /// "-N" chip previewing what the selected card would deal here.
    private func damagePreviewChip(_ amount: Int) -> some View {
        Text("-\(amount)")
            .font(.system(size: 13, weight: .heavy))
            .monospacedDigit()
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(Capsule().fill(targetTint))
            .shadow(color: targetTint.opacity(0.6), radius: 6)
    }
}
