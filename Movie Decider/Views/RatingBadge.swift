import SwiftUI

struct RatingBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RatingsRowView: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 0) {
            RatingBadge(value: movie.imdbDisplay, label: "IMBD")
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 1, height: 38)
            RatingBadge(value: "\(movie.rottenTomatoesPercent)%", label: "Rotten Tomatoes")
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 1, height: 38)
            RatingBadge(value: "\(movie.metacriticPercent)%", label: "Metacritic")
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RatingsRowView(movie: Movie.sampleMovies[0])
            .padding(.horizontal, 24)
    }
}
