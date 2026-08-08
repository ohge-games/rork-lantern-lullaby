import SwiftUI

/// The landscape staging area: enemies stand on the left, heroes on the
/// right, facing each other across the dream-forest clearing like figures
/// on facing pages of a storybook.
///
/// Depth staggering: the front character (primary enemy / active hero)
/// stands nearest the center, larger and lower; supports stand behind —
/// smaller and higher up the receding ground plane.
///
/// Tap rules mirror the old rows: tapping an enemy targets (or confirms
/// on) it; tapping an inactive hero switches the lead (free); tapping the
/// active hero shows their passive tooltip.
struct BattlefieldView: View {
    let viewModel: BattleViewModel

    @State private var tooltipAllyID: UUID?

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let frontHeight = size.height * 0.44
            let backHeight = size.height * 0.36

            ZStack {
                enemySide(size: size, frontHeight: frontHeight, backHeight: backHeight)
                heroSide(size: size, frontHeight: frontHeight, backHeight: backHeight)

                if let ally = viewModel.allies.first(where: { $0.id == tooltipAllyID }) {
                    passiveTooltip(for: ally)
                        .position(x: size.width * 0.74, y: size.height * 0.13)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                        .zIndex(10)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: tooltipAllyID)
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: viewModel.activeAllyID)
        }
    }

    // MARK: - Enemy side (left)

    private func enemySide(size: CGSize, frontHeight: CGFloat, backHeight: CGFloat) -> some View {
        // enemies[0] is the primary — it stands in front, nearest the center.
        let enemies = viewModel.enemies
        // Back-row first so the front enemy draws over them.
        let slots: [(index: Int, x: CGFloat, y: CGFloat, height: CGFloat)] = [
            (2, 0.085, 0.42, backHeight),
            (1, 0.195, 0.45, backHeight),
            (0, 0.325, 0.56, frontHeight),
        ]

        return ZStack {
            ForEach(slots, id: \.index) { slot in
                if enemies.indices.contains(slot.index) {
                    let enemy = enemies[slot.index]
                    BattlefieldCharacterView(
                        artName: enemy.fullBodyArtName,
                        name: enemy.name,
                        health: enemy.health,
                        maxHealth: enemy.maxHealth,
                        shield: enemy.shield,
                        healthTint: DreamTheme.danger,
                        bodyHeight: slot.height,
                        intent: enemy.intent,
                        isTargeted: viewModel.targetedEnemyID == enemy.id,
                        isTargetable: viewModel.isTargetingActive && enemy.health > 0,
                        previewDamage: previewDamage(for: enemy),
                        hit: viewModel.enemyHitTargetID == enemy.id ? viewModel.enemyHit : nil,
                        breathDelay: Double(slot.index) * 0.55,
                        onFrameChange: { viewModel.reportEnemyFrame(enemy.id, frame: $0) },
                        onTap: { viewModel.tapEnemy(enemy.id) }
                    )
                    .position(x: size.width * slot.x, y: size.height * slot.y)
                }
            }
        }
        // The whole nightmare side lunges when it acts.
        .phaseAnimator([false, true], trigger: viewModel.enemyActionTrigger) { content, pulsing in
            content
                .scaleEffect(pulsing ? 1.035 : 1, anchor: UnitPoint(x: 0.25, y: 0.7))
                .brightness(pulsing ? 0.05 : 0)
        } animation: { pulsing in
            pulsing
                ? .spring(response: 0.16, dampingFraction: 0.5)
                : .spring(response: 0.45, dampingFraction: 0.75)
        }
        .opacity(viewModel.isEnemyThinking ? 0.92 : 1)
        .animation(.easeInOut(duration: 0.4), value: viewModel.isEnemyThinking)
    }

    // MARK: - Hero side (right)

    private func heroSide(size: CGSize, frontHeight: CGFloat, backHeight: CGFloat) -> some View {
        // The active hero steps to the front, nearest the center; the
        // others wait behind. Order within the back row stays stable.
        let allies = viewModel.allies
        let active = allies.first { $0.isActive }
        let benched = allies.filter { !$0.isActive }

        let backSlots: [(x: CGFloat, y: CGFloat)] = [
            (0.815, 0.45),
            (0.92, 0.42),
        ]

        return ZStack {
            ForEach(Array(benched.enumerated()), id: \.element.id) { index, ally in
                if index < backSlots.count {
                    heroView(ally, bodyHeight: backHeight, breathDelay: Double(index) * 0.7 + 0.3)
                        .position(
                            x: size.width * backSlots[index].x,
                            y: size.height * backSlots[index].y
                        )
                }
            }

            if let active {
                heroView(active, bodyHeight: frontHeight, breathDelay: 0)
                    .position(x: size.width * 0.675, y: size.height * 0.56)
            }
        }
    }

    private func heroView(_ ally: AllyMember, bodyHeight: CGFloat, breathDelay: Double) -> some View {
        BattlefieldCharacterView(
            artName: ally.fullBodyArtName,
            name: ally.name,
            health: ally.health,
            maxHealth: ally.maxHealth,
            shield: ally.shield,
            healthTint: DreamTheme.healthGreen,
            bodyHeight: bodyHeight,
            showsActiveTag: ally.isActive,
            hit: viewModel.playerHitTargetID == ally.id ? viewModel.playerHit : nil,
            breathDelay: breathDelay,
            onTap: { handleTap(on: ally) }
        )
    }

    private func handleTap(on ally: AllyMember) {
        if ally.isActive {
            toggleTooltip(for: ally.id)
        } else {
            tooltipAllyID = nil
            viewModel.switchActiveHero(to: ally.id)
        }
    }

    private func toggleTooltip(for id: UUID) {
        if tooltipAllyID == id {
            tooltipAllyID = nil
            return
        }
        tooltipAllyID = id
        Task {
            try? await Task.sleep(for: .milliseconds(3500))
            if tooltipAllyID == id { tooltipAllyID = nil }
        }
    }

    // MARK: - Shared pieces

    private func previewDamage(for enemy: EnemyMember) -> Int? {
        guard viewModel.isTargetingActive,
              viewModel.targetedEnemyID == enemy.id,
              let card = viewModel.selectedCard else { return nil }
        let damage = viewModel.projectedDamage(of: card)
        return damage > 0 ? damage : nil
    }

    private func passiveTooltip(for ally: AllyMember) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 13))
                .foregroundStyle(DreamTheme.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(ally.name) · \(ally.passiveName)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                Text(ally.passiveText)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.10, green: 0.09, blue: 0.22).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DreamTheme.gold.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 12, y: 4)
    }
}
