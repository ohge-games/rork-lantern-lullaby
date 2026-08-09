import SwiftUI

// MARK: - Campaign Flow View
// Main container that switches between campaign screens based on flow state

struct CampaignFlowView: View {
    @State private var coordinator = CampaignFlowCoordinator()
    @State private var hasSeenIntro: Bool = UserDefaults.standard.bool(forKey: "HasSeenBookstoreIntro")
    @State private var showingIntro = false
    
    var body: some View {
        ZStack {
            // Main flow based on state
            switch coordinator.flowState {
            case .bookSelect:
                BookSelectView(coordinator: coordinator)
                    .transition(.opacity)
                
            case .chapterSelect:
                if let book = coordinator.currentBook {
                    ChapterSelectView(coordinator: coordinator, book: book)
                        .transition(.move(edge: .trailing))
                }
                
            case .stageSelect:
                if let book = coordinator.currentBook,
                   let chapter = coordinator.currentChapter {
                    StageSelectView(coordinator: coordinator, book: book, chapter: chapter)
                        .transition(.move(edge: .trailing))
                }
                
            case .heroSelect:
                HeroSelectView(coordinator: coordinator)
                    .transition(.move(edge: .trailing))
                
            case .inBattle:
                if let viewModel = coordinator.battleViewModel {
                    BattleView(
                        viewModel: viewModel,
                        onExit: {
                            let victory = viewModel.state.outcome == .victory
                            coordinator.completeBattle(victory: victory)
                        }
                    )
                    .transition(.opacity)
                }
                
            case .victoryScreen:
                VictoryView(coordinator: coordinator)
                    .transition(.scale.combined(with: .opacity))
                
            case .defeatScreen:
                DefeatView(coordinator: coordinator)
                    .transition(.opacity)
            }
            
            // Bookstore intro overlay
            if showingIntro {
                BookstoreSceneView(onComplete: {
                    withAnimation {
                        showingIntro = false
                        hasSeenIntro = true
                        UserDefaults.standard.set(true, forKey: "HasSeenBookstoreIntro")
                    }
                })
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.flowState)
        .onAppear {
            // Show intro on first launch
            if !hasSeenIntro {
                showingIntro = true
            }
        }
    }
}

// MARK: - Book Select View
// Choose which book to read (currently just Book 1)

struct BookSelectView: View {
    let coordinator: CampaignFlowCoordinator
    
    var body: some View {
        ZStack {
            // Bookshelf background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.12, blue: 0.1),
                    Color(red: 0.1, green: 0.08, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Title
                Text("Pages & Embers")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Choose Your Story")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                // Books
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(coordinator.allBooks) { book in
                            BookCoverView(book: book) {
                                coordinator.selectBook(book)
                            }
                        }
                        
                        // Coming soon placeholder
                        ComingSoonBookView(title: "Book of the Dead")
                        ComingSoonBookView(title: "The Odyssey")
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Stats footer
                statsFooter
            }
            .padding(.top, 60)
        }
    }
    
