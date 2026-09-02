import SwiftUI

/// The roster: every hero the dreamer has met. Tap to seat up to three in
/// the party; the first seat leads and lends the party its passive.
struct PartySelectView: View {
    let coordinator: CampaignCoordinator
    let onDone: () -> Void

    @State private var focusedHeroID: Hero.ID?

    private var focusedHero: Hero? {
        let heroes = coordinator.unlockedHeroes
        if let id = focusedHeroID, let hero = heroes.first(where: { $0.id == id }) { return hero }
        return coordinator.party.first ?? heroes.first
    }

    private let columns = [GridItem(.adaptive(minimum: 84), spacing: 10)]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDone() }

            HStack(spacing: 14) {
                rosterGrid
                    .frame(maxWidth: .infinity)

                detailPanel
                    .frame(width: 250)
            }
            .padding(16)
            .frame(maxWidth: 720, maxHeight: 360)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.09, green: 0.08, blue: 0.19)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.14), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 24, y: 8)
            .padding(24)
        }
    }

    // MARK: - Roster

    private var rosterGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Party")
                    .font(.system(size: 18, weight: .bold))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(coordinator.party.count)/\(CampaignCoordinator.partySize) seated")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(coordinator.unlockedHeroes) { hero in
                        heroTile(hero)
                    }
                }
                .padding(.vertical, 2)
            }

            Text("Tap a hero to seat or unseat them. The first seat leads the party.")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private func heroTile(_ hero: Hero) -> some View {
        let seat = coordinator.party.firstIndex { $0.id == hero.id }
        let isFocused = focusedHero?.id == hero.id
        return Button {
            focusedHeroID = hero.id
            coordinator.toggleHero(hero)
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(ArtCatalog.heroPortrait(for: hero))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(
                                seat != nil ? DreamTheme.gold : .white.opacity(0.25),
                                lineWidth: seat != nil ? 2.5 : 1
                            )
                        )
                        .shadow(color: DreamTheme.gold.opacity(seat != nil ? 0.45 : 0), radius: 10)
                    if let seat {
                        Text("\(seat + 1)")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.black)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(DreamTheme.gold))
                            .offset(x: 4, y: -2)
                    }
                }
                Text(hero.name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .padding(6)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFocused ? .white.opacity(0.08) : .clear)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailPanel: some View {
        if let hero = focusedHero {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    Image(ArtCatalog.heroPortrait(for: hero))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hero.name)
                            .font(.system(size: 16, weight: .bold))
                            .fontDesign(.serif)
                            .foregroundStyle(.white)
                        Text(hero.title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DreamTheme.gold.opacity(0.9))
                            .lineLimit(2)
                    }
                }

                HStack(spacing: 6) {
                    Label("\(hero.maxHealth) HP", systemImage: "heart.fill")
                        .foregroundStyle(DreamTheme.healthGreen)
                    Label("\(CardCatalog.pool(for: hero).count) cards", systemImage: "square.stack.fill")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .font(.system(size: 10, weight: .semibold))

                VStack(alignment: .leading, spacing: 3) {
                    Text(hero.passive.name.uppercased())
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(1.2)
                        .foregroundStyle(DreamTheme.gold)
                    Text(hero.passive.text)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))

                Text(hero.storyText)
                    .font(.system(size: 10))
                    .italic()
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(4)

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    if coordinator.isInParty(hero), coordinator.party.first?.id != hero.id {
                        Button {
                            coordinator.makeLead(hero)
                        } label: {
                            Text("Make lead")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(DreamTheme.gold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().stroke(DreamTheme.gold.opacity(0.6), lineWidth: 1))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    Spacer()
                    Button {
                        onDone()
                    } label: {
                        Text("Done")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(DreamTheme.gold))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        } else {
            Text("No heroes yet.")
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PartySelectView(coordinator: CampaignCoordinator()) {}
}
