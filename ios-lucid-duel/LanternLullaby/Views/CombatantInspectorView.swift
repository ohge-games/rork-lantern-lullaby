import SwiftUI

/// The long-press card: everything the battlefield plate is too small to
/// say. Hold a hero to read their passive, their ability and how charged it
/// is; hold an enemy to read what it is about to do, what it will do after
/// that, and what kind of thing it is.
///
/// A tap still does the quick thing (target an enemy, glance at a passive);
/// this is the "tell me everything" gesture, so nothing here is a control.
struct CombatantInspectorView: View {
    let subject: Subject
    let onClose: () -> Void

    /// Everything the inspector shows, gathered by the battlefield so this
    /// view stays free of the view model.
    struct Subject {
        let name: String
        let artName: String
        let isMirrored: Bool
        let health: Int
        let maxHealth: Int
        let shield: Int
        var isLead = false
        var tier: EnemyTier? = nil
        var passiveName: String? = nil
        var passiveText: String? = nil
        var passiveAppliesNow = true
        var ability: HeroAbility? = nil
        var abilityCharge: Int = 0
        var intent: EnemyIntent? = nil
        var nextIntent: EnemyIntent? = nil
        var intentTargetName: String? = nil
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            HStack(alignment: .top, spacing: 14) {
                portrait
                details
            }
            .padding(16)
            .frame(maxWidth: 430)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.09, green: 0.08, blue: 0.20).opacity(0.98))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DreamTheme.gold.opacity(0.45), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.55), radius: 22, y: 8)
            .padding(.horizontal, 24)
            .onTapGesture(perform: onClose)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private var portrait: some View {
        Image(subject.artName)
            .resizable()
            .scaledToFit()
            .frame(width: 96, height: 128)
            .scaleEffect(x: subject.isMirrored ? -1 : 1, y: 1)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.04))
            )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(subject.name)
                    .font(.system(size: 16, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                if subject.isLead {
                    tag("LEAD", tint: DreamTheme.gold)
                }
                if let tier = subject.tier {
                    tag(tier.rawValue.uppercased(), tint: tierTint(tier))
                }
            }

            healthRow

            if let intent = subject.intent {
                intentRow(intent)
            }

            if let name = subject.passiveName, let text = subject.passiveText {
                section(icon: "sparkles", title: name, body: text, tint: DreamTheme.gold)
                if !subject.passiveAppliesNow {
                    Text("Only the hero in the lead applies their passive.")
                        .font(.system(size: 9.5))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }

            if let ability = subject.ability {
                abilityBlock(ability)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var healthRow: some View {
        HStack(spacing: 8) {
            HealthBarView(
                current: subject.health,
                maximum: subject.maxHealth,
                tint: subject.tier == nil ? DreamTheme.healthGreen : DreamTheme.danger
            )
            .frame(width: 120, height: 8)

            Text("\(subject.health)/\(subject.maxHealth)")
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.85))

            if subject.shield > 0 {
                ShieldChip(amount: subject.shield)
            }
        }
    }

    private func intentRow(_ intent: EnemyIntent) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Text("NEXT")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.45))
                IntentChip(intent: intent, targetName: subject.intentTargetName)
            }
            if let next = subject.nextIntent {
                HStack(spacing: 6) {
                    Text("THEN")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.3))
                    IntentChip(intent: next, isPreview: true)
                }
            } else {
                Text("What comes after is hidden — dim the lantern into Drifting to read further.")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.white.opacity(0.4))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func abilityBlock(_ ability: HeroAbility) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 10))
                    .foregroundStyle(DreamTheme.gold)
                Text(ability.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DreamTheme.gold)
                Text("\(min(subject.abilityCharge, ability.chargeRequired))/\(ability.chargeRequired)")
                    .font(.system(size: 10, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(spacing: 2) {
                ForEach(0..<ability.chargeRequired, id: \.self) { index in
                    Capsule()
                        .fill(index < subject.abilityCharge ? DreamTheme.gold.opacity(0.9) : .white.opacity(0.16))
                        .frame(height: 4)
                }
            }
            .frame(width: 140)

            Text(ability.text)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            Text(subject.abilityCharge >= ability.chargeRequired
                 ? "Ready. Tap the gold badge above them."
                 : "Play this hero's cards to charge it — from the back line too.")
                .font(.system(size: 9.5))
                .foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func section(icon: String, title: String, body text: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tint)
            }
            Text(text)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func tag(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .heavy))
            .tracking(1)
            .foregroundStyle(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(tint))
    }

    private func tierTint(_ tier: EnemyTier) -> Color {
        switch tier {
        case .minion: return .white.opacity(0.6)
        case .elite: return DreamTheme.shieldBlue
        case .boss: return DreamTheme.danger
        }
    }
}
