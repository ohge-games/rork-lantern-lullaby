import SwiftUI

/// Victory: "Dream Conquered" — celebratory but dreamy. Golden motes drift
/// upward through a soft glow.
///
/// The card answers the three things a player actually wants after a win:
/// what page they just turned, who joined them, and what waits next. The
/// old Final Lucidity readout lived here and told them nothing, since the
/// number was whatever the killing blow happened to cost.
struct VictoryOverlayView: View {
    var summary: VictorySummary?
    var subtitle: String = "The Nightmare dissolves into morning light."
    let onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.78 : 0)
                .ignoresSafeArea()

            // The painted final page: the child holding the lantern high
            // as the dream settles into golden motes.
            Color.clear
                .overlay {
                    Image("child_lantern_moonlit_dream")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
                .ignoresSafeArea()
                .opacity(appeared ? 0.5 : 0)

            // Readability scrim over the painting.
            LinearGradient(
                colors: [.black.opacity(0.3), .black.opacity(0.78)],
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

            content
                .scaleEffect(appeared ? 1 : 0.92)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appeared = true
            }
        }
    }

    private var content: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 34))
                .foregroundStyle(DreamTheme.gold)
                .shadow(color: DreamTheme.gold.opacity(0.8), radius: 12)
                .symbolEffect(.bounce, options: .nonRepeating, value: appeared)

            Text(summary?.isChapterFinale == true ? "Chapter Complete" : "Dream Conquered")
                .font(.system(size: 32, weight: .bold))
                .fontDesign(.serif)
                .foregroundStyle(.white)

            Text(headline)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            if let summary {
                progressPanel(summary)
                    .padding(.top, 2)

                if let hero = summary.unlockedHeroes.first {
                    unlockRow(hero)
                }

                if let next = nextLine(summary) {
                    Text(next)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DreamTheme.gold.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
            }

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
            .padding(.top, 4)
        }
        .padding(.horizontal, 36)
    }

    private var headline: String {
        guard let summary else { return subtitle }
        return "\(summary.stageName) — the page turns."
    }

    private func nextLine(_ summary: VictorySummary) -> String? {
        if let next = summary.nextStageName {
            return "Next: \(next)"
        }
        if let chapter = summary.nextChapterTitle {
            return "A new chapter opens: \(chapter)"
        }
        return nil
    }

    // MARK: - Progress

    /// Chapter, page count, and a row of pips so the shape of the chapter
    /// is visible at a glance.
    private func progressPanel(_ summary: VictorySummary) -> some View {
        VStack(spacing: 8) {
            Text("CHAPTER \(VictorySummary.numeral(pageChapterIndex(summary))) · \(summary.chapterTitle.uppercased())")
                .font(.system(size: 9, weight: .heavy))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("Page \(summary.pageNumber) of \(summary.pageCount)")
                .font(.system(size: 17, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.white)

            HStack(spacing: 4) {
                ForEach(1...max(1, summary.pageCount), id: \.self) { page in
                    Capsule()
                        .fill(
                            page < summary.pageNumber ? DreamTheme.gold.opacity(0.5)
                                : page == summary.pageNumber ? DreamTheme.gold
                                : Color.white.opacity(0.18)
                        )
                        .frame(width: page == summary.pageNumber ? 18 : 12, height: 4)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 26)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.07)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.14), lineWidth: 1))
    }

    /// The chapter's own index is not carried on the summary, so derive the
    /// numeral position from the title's place in the book at build time.
    private func pageChapterIndex(_ summary: VictorySummary) -> Int {
        CampaignCatalogBook1.allChapters.firstIndex { $0.title == summary.chapterTitle } ?? 0
    }

    private func unlockRow(_ hero: Hero) -> some View {
        HStack(spacing: 10) {
            Image(ArtCatalog.heroPortrait(for: hero))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(DreamTheme.gold, lineWidth: 2))
                .shadow(color: DreamTheme.gold.opacity(0.6), radius: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(hero.name) joins your party")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text(hero.title)
                    .font(.system(size: 10))
                    .foregroundStyle(DreamTheme.gold.opacity(0.85))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(DreamTheme.gold.opacity(0.14)))
        .overlay(Capsule().stroke(DreamTheme.gold.opacity(0.45), lineWidth: 1))
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
