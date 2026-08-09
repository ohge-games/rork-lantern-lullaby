import SwiftUI

// MARK: - Bookstore Scene View
// The intro experience: MC discovers Pages & Embers, meets the Shopkeeper

struct BookstoreSceneView: View {
    let onComplete: () -> Void
    
    @State private var scenePhase: BookstorePhase = .approach
    @State private var currentLineIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var showTapHint = false
    @State private var shopkeeperVisible = false
    @State private var lanternGlowing = false
    @State private var stormIntensity: Double = 0
    
    private let typingSpeed: Double = 0.03
    
    var body: some View {
        ZStack {
            // Background layers
            backgroundLayer
            
            // Storm overlay (increases as scene progresses)
            stormOverlay
            
            // Scene content
            VStack {
                Spacer()
                
                // Character area (shopkeeper appears here)
                if shopkeeperVisible {
                    shopkeeperImage
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
                
                Spacer()
                
                // Dialogue box
                dialogueBox
            }
            
            // Lantern glow effect
            if lanternGlowing {
                lanternEffect
            }
        }
        .onAppear {
            startScene()
        }
        .onTapGesture {
            handleTap()
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            // Base gradient (time of day)
            LinearGradient(
                colors: backgroundColors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Bookstore interior overlay (when inside)
            if scenePhase.isInside {
                Image("bg_bookstore_interior")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.9)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.0), value: scenePhase)
    }
    
    private var backgroundColors: [Color] {
        switch scenePhase {
        case .approach:
            return [Color(red: 0.4, green: 0.45, blue: 0.55), Color(red: 0.25, green: 0.25, blue: 0.35)]
        case .enterShop, .meetShopkeeper:
            return [Color(red: 0.15, green: 0.12, blue: 0.1), Color(red: 0.1, green: 0.08, blue: 0.05)]
        case .receiveBook, .receiveLantern:
            return [Color(red: 0.12, green: 0.1, blue: 0.08), Color(red: 0.08, green: 0.06, blue: 0.04)]
        case .stormBuilds:
            return [Color(red: 0.08, green: 0.06, blue: 0.1), Color(red: 0.05, green: 0.03, blue: 0.08)]
        case .departure:
            return [Color(red: 0.1, green: 0.08, blue: 0.15), Color(red: 0.05, green: 0.03, blue: 0.1)]
        }
    }
    
    // MARK: - Storm
    
    private var stormOverlay: some View {
        ZStack {
            // Rain streaks
            if stormIntensity > 0.3 {
                RainEffect(intensity: stormIntensity)
            }
            
            // Lightning flash
            if stormIntensity > 0.7 {
                Color.white
                    .opacity(stormIntensity > 0.9 ? 0.3 : 0)
                    .animation(.easeOut(duration: 0.1), value: stormIntensity)
            }
            
            // Darkening vignette
            RadialGradient(
                colors: [.clear, .black.opacity(stormIntensity * 0.5)],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    // MARK: - Shopkeeper
    
    private var shopkeeperImage: some View {
        VStack {
            Image("portrait_shopkeeper")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .shadow(color: .black.opacity(0.5), radius: 20)
        }
        .padding(.bottom, 100)
    }
    
    // MARK: - Lantern Effect
    
    private var lanternEffect: some View {
        ZStack {
            // Warm glow from bottom
            RadialGradient(
                colors: [
                    Color.orange.opacity(0.4),
                    Color.yellow.opacity(0.2),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 50,
                endRadius: 300
            )
            
            // Pulsing inner glow
            Circle()
                .fill(Color.orange.opacity(0.6))
                .frame(width: 60, height: 60)
                .blur(radius: 30)
                .offset(y: 200)
                .modifier(PulseModifier())
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .transition(.opacity)
    }
    
    // MARK: - Dialogue Box
    
    private var dialogueBox: some View {
        VStack(spacing: 0) {
            // Speaker name (if applicable)
            if let speaker = currentSpeaker, !speaker.isEmpty {
                HStack {
                    Text(speaker)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.7))
                        )
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            
            // Dialogue text
            HStack(alignment: .top, spacing: 16) {
                Text(displayedText)
                    .font(isNarration ? .body.italic() : .body)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if showTapHint {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(20)
            .frame(minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Scene Content
    
    private var currentSpeaker: String? {
        guard currentLineIndex < currentPhaseLines.count else { return nil }
        return currentPhaseLines[currentLineIndex].speaker
    }
    
    private var isNarration: Bool {
        guard currentLineIndex < currentPhaseLines.count else { return false }
        return currentPhaseLines[currentLineIndex].isNarration
    }
    
    private var currentPhaseLines: [SceneLine] {
        switch scenePhase {
        case .approach:
            return [
                SceneLine(text: "Moving is hard.", isNarration: true),
                SceneLine(text: "Everything you knew is somewhere else now. Your friends. Your room. The way the light came through your window in the morning.", isNarration: true),
                SceneLine(text: "Your parents say you'll make new friends. That you'll love it here eventually.", isNarration: true),
                SceneLine(text: "When you're young, 'eventually' feels like forever.", isNarration: true),
                SceneLine(text: "So you walk. Because walking is better than unpacking. Better than pretending you're okay.", isNarration: true),
                SceneLine(text: "And sometimes, when you're not looking for anything at all...", isNarration: true),
                SceneLine(text: "...you find exactly what you need.", isNarration: true),
            ]
        case .enterShop:
            return [
                SceneLine(text: "The door creaks. A bell chimes — but the sound is strange. Almost musical. Like it's welcoming you specifically.", isNarration: true),
                SceneLine(text: "The shop is cramped and wonderful. Bookshelves reach to the ceiling. The smell is old paper, candle wax, and something that reminds you of campfires.", isNarration: true),
                SceneLine(text: "No one seems to be here.", isNarration: true),
            ]
        case .meetShopkeeper:
            return [
                SceneLine(speaker: "Shopkeeper", text: "I'm always here. Though 'here' is somewhat flexible."),
                SceneLine(text: "An old man emerges from between the shelves. He's tall and thin, with a long white beard and eyes that seem to hold secrets.", isNarration: true),
                SceneLine(speaker: "Shopkeeper", text: "Ah. There you are. I was beginning to wonder."),
                SceneLine(speaker: "Shopkeeper", text: "Most people walk by this place a thousand times and never see it. But you saw it on your first day."),
                SceneLine(speaker: "Shopkeeper", text: "That's not an accident."),
            ]
        case .receiveBook:
            return [
                SceneLine(text: "The shopkeeper moves toward a particular shelf. His fingers brush spines as he walks, and you'd swear the books lean toward his touch.", isNarration: true),
                SceneLine(speaker: "Shopkeeper", text: "You're new here. I can tell. You have that look — the one that says 'I don't belong anywhere yet.'"),
                SceneLine(speaker: "Shopkeeper", text: "But here's a secret: nobody belongs anywhere at first. Belonging is something you build. Story by story. Dream by dream."),
                SceneLine(text: "He holds out a book. It's old. Leather-bound. The cover shows a sword thrust into a stone.", isNarration: true),
                SceneLine(speaker: "Shopkeeper", text: "This one's been waiting for you. Has been for quite some time."),
            ]
        case .receiveLantern:
            return [
                SceneLine(text: "You take the book. It's heavier than it looks. And warm — like it's been sitting in sunlight.", isNarration: true),
                SceneLine(text: "The shopkeeper reaches behind the counter and produces something else: a small brass lantern. Old-fashioned. Beautiful.", isNarration: true),
                SceneLine(speaker: "Shopkeeper", text: "You'll need this too. For finding your way. Dreams can be dark places."),
                SceneLine(text: "The moment your fingers close around it, the flame sparks to life — by itself.", isNarration: true),
                SceneLine(speaker: "Shopkeeper", text: "Ah. Good. It likes you."),
            ]
        case .stormBuilds:
            return [
                SceneLine(text: "Outside the window, the light changes. Clouds roll in with unnatural speed. Thunder shakes the windowpanes.", isNarration: true),
                SceneLine(speaker: "Shopkeeper", text: "You should go home now. Read the first chapter before bed tonight. Light the lantern when you do."),
                SceneLine(speaker: "Shopkeeper", text: "And remember: in dreams, nothing is quite what it seems. Not even you."),
            ]
        case .departure:
            return [
                SceneLine(text: "He turns and disappears between the shelves. When you blink, he's gone.", isNarration: true),
                SceneLine(text: "Thunder rolls again. The lantern glows steadily in your hand.", isNarration: true),
                SceneLine(text: "You run home through the rain, the book clutched to your chest.", isNarration: true),
            ]
        }
    }
    
    // MARK: - Scene Flow
    
    private func startScene() {
        startTypingCurrentLine()
    }
    
    private func startTypingCurrentLine() {
        guard currentLineIndex < currentPhaseLines.count else {
            advancePhase()
            return
        }
        
        let line = currentPhaseLines[currentLineIndex]
        displayedText = ""
        isTyping = true
        showTapHint = false
        
        let characters = Array(line.text)
        
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed * Double(index)) {
                if isTyping {
                    displayedText.append(character)
                    
                    if index == characters.count - 1 {
                        isTyping = false
                        withAnimation(.easeIn(duration: 0.3)) {
                            showTapHint = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleTap() {
        if isTyping {
            // Skip to full text
            isTyping = false
            displayedText = currentPhaseLines[currentLineIndex].text
            withAnimation(.easeIn(duration: 0.3)) {
                showTapHint = true
            }
        } else {
            // Advance to next line
            currentLineIndex += 1
            if currentLineIndex < currentPhaseLines.count {
                startTypingCurrentLine()
            } else {
                advancePhase()
            }
        }
    }
    
    private func advancePhase() {
        currentLineIndex = 0
        
        switch scenePhase {
        case .approach:
            scenePhase = .enterShop
        case .enterShop:
            scenePhase = .meetShopkeeper
            withAnimation(.easeIn(duration: 0.5)) {
                shopkeeperVisible = true
            }
        case .meetShopkeeper:
            scenePhase = .receiveBook
        case .receiveBook:
            scenePhase = .receiveLantern
            withAnimation(.easeIn(duration: 0.8)) {
                lanternGlowing = true
            }
        case .receiveLantern:
            scenePhase = .stormBuilds
            withAnimation(.easeIn(duration: 1.5)) {
                stormIntensity = 0.8
            }
        case .stormBuilds:
            scenePhase = .departure
            withAnimation(.easeIn(duration: 0.3)) {
                shopkeeperVisible = false
            }
        case .departure:
            onComplete()
            return
        }
        
        startTypingCurrentLine()
    }
}

// MARK: - Scene Phase

private enum BookstorePhase {
    case approach
    case enterShop
    case meetShopkeeper
    case receiveBook
    case receiveLantern
    case stormBuilds
    case departure
    
    var isInside: Bool {
        switch self {
        case .approach: return false
        default: return true
        }
    }
}

// MARK: - Scene Line

private struct SceneLine {
    let speaker: String?
    let text: String
    let isNarration: Bool
    
    init(speaker: String? = nil, text: String, isNarration: Bool = false) {
        self.speaker = speaker
        self.text = text
        self.isNarration = isNarration
    }
}

// MARK: - Effects

private struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 0.9)
            .opacity(isPulsing ? 0.8 : 0.5)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

private struct RainEffect: View {
    let intensity: Double
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for _ in 0..<Int(intensity * 100) {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let length = Double.random(in: 10...30) * intensity
                    
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x - 2, y: y + length))
                    
                    context.stroke(
                        path,
                        with: .color(.white.opacity(0.3)),
                        lineWidth: 1
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BookstoreSceneView(onComplete: {})
}
