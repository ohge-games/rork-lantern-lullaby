import SwiftUI

/// The landscape staging area: the party stands on the left, enemies on
/// the right, facing each other across the painted clearing like figures
/// on facing pages of a storybook.
///
/// Every figure is planted on a ground line rather than floated at a
/// center point, so feet sit on the painted path. The lead hero and the
/// primary enemy stand nearest the center on the lowest, closest line;
/// supports recede toward their own edge of the page, higher up the path
/// and drawn smaller. The slots are spaced widely enough that the name
/// plates above them never stack.
///
/// Tapping an enemy targets it (or confirms a selected attack on it);
/// tapping a hero shows their passive. The party's order is set before
/// the battle — only cards like Step Forward change it here.
struct BattlefieldView: View {
    let viewModel: BattleViewModel

    @State private var tooltipAllyID: UUID?
    @State private var inspecting: CombatantInspectorView.Subject?

    /// Where the enemy row stands, front slot first. The hero side is this
    /// mirrored across the screen.
    /// The front slots sit outside the card fan's footprint (the fan spans
    /// roughly the middle third), and the far enemy slot stays clear of
    /// the lantern's drop zone in the bottom-right corner.
    private static let enemyPositions: [(x: CGFloat, ground: CGFloat, isFront: Bool)] = [
        (0.70, 0.94, true),
        (0.815, 0.78, false),
        (0.90, 0.66, false),
    ]

    private static let heroBackPositions: [(x: CGFloat, ground: CGFloat)] = [
        (0.075, 0.70),
        (0.175, 0.78),
        (0.27, 0.84),
    ]

    private static let heroLeadPosition: (x: CGFloat, ground: CGFloat) = (0.30, 0.94)

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let frontHeight = size.height * 0.50
            let backHeight = size.height * 0.40

