import SwiftUI

struct CarouselView: View {
    let movies: [Movie]
    @Binding var selectedIndex: Int

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = proxy.size.width - 96  // 48pt padding each side
            let cardHeight = cardWidth * 1.48      // standard 2:3 poster ratio

            TabView(selection: $selectedIndex) {
                ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                    MoviePosterCard(movie: movie, isSelected: selectedIndex == index)
                        .frame(width: cardWidth, height: cardHeight)
                        .padding(.horizontal, 48)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: cardHeight + 10)
            .overlay(alignment: .bottom) {
                HStack(spacing: 6) {
                    ForEach(movies.indices, id: \.self) { i in
                        Circle()
                            .fill(i == selectedIndex ? Color.white : Color.white.opacity(0.30))
                            .frame(
                                width: i == selectedIndex ? 8 : 5,
                                height: i == selectedIndex ? 8 : 5
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .frame(height: 460)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CarouselView(movies: Movie.sampleMovies, selectedIndex: .constant(0))
    }
}
