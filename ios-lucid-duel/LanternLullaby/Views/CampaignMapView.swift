import SwiftUI

/// The open book: a chapter on the left page, its ten stages on the right.
///
/// Tapping a stage selects it; "Drift to Sleep" starts the battle. The
/// party strip at the bottom of the left page opens the roster.
struct CampaignMapView: View {
    let coordinator: CampaignCoordinator
    let onBegin: (Stage) -> Void

    @State private var showParty = false
    @State private var confirmReset = false

    private var chapter: Chapter { coordinator.selectedChapter }

    private static let numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    var body: some View {
        ZStack {
            DreamBackground(zone: .balanced, artName: ArtCatalog.chapterCover(forChapterIndex: chapter.index))

            // Readability scrim over the chapter painting.
            LinearGradient(
                colors: [.black.opacity(0.35), .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            HStack(spacing: 18) {
                leftPage
                    .frame(width: 300)
                rightPage
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)

            if showParty {
                PartySelectView(coordinator: coordinator) {
                    showParty = false
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(50)
            }

            if let hero = coordinator.recentlyUnlockedHeroes.first, !showParty {
                unlockBanner(for: hero)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(60)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showParty)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: coordinator.recentlyUnlockedHeroes.count)
        .animation(.easeInOut(duration: 0.4), value: coordinator.selectedChapterIndex)
        .confirmationDialog("Start the book over?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Erase all progress", role: .destructive) { coordinator.resetProgress() }
            Button("Keep reading", role: .cancel) {}
        }
    }

    // MARK: - Left page: the chapter

    private var leftPage: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THE ONCE AND FUTURE KING")
                .font(.system(size: 9, weight: .heavy))
                .tracking(2.5)
                .foregroundStyle(DreamTheme.gold.opacity(0.85))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                chapterArrow(direction: -1)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chapter \(Self.numerals[min(chapter.index, 9)])")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))
                    Text(chapter.title)
                        .font(.system(size: 22, weight: .bold))
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                chapterArrow(direction: 1)
            }

            chapterCover

            HStack {
                Text("\(coordinator.clearedCount(in: chapter)) of \(chapter.stages.count) pages turned")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                if !coordinator.isChapterUnlocked(chapter) {
                    Label("Sealed", systemImage: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(DreamTheme.gold.opacity(0.8))
                }
            }

            Spacer(minLength: 4)

            partyStrip

            HStack {
                Button {
                    confirmReset = true
                } label: {
                    Text("Start over")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .buttonStyle(PressableButtonStyle())
                Spacer()
            }
        }
        .padding(16)
        .dreamPanel()
    }

    private func chapterArrow(direction: Int) -> some View {
        let target = chapter.index + direction
        let exists = coordinator.chapters.indices.contains(target)
        return Button {
            guard exists else { return }
            coordinator.selectedChapterIndex = target
            coordinator.selectedStageID = coordinator.chapters[target].stages.first?.id
        } label: {
            Image(systemName: direction < 0 ? "chevron.left" : "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(exists ? 0.7 : 0.15))
                .frame(width: 26, height: 26)
                .background(Circle().fill(.black.opacity(0.3)))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!exists)
    }

    private var chapterCover: some View {
        Color(red: 0.10, green: 0.09, blue: 0.22)
            .frame(height: 96)
            .overlay {
                Image(ArtCatalog.chapterCover(forChapterIndex: chapter.index))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.14), lineWidth: 1))
            .saturation(coordinator.isChapterUnlocked(chapter) ? 1 : 0.2)
    }

    private var partyStrip: some View {
        Button {
            showParty = true
        } label: {
            HStack(spacing: 8) {
                ForEach(Array(coordinator.party.enumerated()), id: \.element.id) { index, hero in
                    ZStack(alignment: .bottomTrailing) {
                        Image(ArtCatalog.heroPortrait(for: hero))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(
                                    index == 0 ? DreamTheme.gold : .white.opacity(0.3),
                                    lineWidth: index == 0 ? 2 : 1
                                )
                            )
                        if index == 0 {
                            Text("LEAD")
                                .font(.system(size: 6, weight: .heavy))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(DreamTheme.gold))
                                .offset(x: 4, y: 2)
                        }
                    }
                }
                ForEach(0..<max(0, CampaignCoordinator.partySize - coordinator.party.count), id: \.self) { _ in
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .foregroundStyle(.white.opacity(0.25))
                        .frame(width: 44, height: 44)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Party")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(coordinator.unlockedHeroes.count) heroes known")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.3)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Right page: the stages