            ZStack {
                heroSide(size: size, frontHeight: frontHeight, backHeight: backHeight)
                enemySide(size: size, frontHeight: frontHeight, backHeight: backHeight)

                if let ally = viewModel.allies.first(where: { $0.id == tooltipAllyID }) {
                    passiveTooltip(for: ally)
                        .position(x: size.width * 0.26, y: size.height * 0.30)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                        .zIndex(10)
                }

                if let subject = inspecting {
                    CombatantInspectorView(subject: subject) { inspecting = nil }
                        .zIndex(80)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: tooltipAllyID)
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: viewModel.activeAllyID)
            .animation(.easeInOut(duration: 0.35), value: viewModel.waveIndex)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.abilityTrigger)
            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: inspecting == nil)
        }
    }

    /// Plants a figure so its feet rest on `ground` (a y in the field).
    private func planted<Content: View>(_ content: Content, x: CGFloat, ground: CGFloat) -> some View {
        content
            .frame(height: ground, alignment: .bottom)
            .position(x: x, y: ground / 2)
    }

    // MARK: - Hero side (left)

    private func heroSide(size: CGSize, frontHeight: CGFloat, backHeight: CGFloat) -> some View {
        let allies = viewModel.allies
        let lead = allies.first { $0.isActive }
        let benched = allies.filter { !$0.isActive }
        let backSlots = Self.heroBackPositions

        return ZStack {
            ForEach(Array(benched.enumerated()), id: \.element.id) { index, ally in
                if index < backSlots.count {
                    planted(
                        heroView(ally, bodyHeight: backHeight, breathDelay: Double(index) * 0.7 + 0.3),
                        x: size.width * backSlots[index].x,
                        ground: size.height * backSlots[index].ground
                    )
                }
            }

            if let lead {
                planted(
                    heroView(lead, bodyHeight: frontHeight, breathDelay: 0),
                    x: size.width * Self.heroLeadPosition.x,
                    ground: size.height * Self.heroLeadPosition.ground
                )
            }
        }
    }

    private func heroView(_ ally: AllyMember, bodyHeight: CGFloat, breathDelay: Double) -> some View {
        let hero = viewModel.party.first { $0.id == ally.id }?.hero
        return BattlefieldCharacterView(
            artName: ally.fullBodyArtName,
            name: ally.name,
            health: ally.health,
            maxHealth: ally.maxHealth,
            shield: ally.shield,
            healthTint: DreamTheme.healthGreen,
            bodyHeight: bodyHeight,
            isMirrored: hero.map { ArtCatalog.isHeroMirrored($0) } ?? true,
            targetTint: DreamTheme.gold,
            showsActiveTag: ally.isActive,
            ability: viewModel.ability(for: ally.id),
            abilityCharge: viewModel.charge(for: ally.id),
            isAbilityReady: viewModel.isAbilityReady(for: ally.id),
            onFireAbility: { viewModel.fireAbility(for: ally.id) },
            isTargeted: viewModel.hoveredAllyID == ally.id,
            isTargetable: viewModel.isAllyTargetingActive && ally.health > 0,
            hit: viewModel.playerHitTargetID == ally.id ? viewModel.playerHit : nil,
            breathDelay: breathDelay,
            onFrameChange: { viewModel.reportAllyFrame(ally.id, frame: $0) },
            onInspect: { inspect(ally) },
            onTap: { toggleTooltip(for: ally.id) }
        )
    }

    /// The full record on a hero: their passive, whether it is doing
    /// anything from where they stand, and how charged their ability is.
    private func inspect(_ ally: AllyMember) {
        tooltipAllyID = nil
        inspecting = CombatantInspectorView.Subject(
            name: ally.name,
            artName: ally.fullBodyArtName,
            isMirrored: viewModel.party.first { $0.id == ally.id }
                .map { ArtCatalog.isHeroMirrored($0.hero) } ?? true,
            health: ally.health,
            maxHealth: ally.maxHealth,
            shield: ally.isActive ? ally.shield : 0,
            isLead: ally.isActive,
            passiveName: ally.passiveName,
            passiveText: ally.passiveText,
            passiveAppliesNow: ally.isActive,
            ability: viewModel.ability(for: ally.id),
            abilityCharge: viewModel.charge(for: ally.id)
        )
    }

    /// The full record on an enemy: both of its telegraphed moves, and what
    /// weight of thing it is.
    private func inspect(_ enemy: EnemyMember, definition: Enemy?) {
        inspecting = CombatantInspectorView.Subject(
            name: enemy.name,
            artName: enemy.fullBodyArtName,
            isMirrored: definition.map { ArtCatalog.isEnemyMirrored($0) } ?? true,
            health: enemy.health,
            maxHealth: enemy.maxHealth,
            shield: enemy.shield,
            tier: definition?.tier ?? .minion,
            passiveName: definition?.passive?.name,
            passiveText: definition?.passive?.text,
            intent: enemy.intent,
            nextIntent: enemy.nextIntent,
            intentTargetName: viewModel.leadHeroName
        )
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

    // MARK: - Enemy side (right)

    private func enemySide(size: CGSize, frontHeight: CGFloat, backHeight: CGFloat) -> some View {
        // enemies[0] is the primary — it stands in front, nearest the center.
        let positions = Self.enemyPositions
        let placed = viewModel.enemies.enumerated()
            .filter { positions.indices.contains($0.offset) }
        // Drawn back to front so the primary overlaps its supports, and keyed
        // by combatant id so an arriving wave re-reports its drop targets
        // instead of inheriting the last wave's stale frames.
        let backToFront = Array(placed.reversed())

        return ZStack {
            ForEach(backToFront, id: \.element.id) { pair in
                let enemy = pair.element
                let slot = positions[pair.offset]
                let definition = viewModel.enemyLine.first { $0.id == enemy.id }?.enemy
                planted(
                    BattlefieldCharacterView(
                        artName: enemy.fullBodyArtName,
                        name: enemy.name,
                        health: enemy.health,
                        maxHealth: enemy.maxHealth,
                        shield: enemy.shield,
                        healthTint: DreamTheme.danger,
                        bodyHeight: slot.isFront ? frontHeight : backHeight,
                        intent: enemy.intent,
                        nextIntent: enemy.nextIntent,
                        intentTargetName: slot.isFront ? viewModel.leadHeroName : nil,
                        isMirrored: definition.map { ArtCatalog.isEnemyMirrored($0) } ?? true,
                        isTargeted: viewModel.targetedEnemyID == enemy.id,
                        isTargetable: viewModel.isTargetingActive && enemy.health > 0,
                        previewDamage: previewDamage(for: enemy),
                        hit: viewModel.enemyHitTargetID == enemy.id ? viewModel.enemyHit : nil,
                        breathDelay: Double(pair.offset) * 0.55,
                        onFrameChange: { viewModel.reportEnemyFrame(enemy.id, frame: $0) },
                        onInspect: { inspect(enemy, definition: definition) },
                        onTap: { viewModel.tapEnemy(enemy.id) }
                    )
                    .scaleEffect(viewModel.actingEnemyID == enemy.id ? 1.05 : 1, anchor: .bottom)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: viewModel.actingEnemyID),
                    x: size.width * slot.x,
                    ground: size.height * slot.ground
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
            }
        }
        .opacity(viewModel.isEnemyThinking ? 0.92 : 1)
        .animation(.easeInOut(duration: 0.4), value: viewModel.isEnemyThinking)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isDrifting)
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
                if let ability = viewModel.ability(for: ally.id) {
                    Text("\(ability.name) · \(viewModel.charge(for: ally.id))/\(ability.chargeRequired)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(DreamTheme.gold)
                        .padding(.top, 2)
                    Text(ability.text)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !ally.isActive {
                    Text("Passive is active only while leading.")
                        .font(.system(size: 9.5))
                        .foregroundStyle(.white.opacity(0.45))
                }
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
