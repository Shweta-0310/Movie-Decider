import SwiftUI

struct MovieDetailSection: View {
    let movie: Movie

    var body: some View {
        VStack(spacing: 10) {
            Text(movie.title)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("\(movie.genre)  •  \(movie.formattedDuration)")
                .font(.subheadline)
                .foregroundColor(.gray)

            RatingsRowView(movie: movie)
                .padding(.horizontal, 24)
                .padding(.top, 6)
        }
        .padding(.horizontal, 24)
        .id(movie.id)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MovieDetailSection(movie: Movie.sampleMovies[0])
    }
}
