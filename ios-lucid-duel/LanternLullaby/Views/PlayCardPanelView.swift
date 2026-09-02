import SwiftUI

/// Confirmation panel shown above the hand when a card is selected.
///
/// Standard cards get a single Play button with resolved effect values
/// (boosted numbers in gold) and a meter projection. Dual-direction cards
/// ("Focused Mind") replace the Play button with one button per branch,
/// each carrying its own projection and danger styling.
struct PlayCardPanelView: View {
    let viewModel: BattleViewModel
    let card: Card

    var body: some View {
        Group {
            if let choices = card.choices {
                choiceLayout(choices: choices)
            } else {
                standardLayout
            }
        }
        .padding(12)
        .dreamPanel()
    }

    // MARK: - Standard cards

    private var standardLayout: some View {
        let projected = viewModel.projectedLucidity(after: card)
        let projectedZone = LucidityZone.zone(for: projected)

        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                cardHeader
                effectLines

                if viewModel.cardDealsDamage(card) {
                    targetLine
                }

                lucidityLine(projected: projected, projectedZone: projectedZone)

                if projectedZone.isLoseCondition {
                    Label("This would end the duel", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(DreamTheme.danger)
                }
            }

            Spacer()

            VStack(spacing: 6) {
                playButton(dangerous: projectedZone.isLoseCondition)
                cancelButton
            }
        }
    }

    // MARK: - Dual-direction cards

    private func choiceLayout(choices: [CardChoiceOption]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                cardHeader
                Spacer()
                cancelButton
            }

            Text("Choose one:")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 8) {
                ForEach(choices) { choice in
                    choiceButton(choice)
                }
            }
        }
    }

    private func choiceButton(_ choice: CardChoiceOption) -> some View {
        let projected = viewModel.projectedLucidity(after: card, choice: choice)
        let projectedZone = LucidityZone.zone(for: projected)
        let dangerous = projectedZone.isLoseCondition

        return Button {
            viewModel.playSelectedCard(choice: choice)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Label(choice.name, systemImage: choice.iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)

                Text(choice.text)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                HStack(spacing: 4) {
                    Text("→ \(projected)")
                        .font(.system(size: 10, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.75))
                    Circle()
                        .fill(projectedZone.color)
                        .frame(width: 6, height: 6)
                    Text(dangerous ? "Ends the duel" : projectedZone.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(dangerous ? DreamTheme.danger : projectedZone.color)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(dangerous ? DreamTheme.danger.opacity(0.16) : .white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        dangerous ? DreamTheme.danger.opacity(0.6) : DreamTheme.gold.opacity(0.35),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Shared pieces

    private var cardHeader: some View {
        HStack(spacing: 6) {
            Text(card.name)
                .font(.subheadline.weight(.bold))
                .fontDesign(.serif)
                .foregroundStyle(.white)
            if viewModel.isBonusActive(for: card) {
                Text("+20%")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(DreamTheme.gold))
            }
        }
    }

    /// Names the current target and hints at the tap-to-retarget flow.
    private var targetLine: some View {
        HStack(spacing: 5) {
            Image(systemName: "scope")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(DreamTheme.danger)
            Text("Target: \(viewModel.targetedEnemyName)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text("· tap an enemy to switch")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            viewModel.clearSelection()
        }
        .font(.caption)
        .foregroundStyle(.white.opacity(0.5))
    }

    private var effectLines: some View {
        HStack(spacing: 10) {
            let strain = viewModel.strain(for: card)
            Label("+\(viewModel.effectiveCost(of: card))", systemImage: "eye")
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(strain > 0 ? DreamTheme.goldDeep : .white.opacity(0.6))
            if strain > 0 {
                Text("strain +\(strain)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DreamTheme.goldDeep)
            }

            ForEach(Array(card.effects.enumerated()), id: \.offset) { _, effect in
                let resolved = viewModel.resolvedEffectValue(for: effect, on: card)
                let boosted = resolved != effect.value
                Label(summary(for: effect, resolved: resolved), systemImage: effect.type.iconName)
                    .font(.system(size: 11, weight: boosted ? .bold : .semibold))
                    .monospacedDigit()
                    .foregroundStyle(boosted ? DreamTheme.gold : .white.opacity(0.85))
            }
        }
    }

    private func lucidityLine(projected: Int, projectedZone: LucidityZone) -> some View {
        HStack(spacing: 6) {
            Text("Lucidity \(viewModel.state.player.lucidity) → \(projected)")
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.75))
            Circle()
                .fill(projectedZone.color)
                .frame(width: 7, height: 7)
            Text(projectedZone.displayName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(projectedZone.color)
        }
    }

    private func playButton(dangerous: Bool) -> some View {
        Button {
            viewModel.playSelectedCard()
        } label: {
            Text("Play")
                .font(.headline)
                .foregroundStyle(dangerous ? .white : .black)
                .padding(.horizontal, 26)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(
                        dangerous
                            ? LinearGradient(
                                colors: [DreamTheme.danger, Color(red: 0.6, green: 0.15, blue: 0.15)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : LinearGradient(
                                colors: [DreamTheme.gold, DreamTheme.goldDeep],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func summary(for effect: Effect, resolved: Int) -> String {
        switch effect.type {
        case .damage: return "Deal \(resolved)"
        case .heal: return "Heal \(resolved)"
        case .shield: return "Shield \(resolved)"
        case .lucidityModify: return resolved > 0 ? "Lucidity +\(resolved)" : "Lucidity \(resolved)"
        case .lucidityCenter: return "Center \(resolved)"
        case .drawCards: return "Draw \(resolved)"
        case .swapLead: return "Change lead"
        }
    }
}
