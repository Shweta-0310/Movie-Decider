import SwiftUI

struct MoviePosterCard: View {
    let movie: Movie
    let isSelected: Bool
    // Namespace passed from ContentView for the hero transition.
    // Optional so the preview compiles without a namespace.
    var namespace: Namespace.ID? = nil
    // When the detail is open for THIS card, set to false so the card
    // becomes invisible (but stays in the view tree — critical for matchedGeometryEffect).
    var isSourceOfTruth: Bool = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Poster image
            Image(movie.posterImageName)
                .resizable()
                .scaledToFill()

            // Subtle bottom gradient so the card edge fades into the background
            LinearGradient(
                colors: [.clear, .black.opacity(0.35)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        // matchedGeometryEffect must come AFTER clipShape so the geometry
        // frame matches the clipped (rounded) bounds, not the raw image bounds.
        .modifier(HeroModifier(movie: movie, namespace: namespace, isSource: isSourceOfTruth))
        .shadow(color: movie.dominantColor.opacity(0.6), radius: 24, x: 0, y: 12)
        .scaleEffect(isSelected ? 1.0 : 0.88)
        // When isSourceOfTruth is false the detail view is open for this card;
        // hide it with opacity (never remove it — the geometry source must stay in the tree).
        .opacity(isSourceOfTruth ? (isSelected ? 1.0 : 0.55) : 0)
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: isSelected)
    }
}

/// Applies matchedGeometryEffect only when a namespace is provided.
/// Using a ViewModifier avoids the need for AnyView or conditional type erasure.
private struct HeroModifier: ViewModifier {
    let movie: Movie
    let namespace: Namespace.ID?
    let isSource: Bool

    func body(content: Content) -> some View {
        if let ns = namespace {
            content.matchedGeometryEffect(
                id: "poster-\(movie.id)",
                in: ns,
                isSource: isSource
            )
        } else {
            content
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MoviePosterCard(movie: Movie.sampleMovies[0], isSelected: true)
            .frame(width: 280, height: 400)
            .padding()
    }
}
