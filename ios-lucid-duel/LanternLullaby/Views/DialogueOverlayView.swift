import SwiftUI

// MARK: - Dialogue Overlay View
// In-battle dialogue that appears in the card zone area
// Portrait on left, speech bubble spanning right

struct DialogueOverlayView: View {
    let dialogue: BattleDialogue
    let onDismiss: () -> Void

    @State private var currentLineIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var isVisible = false
    /// The typing task for the current line; cancelled on every line change.
    @State private var typingTask: Task<Void, Never>?

    private let typingSpeed: Double = 0.025

    private var currentLine: DialogueLine? {
        guard currentLineIndex < dialogue.lines.count else { return nil }
        return dialogue.lines[currentLineIndex]
    }

    private var isLastLine: Bool {
        currentLineIndex >= dialogue.lines.count - 1
    }

    var body: some View {
        VStack {
            Spacer()

            // Dialogue container - same height as card zone
            dialogueContainer
                .frame(height: 160)
                .offset(y: isVisible ? 0 : 200)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
            startTypingCurrentLine()
        }
        .onTapGesture {
            handleTap()
        }
    }

    // MARK: - Dialogue Container

    private var dialogueContainer: some View {
        HStack(alignment: .center, spacing: 0) {
            // Portrait area (left)
            portraitArea
                .frame(width: 120)

            // Speech bubble (right, spanning remaining width)
            speechBubble
        }
        .background(dialogueBackground)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Portrait Area

    private var portraitArea: some View {
        ZStack {
            // Character portrait
            if let line = currentLine {
                VStack(spacing: 4) {
                    // Portrait frame
                    ZStack {
                        // Glow effect based on speaker type
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        portraitGlowColor(for: line).opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 100, height: 100)

                        // Portrait image
                        if !line.speakerPortrait.isEmpty {
                            Image(line.speakerPortrait)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(portraitBorderColor(for: line), lineWidth: 3)
                                )
                                .shadow(color: portraitGlowColor(for: line).opacity(0.5), radius: 8)
                        } else {
                            // Narrator - no portrait, just icon
                            Image(systemName: "book.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    // Speaker name badge
                    if !line.speakerName.isEmpty && !line.isPlayerThought {
                        Text(line.speakerName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.6))
                            )
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Speech Bubble

    private var speechBubble: some View {
        ZStack(alignment: .leading) {
            // Bubble background with pointer
            SpeechBubbleShape()
                .fill(Color.black.opacity(0.85))
                .overlay(
                    SpeechBubbleShape()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                if let line = currentLine {
                    // Internal thought indicator
                    if line.isPlayerThought {
                        HStack(spacing: 4) {
                            Image(systemName: "thought.bubble")
                                .font(.caption2)
                            Text("(thinking)")
                                .font(.caption2)
                        }
                        .foregroundColor(.white.opacity(0.5))
                    }

                    // Dialogue text
                    Text(displayedText)
                        .font(line.isPlayerThought ? .body.italic() : .body)
                        .foregroundColor(.white)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                // Tap indicator
                HStack {
                    Spacer()
                    if !isTyping {
                        HStack(spacing: 4) {
                            Text(isLastLine ? "Tap to continue" : "▼")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Background

    private var dialogueBackground: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    // MARK: - Helper Functions

    private func portraitGlowColor(for line: DialogueLine) -> Color {
        if line.isPlayerThought {
            return .blue
        }
        // Could extend to differentiate heroes vs villains
        return .yellow
    }

    private func portraitBorderColor(for line: DialogueLine) -> Color {
        if line.isPlayerThought {
            return .blue.opacity(0.7)
        }
        return .yellow.opacity(0.7)
    }

    // MARK: - Typing Animation

    private func startTypingCurrentLine() {
        typingTask?.cancel()
        guard let line = currentLine else {
            dismiss()
            return
        }

        displayedText = ""
        isTyping = true

        let characters = Array(line.text)
        let delay = typingSpeed
        typingTask = Task { @MainActor in
            var revealed = ""
            for character in characters {
                try? await Task.sleep(for: .seconds(delay))
                if Task.isCancelled { return }
                revealed.append(character)
                displayedText = revealed
            }
            isTyping = false
        }
    }

    private func handleTap() {
        if isTyping {
            // Skip to full text
            typingTask?.cancel()
            isTyping = false
            displayedText = currentLine?.text ?? ""
        } else {
            // Advance to next line or dismiss
            if isLastLine {
                dismiss()
            } else {
                currentLineIndex += 1
                startTypingCurrentLine()
            }
        }
    }

    private func dismiss() {
        typingTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

// MARK: - Speech Bubble Shape

struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cornerRadius: CGFloat = 12
        let pointerWidth: CGFloat = 15
        let pointerHeight: CGFloat = 12
        let pointerOffset: CGFloat = 30  // From left edge

        // Start at top-left, after corner
        path.move(to: CGPoint(x: cornerRadius, y: 0))

        // Top edge
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))

        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cornerRadius),
            control: CGPoint(x: rect.width, y: 0)
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))

        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width - cornerRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )

        // Bottom edge (no pointer on this side - pointer points left)
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))

        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - cornerRadius),
            control: CGPoint(x: 0, y: rect.height)
        )

        // Left edge with pointer
        path.addLine(to: CGPoint(x: 0, y: pointerOffset + pointerHeight))

        // Pointer (pointing left toward portrait)
        path.addLine(to: CGPoint(x: -pointerWidth, y: pointerOffset + pointerHeight / 2))
        path.addLine(to: CGPoint(x: 0, y: pointerOffset))

        // Continue left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))

        // Top-left corner
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray

        DialogueOverlayView(
            dialogue: BattleDialogue(
                trigger: .battleStart,
                lines: [
                    .hero(
                        CardCatalog.HeroIDs.lancelot,
                        name: "Lancelot",
                        portrait: "portrait_lancelot",
                        text: "You fight well, young dreamer. Better than most knights I've known."
                    ),
                    .mcThought("A knight. A real knight. And he's following me.")
                ]
            ),
            onDismiss: {}
        )
    }
    .ignoresSafeArea()
}
