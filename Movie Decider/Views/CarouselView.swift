import SwiftUI

struct CarouselView: View {
    let movies: [Movie]
    @Binding var selectedIndex: Int
    @State private var scrolledID: Int?

    var body: some View {
        GeometryReader { proxy in
            let peekAmount: CGFloat = 44
            let spacing: CGFloat = 12
            let cardWidth  = proxy.size.width - peekAmount * 2
            let cardHeight = cardWidth * 1.5   // true 2:3 poster ratio

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                        MoviePosterCard(
                            movie: movie,
                            isSelected: (scrolledID ?? selectedIndex) == index
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            // Creates the peek inset on both sides without blank padding views
            .contentMargins(.horizontal, peekAmount, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .onChange(of: scrolledID) { _, newValue in
                if let v = newValue { selectedIndex = v }
            }
            .onChange(of: selectedIndex) { _, newValue in
                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                    scrolledID = newValue
                }
            }
            .onAppear { scrolledID = selectedIndex }
            .frame(height: cardHeight + 20)
        }
        .frame(height: (UIScreen.main.bounds.width - 88) * 1.5 + 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CarouselView(movies: Movie.sampleMovies, selectedIndex: .constant(0))
    }
}
