import SwiftUI

struct MoviePosterCard: View {
    let movie: Movie
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Real poster image
            Image(movie.posterImageName)
                .resizable()
                .scaledToFill()

            // Subtle bottom gradient overlay so the card bleeds into the bg
            LinearGradient(
                colors: [.clear, .black.opacity(0.35)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Play badge top-right
            ZStack {
                Circle()
                    .fill(.white.opacity(0.88))
                    .frame(width: 38, height: 38)
                Image(systemName: "play.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                    .offset(x: 1)
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: movie.dominantColor.opacity(0.6), radius: 24, x: 0, y: 12)
        .scaleEffect(isSelected ? 1.0 : 0.88)
        .opacity(isSelected ? 1.0 : 0.55)
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: isSelected)
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
