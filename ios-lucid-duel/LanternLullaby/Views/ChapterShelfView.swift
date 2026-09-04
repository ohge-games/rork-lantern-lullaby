import SwiftUI

/// The shelf: every chapter of the book at once, as covers.
///
/// The map's arrows step one chapter at a time, which is fine for the
/// chapter you are on and useless for "how much book is left". This is the
/// overview — cover, progress, and whether it is still sealed — and picking
/// one takes the map there.
struct ChapterShelfView: View {
    let coordinator: CampaignCoordinator
    let onPick: (Int) -> Void
    let onDone: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 168, maximum: 220), spacing: 12)]

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture(perform: onDone)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("THE ONCE AND FUTURE KING")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(2)
                            .foregroundStyle(DreamTheme.gold.opacity(0.85))
                        Text("Five chapters, ten pages each")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Button(action: onDone) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(.white.opacity(0.08)))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel("Close")
                }

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(coordinator.chapters) { chapter in
                            cover(for: chapter)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(16)
            .frame(maxWidth: 760, maxHeight: 400)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.09, green: 0.08, blue: 0.19)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DreamTheme.gold.opacity(0.35), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.55), radius: 24, y: 8)
            .padding(24)
        }
    }

    private func cover(for chapter: Chapter) -> some View {
        let unlocked = coordinator.isChapterUnlocked(chapter)
        let cleared = coordinator.clearedCount(in: chapter)
        let isCurrent = chapter.index == coordinator.selectedChapterIndex
        return Button {
            guard unlocked else { return }
            onPick(chapter.index)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomLeading) {
                    Color(red: 0.10, green: 0.09, blue: 0.22)
                        .frame(height: 92)
                        .overlay {
                            Image(ArtCatalog.chapterCover(forChapterIndex: chapter.index))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                        .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.75)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    Text("CHAPTER \(VictorySummary.numeral(chapter.index))")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(1.5)
                        .foregroundStyle(DreamTheme.gold)
                        .padding(8)

                    if !unlocked {
                        Color.black.opacity(0.55)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(DreamTheme.gold.opacity(0.8))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 92)
                .clipShape(.rect(cornerRadius: 12))
                .saturation(unlocked ? 1 : 0.15)

                Text(chapter.title)
                    .font(.system(size: 13, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white.opacity(unlocked ? 1 : 0.45))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                progressBar(cleared: cleared, total: chapter.stages.count, unlocked: unlocked)

                Text(statusLine(chapter: chapter, cleared: cleared, unlocked: unlocked))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isCurrent ? DreamTheme.gold.opacity(0.12) : .white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isCurrent ? DreamTheme.gold.opacity(0.65) : .white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!unlocked)
    }

    private func progressBar(cleared: Int, total: Int, unlocked: Bool) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.10))
                Capsule()
                    .fill(DreamTheme.gold.opacity(unlocked ? 0.85 : 0.3))
                    .frame(width: total > 0 ? geo.size.width * CGFloat(cleared) / CGFloat(total) : 0)
            }
        }
        .frame(height: 4)
    }

    private func statusLine(chapter: Chapter, cleared: Int, unlocked: Bool) -> String {
        if !unlocked { return "Sealed — finish the chapter before it" }
        if cleared == 0 { return "Not yet opened" }
        if cleared >= chapter.stages.count { return "Finished · \(chapter.stages.count) pages" }
        return "\(cleared) of \(chapter.stages.count) pages turned"
    }
}
