import SwiftUI

/// Routes the duel's ending to its emotionally distinct full-screen state:
/// dreamy gold for victory, a harsh white jolt for Awakening, a slow sink
/// into darkness for Deep Sleep, and a plain defeat card for health loss.
struct GameOverOverlayView: View {
    let outcome: GameOutcome
    /// Where the book stands after this win; `nil` outside the campaign.
    var summary: VictorySummary? = nil
    var victorySubtitle: String = "The Nightmare dissolves into morning light."
    /// The page this was, so a loss reads as a place in the book.
    var stageName: String? = nil
    let onRestart: () -> Void
    let onContinue: () -> Void

    private var note: DefeatNote? {
        DefeatNote.note(for: outcome, stageName: stageName)
    }

    var body: some View {
        switch outcome {
        case .victory:
            VictoryOverlayView(summary: summary, subtitle: victorySubtitle, onContinue: onContinue)
        case .lostToLucidity(let zone):
            if zone == .awakening {
                AwakeningOverlayView(note: note, onRetry: onRestart, onLeave: onContinue)
            } else {
                DeepSleepOverlayView(note: note, onRetry: onRestart, onLeave: onContinue)
            }
        case .defeated:
            defeatedCard
        case .ongoing:
            EmptyView()
        }
    }

    /// Health-loss defeat: standard dark card (not a lucidity fail state).
    private var defeatedCard: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(DreamTheme.danger)

                Text(note?.title ?? "Defeated")
                    .font(.largeTitle.bold())
                    .fontDesign(.serif)
                    .foregroundStyle(.white)

                Text(note?.line ?? "The dream overwhelmed your party.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                if let advice = note?.advice {
                    DefeatAdviceView(advice: advice)
                }

                Button {
                    onRestart()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 32)
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
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 8)

                Button {
                    onContinue()
                } label: {
                    Text("Close the book")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.10, green: 0.09, blue: 0.20))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .padding(.horizontal, 32)
        }
    }
}