    private var rightPage: some View {
        VStack(spacing: 8) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(chapter.stages) { stage in
                            stageRow(stage)
                                .id(stage.id)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onAppear {
                    if let id = coordinator.selectedStageID {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }

            beginButton
        }
        .padding(12)
        .dreamPanel()
    }

    private func stageRow(_ stage: Stage) -> some View {
        let unlocked = coordinator.isStageUnlocked(stage, in: chapter)
        let cleared = coordinator.isStageCleared(stage)
        let selected = coordinator.selectedStageID == stage.id
        let waves = coordinator.enemies(for: stage)
        let names = uniqueNames(in: waves)

        return Button {
            guard unlocked else { return }
            coordinator.selectedStageID = stage.id
        } label: {
            HStack(spacing: 10) {
                Text("\(stage.index + 1)")
                    .font(.system(size: 13, weight: .heavy, design: .serif))
                    .foregroundStyle(cleared ? .black : .white.opacity(unlocked ? 0.9 : 0.35))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(cleared ? DreamTheme.gold : .black.opacity(0.35))
                    )
                    .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(stage.name)
                            .font(.system(size: 13, weight: .bold))
                            .fontDesign(.serif)
                            .foregroundStyle(.white.opacity(unlocked ? 1 : 0.4))
                            .lineLimit(1)
                        if stage.isBoss {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(DreamTheme.gold)
                        }
                    }
                    Text(names.joined(separator: " · "))
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(unlocked ? 0.55 : 0.25))
                        .lineLimit(1)
                }

                Spacer()

                if waves.count > 1 {
                    Text("\(waves.count) WAVES")
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.black.opacity(0.3)))
                }

                Image(systemName: cleared ? "checkmark.seal.fill" : (unlocked ? "play.fill" : "lock.fill"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(cleared ? DreamTheme.gold : .white.opacity(unlocked ? 0.7 : 0.25))
                    .frame(width: 18)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? DreamTheme.gold.opacity(0.16) : .white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? DreamTheme.gold.opacity(0.7) : .white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!unlocked)
    }

    private func uniqueNames(in waves: [[Enemy]]) -> [String] {
        var names: [String] = []
        for wave in waves {
            for enemy in wave where !names.contains(enemy.name) {
                names.append(enemy.name)
            }
        }
        return names
    }

    private var beginButton: some View {
        let stage = coordinator.selectedStage
        let ready = stage.map { coordinator.isStageUnlocked($0, in: chapter) } ?? false
        return Button {
            if let stage, ready { onBegin(stage) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "moon.zzz.fill")
                Text(stage.map { "Drift to Sleep — \($0.name)" } ?? "Choose a page")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 22)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [DreamTheme.gold, DreamTheme.goldDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .shadow(color: DreamTheme.gold.opacity(ready ? 0.45 : 0), radius: 14)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!ready)
        .opacity(ready ? 1 : 0.45)
    }

    // MARK: - Unlock banner

    private func unlockBanner(for hero: Hero) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { coordinator.acknowledgeUnlocks() }

            VStack(spacing: 12) {
                Image(ArtCatalog.heroPortrait(for: hero))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(DreamTheme.gold, lineWidth: 3))
                    .shadow(color: DreamTheme.gold.opacity(0.6), radius: 16)

                Text("\(hero.name) joins your party")
                    .font(.system(size: 22, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)

                Text(hero.title)
                    .font(.subheadline)
                    .foregroundStyle(DreamTheme.gold.opacity(0.9))

                Text("\(hero.passive.name): \(hero.passive.text)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)

                Button {
                    coordinator.acknowledgeUnlocks()
                } label: {
                    Text("Welcome")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(DreamTheme.gold))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 22).fill(Color(red: 0.10, green: 0.09, blue: 0.20)))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(DreamTheme.gold.opacity(0.4), lineWidth: 1))
        }
    }
}

#Preview(traits: .landscapeLeft) {
    CampaignMapView(coordinator: CampaignCoordinator()) { _ in }
}
