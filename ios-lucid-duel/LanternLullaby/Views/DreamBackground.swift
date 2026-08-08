import SwiftUI

/// Atmospheric backdrop that lives with the duel: the painted misty
/// forest of The First Nightmare sits beneath a zone-tinted veil, so the
/// stage keeps its picture-book texture while drifting toward danger is
/// felt in color before it's read.
struct DreamBackground: View {
    var zone: LucidityZone = .balanced

    @State private var drift = false

    var body: some View {
        ZStack {
            // Painted arena page, anchored by a Color so the .fill image
            // can't distort layout.
            Color(red: 0.07, green: 0.06, blue: 0.16)
                .overlay {
                    Image("enchanted_forest_night")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()

            // Zone-tinted veil over the painting — light enough that the
            // forest reads clearly behind the full-body characters.
            LinearGradient(
                colors: [zone.ambientTop.opacity(0.45), zone.ambientBottom.opacity(0.32)],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [zone.color.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .offset(x: -120, y: drift ? -190 : -130)
                .blur(radius: 24)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            zone.color.opacity(0.16),
                            Color(red: 0.15, green: 0.35, blue: 0.5).opacity(0.14),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 380, height: 380)
                .offset(x: 150, y: drift ? 250 : 320)
                .blur(radius: 24)

            stars
        }
        .animation(.easeInOut(duration: 1.6), value: zone)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }

    private var stars: some View {
        GeometryReader { geo in
            ForEach(0..<26, id: \.self) { index in
                let fx = (Double(index) * 0.37 + 0.05).truncatingRemainder(dividingBy: 1)
                let fy = (Double(index) * 0.61 + 0.13).truncatingRemainder(dividingBy: 1)
                Circle()
                    .fill(.white.opacity(0.10 + 0.07 * Double(index % 3)))
                    .frame(width: index % 4 == 0 ? 2.5 : 1.5)
                    .position(x: fx * geo.size.width, y: fy * geo.size.height)
            }
        }
        .allowsHitTesting(false)
    }
}
