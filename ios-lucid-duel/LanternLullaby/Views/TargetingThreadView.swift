import SwiftUI

/// The glowing thread that runs from a held card to the finger while a
/// card is being aimed. Drawn in the screen's coordinate space above the
/// whole battle so it can reach any target; gold when a valid target sits
/// under the finger, pale while it is still searching.
struct TargetingThreadView: View {
    let from: CGPoint
    let to: CGPoint
    let isOnTarget: Bool

    var body: some View {
        GeometryReader { geo in
            let origin = geo.frame(in: .global).origin
            let start = CGPoint(x: from.x - origin.x, y: from.y - origin.y)
            let end = CGPoint(x: to.x - origin.x, y: to.y - origin.y)
            let color = isOnTarget ? DreamTheme.gold : Color.white
            let path = threadPath(from: start, to: end)

            ZStack {
                // Soft glow beneath the thread.
                path
                    .stroke(color.opacity(isOnTarget ? 0.55 : 0.25), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .blur(radius: 8)

                // The thread itself.
                path
                    .stroke(
                        color.opacity(isOnTarget ? 0.95 : 0.6),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: isOnTarget ? [] : [8, 6])
                    )

                // The knot at the finger.
                Circle()
                    .fill(color)
                    .frame(width: isOnTarget ? 16 : 10, height: isOnTarget ? 16 : 10)
                    .shadow(color: color.opacity(0.8), radius: isOnTarget ? 12 : 6)
                    .position(end)

                Circle()
                    .stroke(color.opacity(0.6), lineWidth: 1.5)
                    .frame(width: isOnTarget ? 34 : 22, height: isOnTarget ? 34 : 22)
                    .position(end)

                // A small ember where the thread leaves the card.
                Circle()
                    .fill(color.opacity(0.9))
                    .frame(width: 6, height: 6)
                    .position(start)
            }
            .animation(.easeOut(duration: 0.15), value: isOnTarget)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// A gentle arc that rises out of the card before settling on the finger.
    private func threadPath(from start: CGPoint, to end: CGPoint) -> Path {
        var path = Path()
        path.move(to: start)
        let lift = max(40, abs(end.x - start.x) * 0.25)
        let control = CGPoint(x: (start.x + end.x) / 2, y: min(start.y, end.y) - lift)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}
