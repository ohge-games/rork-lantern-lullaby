import SwiftUI

/// The story so far, in the reader's own words.
///
/// Everything the player has actually read — the prologue, the pages they
/// have cleared, and the waking-world interludes between chapters — kept in
/// one place they can go back to. Nothing here is a spoiler: a page that has
/// not been played shows only as a locked line.
///
/// It exists because this is a game a ten-year-old plays twenty minutes at a
/// time, a week apart, and "wait, who is Kay again?" should have an answer
/// that is not "start over".
struct JournalView: View {
    let coordinator: CampaignCoordinator
    let onDone: () -> Void

    @State private var chapterIndex: Int = 0

    private var chapter: Chapter {
        coordinator.chapters.indices.contains(chapterIndex)
            ? coordinator.chapters[chapterIndex]
            : coordinator.chapters[0]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture(perform: onDone)

            HStack(spacing: 0) {
                spine
                pages
            }
            .frame(maxWidth: 760, maxHeight: 380)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.09, green: 0.08, blue: 0.19)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DreamTheme.gold.opacity(0.35), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.55), radius: 24, y: 8)
            .padding(24)
        }
        .onAppear { chapterIndex = coordinator.selectedChapterIndex }
    }

    // MARK: - Chapter spine

    private var spine: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("THE STORY SO FAR")
                .font(.system(size: 9, weight: .heavy))
                .tracking(2)
                .foregroundStyle(DreamTheme.gold.opacity(0.85))
                .padding(.bottom, 2)

            ForEach(coordinator.chapters) { entry in
                chapterTab(entry)
            }

            Spacer()

            Button(action: onDone) {
                Label("Close", systemImage: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(14)
        .frame(width: 200, alignment: .leading)
        .background(.white.opacity(0.04))
    }

    private func chapterTab(_ entry: Chapter) -> some View {
        let selected = entry.index == chapterIndex
        let read = coordinator.clearedCount(in: entry)
        return Button {
            chapterIndex = entry.index
        } label: {
            HStack(spacing: 8) {
                Text(VictorySummary.numeral(entry.index))
                    .font(.system(size: 11, weight: .heavy, design: .serif))
                    .foregroundStyle(selected ? .black : .white.opacity(0.7))
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(selected ? DreamTheme.gold : .white.opacity(0.08)))

                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.title)
                        .font(.system(size: 12, weight: .semibold))
                        .fontDesign(.serif)
                        .foregroundStyle(.white.opacity(read > 0 ? 0.95 : 0.45))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(read > 0 ? "\(read) of \(entry.stages.count) read" : "unread")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .fill(selected ? DreamTheme.gold.opacity(0.12) : .clear)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Pages

    private var pages: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text(chapter.title)
                    .font(.system(size: 20, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)

                if chapterIndex == 0, coordinator.hasSeenPrologue {
                    transcript(
                        title: "Before the first page",
                        subtitle: "The shop on the corner",
                        lines: NarrativeCatalogBook1.prologueScenes.flatMap(\.lines)
                    )
                }

                ForEach(chapter.stages) { stage in
                    stageEntry(stage)
                }

                if coordinator.hasReadInterlude(afterChapter: chapterIndex),
                   let scenes = NarrativeCatalogInterludes.interlude(afterChapter: chapterIndex) {
                    transcript(
                        title: "The morning after",
                        subtitle: "The waking world",
                        lines: scenes.flatMap(\.lines)
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func stageEntry(_ stage: Stage) -> some View {
        if coordinator.isStageCleared(stage) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("PAGE \(stage.index + 1)")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(1.5)
                        .foregroundStyle(DreamTheme.gold.opacity(0.8))
                    Text(stage.name)
                        .font(.system(size: 13, weight: .bold))
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                    if stage.isBoss {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(DreamTheme.gold)
                    }
                }

                if let opening = stage.battle?.openingNarrative, !opening.isEmpty {
                    Text(opening)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let victory = stage.battle?.victoryNarrative, !victory.isEmpty {
                    Text(victory)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, 2)
        } else {
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.22))
                Text("Page \(stage.index + 1) — not yet read")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
    }

    /// A scene played back as a transcript: who said it, and what.
    private func transcript(title: String, subtitle: String, lines: [DialogueLine]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(DreamTheme.shieldBlue.opacity(0.85))
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white.opacity(0.9))
            }

            ForEach(lines) { line in
                if line.isPlayerThought {
                    Text(line.text)
                        .font(.system(size: 11))
                        .italic()
                        .foregroundStyle(.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                } else if line.speakerName == "Narrator" || line.speakerName.isEmpty {
                    Text(line.text)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    (Text("\(line.speakerName): ").font(.system(size: 11, weight: .bold))
                        .foregroundColor(DreamTheme.gold)
                     + Text(line.text).font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8)))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.08), lineWidth: 1))
    }
}
