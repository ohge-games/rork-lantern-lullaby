import SwiftUI

/// The one thing to try next time, on every losing card.
///
/// A loss that only says "you lost" teaches nothing, and this is a game for
/// someone who is ten. One sentence, phrased as an action, in the same
/// storybook voice as everything else.
struct DefeatAdviceView: View {
    let advice: String
    var tint: Color = DreamTheme.gold

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 11))
                .foregroundStyle(tint)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text("TRY THIS")
                    .font(.system(size: 8, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(tint.opacity(0.9))
                Text(advice)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: 380, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.35)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tint.opacity(0.3), lineWidth: 1))
    }
}
