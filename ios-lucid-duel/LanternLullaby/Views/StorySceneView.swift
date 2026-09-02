import SwiftUI

// MARK: - Story Scene View
// Full-screen narrative cutscene shown between stages

struct StorySceneView: View {
    let scene: StoryScene
    let onComplete: () -> Void
    
    @State private var currentLineIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var showTapHint = false
    
    private let typingSpeed: Double = 0.03  // Seconds per character
    
    private var currentLine: DialogueLine? {
        guard currentLineIndex < scene.lines.count else { return nil }
        return scene.lines[currentLineIndex]
    }
    
    private var isLastLine: Bool {
        currentLineIndex >= scene.lines.count - 1
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            // Content
            VStack {
                Spacer()
                
                // Dialogue area (bottom third of screen)
                dialogueArea
            }
        }
        .onAppear {
            startTypingCurrentLine()
        }
        .onTapGesture {
            handleTap()
        }
    }
    
    // MARK: - Background Layer
    
    @ViewBuilder
    private var backgroundLayer: some View {
        if let bgImage = scene.backgroundImage {
            // Anchored by a Color so the .fill image can't distort layout.
            Color(red: 0.07, green: 0.06, blue: 0.16)
                .overlay {
                    Image(bgImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.15), .black.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        } else {
            // Default dreamy gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.15, blue: 0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Dialogue Area
    
    private var dialogueArea: some View {
        VStack(spacing: 0) {
            // Semi-transparent dialogue box
            HStack(alignment: .top, spacing: 16) {
                // Portrait (left side)
                if let line = currentLine, !line.speakerPortrait.isEmpty {
                    portraitView(for: line)
                }
                
                // Text area (right side, full width)
                VStack(alignment: .leading, spacing: 8) {
                    // Speaker name
                    if let line = currentLine, !line.speakerName.isEmpty {
                        Text(line.speakerName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Dialogue text
                    if let line = currentLine {
                        Text(displayedText)
                            .font(line.isPlayerThought ? .body.italic() : .body)
                            .foregroundColor(line.isPlayerThought ? .white.opacity(0.9) : .white)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer(minLength: 8)
                    
                    // Tap hint
                    if showTapHint {
                        HStack {
                            Spacer()
                            Text(isLastLine ? "Tap to continue" : "Tap for next")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Portrait View
    
    private func portraitView(for line: DialogueLine) -> some View {
        ZStack {
            // Portrait background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            line.isPlayerThought 
                                ? Color.blue.opacity(0.5) 
                                : Color.yellow.opacity(0.5),
                            lineWidth: 2
                        )
                )
            
            // Portrait image
            Image(line.speakerPortrait)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(width: 110, height: 120)
    }
    
    // MARK: - Typing Animation
    
    private func startTypingCurrentLine() {
        guard let line = currentLine else {
            onComplete()
            return
        }
        
        displayedText = ""
        isTyping = true
        showTapHint = false
        
        let characters = Array(line.text)
        
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed * Double(index)) {
                if isTyping {
                    displayedText.append(character)
                    
                    // Show tap hint when done
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
            displayedText = currentLine?.text ?? ""
            withAnimation(.easeIn(duration: 0.3)) {
                showTapHint = true
            }
        } else {
            // Advance to next line
            if isLastLine {
                onComplete()
            } else {
                currentLineIndex += 1
                startTypingCurrentLine()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StorySceneView(
        scene: StoryScene(
            backgroundImage: nil,
            lines: [
                .narrator("The forest grows dark around you."),
                .hero(
                    CardCatalog.HeroIDs.wart,
                    name: "Wart",
                    portrait: "portrait_wart",
                    text: "I don't like this. The wolves are acting strange tonight."
                ),
                .mcThought("Something feels wrong. The lantern flickers in my hand.")
            ]
        ),
        onComplete: {}
    )
}