    private var statsFooter: some View {
        HStack(spacing: 32) {
            StatBadge(label: "Heroes", value: "\(coordinator.progress.heroCount)")
            StatBadge(label: "Stages", value: "\(coordinator.progress.totalStagesCleared)")
            StatBadge(label: "Win Rate", value: String(format: "%.0f%%", coordinator.progress.winRate))
        }
        .padding(.bottom, 32)
    }
}

struct BookCoverView: View {
    let book: Book
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Book cover
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.4, blue: 0.2),
                                    Color(red: 0.4, green: 0.25, blue: 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 220)
                        .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                    
                    // Title on spine
                    VStack {
                        Text(book.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                // Chapter count
                Text("\(book.chapters.count) Chapters")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .buttonStyle(.plain)
    }
}

struct ComingSoonBookView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 160, height: 220)
                
                VStack {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Chapter Select View
// List chapters in selected book

struct ChapterSelectView: View {
    let coordinator: CampaignFlowCoordinator
    let book: Book
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Button(action: { coordinator.exitToBookSelect() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44)
                }
                .padding()
                
                // Chapters list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(book.chapters) { chapter in
                            ChapterRowView(
                                chapter: chapter,
                                isUnlocked: coordinator.isChapterUnlocked(chapter, inBook: book),
                                progress: coordinator.chapterProgress(chapter, inBook: book)
                            ) {
                                coordinator.selectChapter(chapter)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct ChapterRowView: View {
    let chapter: Chapter
    let isUnlocked: Bool
    let progress: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: { if isUnlocked { onTap() } }) {
            HStack(spacing: 16) {
                // Chapter number
                ZStack {
                    Circle()
                        .fill(isUnlocked ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    if isUnlocked {
                        Text("\(chapter.index + 1)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                // Chapter info
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.4))
                    
                    Text("\(chapter.stages.count) stages")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    
                    // Progress bar
                    if isUnlocked && progress > 0 {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                
                Spacer()
                
                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isUnlocked ? 0.1 : 0.05))
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

// MARK: - Stage Select View
// List stages in selected chapter

struct StageSelectView: View {
    let coordinator: CampaignFlowCoordinator
    let book: Book
    let chapter: Chapter
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Button(action: { coordinator.exitToChapterSelect() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Chapter \(chapter.index + 1)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Text(chapter.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44)
                }
                .padding()
                
                // Stages grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(chapter.stages) { stage in
                            StageNodeView(
                                stage: stage,
                                isUnlocked: coordinator.isStageUnlocked(stage, inChapter: chapter, book: book),
                                isCleared: coordinator.isStageCleared(stage, inChapter: chapter, book: book)
                            ) {
                                coordinator.selectStage(stage)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct StageNodeView: View {
    let stage: Stage
    let isUnlocked: Bool
    let isCleared: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: { if isUnlocked { onTap() } }) {
            ZStack {
                // Background
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 56, height: 56)
                
                // Border for boss
                if stage.isBoss {
                    Circle()
                        .stroke(Color.red, lineWidth: 3)
                        .frame(width: 56, height: 56)
                }
                
                // Content
                if isUnlocked {
                    if isCleared {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Text("\(stage.index + 1)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
    
    private var backgroundColor: Color {
        if !isUnlocked {
            return Color.gray.opacity(0.3)
        } else if isCleared {
            return Color.green.opacity(0.8)
        } else if stage.isBoss {
            return Color.red.opacity(0.6)
        } else {
            return Color.orange.opacity(0.7)
        }
    }
}

// MARK: - Hero Select View
// Choose party before battle

struct HeroSelectView: View {
    let coordinator: CampaignFlowCoordinator
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { coordinator.exitToStageSelect() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Choose Your Party")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44)
                }
                .padding()
                
                // Selected party
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { slot in
                        PartySlotView(
                            hero: heroForSlot(slot),
                            slotIndex: slot
                        ) {
                            if let heroID = coordinator.selectedPartyHeroIDs[safe: slot] {
                                coordinator.removeHeroFromParty(heroID)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Available heroes
                Text("Available Heroes")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(coordinator.unlockedHeroes) { hero in
                            HeroCardView(
                                hero: hero,
                                isSelected: coordinator.selectedPartyHeroIDs.contains(hero.id)
                            ) {
                                if coordinator.selectedPartyHeroIDs.contains(hero.id) {
                                    coordinator.removeHeroFromParty(hero.id)
                                } else {
                                    coordinator.addHeroToParty(hero.id)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Start button
                Button(action: { coordinator.startBattle() }) {
                    Text("Begin Battle")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                        )
                }
                .padding()
                .disabled(coordinator.selectedPartyHeroIDs.isEmpty)
                .opacity(coordinator.selectedPartyHeroIDs.isEmpty ? 0.5 : 1)
            }
        }
    }
    
    private func heroForSlot(_ slot: Int) -> Hero? {
        guard let heroID = coordinator.selectedPartyHeroIDs[safe: slot] else { return nil }
        return coordinator.unlockedHeroes.first { $0.id == heroID }
    }
}

struct PartySlotView: View {
    let hero: Hero?
    let slotIndex: Int
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(hero != nil ? Color.orange.opacity(0.3) : Color.white.opacity(0.1))
                .frame(width: 80, height: 100)
            
            if let hero = hero {
                VStack(spacing: 4) {
                    Image(PortraitRegistry.heroPortrait(for: hero.id))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    Text(hero.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .onTapGesture(perform: onRemove)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Slot \(slotIndex + 1)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
    }
}

struct HeroCardView: View {
    let hero: Hero
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Image(PortraitRegistry.heroPortrait(for: hero.id))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 3)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(hero.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.15 : 0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Victory View

struct VictoryView: View {
    let coordinator: CampaignFlowCoordinator
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("Victory!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let stage = coordinator.currentStage {
                    Text(stage.name)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: { coordinator.continueAfterVictory() }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green)
                            )
                    }
                    
                    Button(action: { coordinator.exitToStageSelect() }) {
                        Text("Stage Select")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Defeat View

struct DefeatView: View {
    let coordinator: CampaignFlowCoordinator
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue.opacity(0.6))
                
                Text("You Drifted Away...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("The dream fades, but the book remains.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: { coordinator.retryAfterDefeat() }) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange)
                            )
                    }
                    
                    Button(action: { coordinator.exitToStageSelect() }) {
                        Text("Stage Select")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    CampaignFlowView()
}
