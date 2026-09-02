import SwiftUI

/// Plays a sequence of story scenes back to back, then hands off.
struct PrologueView: View {
    let scenes: [StoryScene]
    let onComplete: () -> Void

    @State private var index = 0

    var body: some View {
        ZStack {
            DreamBackground(zone: .balanced)

            if index < scenes.count {
                StorySceneView(scene: scenes[index]) {
                    advance()
                }
                .id(index)
                .transition(.opacity)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        onComplete()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.black.opacity(0.35)))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: index)
    }

    private func advance() {
        if index + 1 < scenes.count {
            index += 1
        } else {
            onComplete()
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PrologueView(scenes: NarrativeCatalogBook1.prologueScenes) {}
}
