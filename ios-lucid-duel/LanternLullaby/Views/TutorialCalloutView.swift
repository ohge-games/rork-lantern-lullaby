import SwiftUI

/// A storybook callout pinned near the thing it explains. Steps that wait
/// for a tap carry a "Got it" button; steps that wait for an action tell
/// the player to try it and stay until they do.
struct TutorialCalloutView: View {
    let step: TutorialStep
    let onTap: () -> Void

    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let placement = placement(in: size)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(DreamTheme.gold)
                    Text(step.title)
                        .font(.system(size: 13, weight: .bold))
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                }

                Text(step.text)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer()
                    if step.advance == .tap {
                        Button {
                            onTap()
                        } label: {
                            Text("Got it")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(DreamTheme.gold))
                        }
                        .buttonStyle(PressableButtonStyle())
                    } else {
                        Text(actionHint)
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(DreamTheme.gold.opacity(0.9))
                    }
                }
            }
            .padding(12)
            .frame(width: 290)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.09, green: 0.08, blue: 0.20).opacity(0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(DreamTheme.gold.opacity(0.55), lineWidth: 1.5)
            )
            .overlay(alignment: placement.pointerAlignment) {
                pointer(direction: placement.pointer)
            }
            .shadow(color: DreamTheme.gold.opacity(0.25), radius: 16)
            .shadow(color: .black.opacity(0.5), radius: 12, y: 4)
            .position(x: size.width * placement.x, y: size.height * placement.y)
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { appeared = true }
        }
        .id(step.id)
    }

    private var actionHint: String {
        switch step.advance {
        case .cardPlayed: return "TRY IT — PLAY A CARD"
        case .turnEnded: return "TRY IT — END YOUR TURN"
        case .enemyTurnDone: return "WATCH THE ENEMY ACT"
        case .tap: return ""
        }
    }

    private enum Pointer {
        case down, up, left, right, none
    }

    private struct Placement {
        let x: CGFloat
        let y: CGFloat
        let pointer: Pointer
        var pointerAlignment: Alignment {
            switch pointer {
            case .down: return .bottom
            case .up: return .top
            case .left: return .leading
            case .right: return .trailing
            case .none: return .center
            }
        }
    }

    /// Callout positions in unit coordinates, matched to the battle layout:
    /// lantern and End Turn bottom-right, hand bottom-center, party left,
    /// enemies right.
    private func placement(in size: CGSize) -> Placement {
        switch step.anchor {
        case .lantern: return Placement(x: 0.74, y: 0.38, pointer: .down)
        case .endTurn: return Placement(x: 0.60, y: 0.80, pointer: .right)
        case .hand: return Placement(x: 0.5, y: 0.36, pointer: .down)
        case .enemy: return Placement(x: 0.54, y: 0.24, pointer: .right)
        case .hero: return Placement(x: 0.46, y: 0.24, pointer: .left)
        case .center: return Placement(x: 0.5, y: 0.42, pointer: .none)
        }
    }

    @ViewBuilder
    private func pointer(direction: Pointer) -> some View {
        switch direction {
        case .none:
            EmptyView()
        default:
            Triangle()
                .fill(DreamTheme.gold.opacity(0.9))
                .frame(width: 14, height: 9)
                .rotationEffect(rotation(for: direction))
                .offset(pointerOffset(for: direction))
        }
    }

    private func rotation(for direction: Pointer) -> Angle {
        switch direction {
        case .down: return .degrees(180)
        case .up: return .degrees(0)
        case .left: return .degrees(-90)
        case .right: return .degrees(90)
        case .none: return .degrees(0)
        }
    }

    private func pointerOffset(for direction: Pointer) -> CGSize {
        switch direction {
        case .down: return CGSize(width: 0, height: 9)
        case .up: return CGSize(width: 0, height: -9)
        case .left: return CGSize(width: -11, height: 0)
        case .right: return CGSize(width: 11, height: 0)
        case .none: return .zero
        }
    }
}

/// An upward-pointing triangle used for callout pointers.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
