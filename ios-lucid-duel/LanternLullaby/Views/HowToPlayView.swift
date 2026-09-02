import SwiftUI

/// The rules page, reachable from the campaign book at any time.
struct HowToPlayView: View {
    let onDone: () -> Void

    private struct RuleSection: Identifiable {
        let id: String
        let icon: String
        let title: String
        let body: String
    }

    private let sections: [RuleSection] = [
        RuleSection(
            id: "lantern",
            icon: "flame.fill",
            title: "The lantern is your Lucidity",
            body: "The flame runs from 0 to 100 and starts at 50. Playing a card brightens it by the +number on the card. If it reaches 100 you jolt awake; if it gutters to 0 you sink into Deep Sleep. Both end the dream — even on the killing blow."
        ),
        RuleSection(
            id: "zones",
            icon: "circle.lefthalf.filled",
            title: "Zones",
            body: "Vivid (66–85): attacks deal 20% more. Drifting (16–35): shields and heals are 20% stronger. Balanced (36–65) is safe but plain. Relax cards (Deep Breath, Mental Shift) dim the flame; most other cards brighten it. Each turn the lantern drifts 2 toward the middle."
        ),
        RuleSection(
            id: "cards",
            icon: "rectangle.portrait.on.rectangle.portrait.angled.fill",
            title: "Playing cards",
            body: "Touch a card and draw its thread to a target. Attacks go to an enemy. Shields, heals and Step Forward go to one of your heroes. Cards that need no target — Relax and card draw — are played by simply pulling them up. Cards marked Choice let you pick a path after you drop them. Play as many as you like, then End Turn."
        ),
        RuleSection(
            id: "strain",
            icon: "flame.fill",
            title: "Focus Strain",
            body: "Leaning on one kind of card wears the dream thin. The second card of a type you play in a turn costs +1 Lucidity, the third +2, and so on — attacks, defense and utility each strain on their own. The card shows its real cost, so a varied turn is always cheaper than a mono turn."
        ),
        RuleSection(
            id: "party",
            icon: "person.3.fill",
            title: "Your party",
            body: "You open with 7 cards and never start a turn with fewer than 4. Up to three heroes fight together with one shared hand and shield. Seat 1 leads: enemies aim at the lead and only the lead's passive is active. Set the order before each dream; in battle only a card like Step Forward can change it. If the lead falls, the next hero steps up. You lose when nobody is standing."
        ),
        RuleSection(
            id: "enemies",
            icon: "eye.fill",
            title: "Reading enemies",
            body: "The chip above an enemy shows exactly what it will do on its turn: a red number is damage, a blue number is shield, gold is a buff. Every living enemy acts. Some stages come in waves — clear one and the next arrives."
        ),
        RuleSection(
            id: "book",
            icon: "book.fill",
            title: "The book",
            body: "Each chapter has ten pages. Clear a page to open the next; clear a chapter's boss to open the next chapter. Heroes join at story moments and take a seat in your party if there is room."
        ),
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { onDone() }

            VStack(spacing: 0) {
                HStack {
                    Text("How to Play")
                        .font(.system(size: 20, weight: .bold))
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        onDone()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(.white.opacity(0.08)))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(sections) { section in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 15))
                                    .foregroundStyle(DreamTheme.gold)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(section.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(section.body)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.white.opacity(0.78))
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.05)))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: 640, maxHeight: 380)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.09, green: 0.08, blue: 0.19)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.14), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 24, y: 8)
            .padding(24)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    HowToPlayView {}
}
