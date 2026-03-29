import SwiftUI

struct Movie: Identifiable, Sendable {
    let id: UUID
    let title: String
    let genre: String
    let durationMinutes: Int
    let imdbScore: Double
    let rottenTomatoesPercent: Int
    let metacriticPercent: Int
    let posterImageName: String
    let dominantColor: Color   // used for the animated background gradient

    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        return minutes == 0 ? "\(hours)h" : "\(hours)h \(minutes)m"
    }

    var imdbDisplay: String { String(format: "%.1f", imdbScore) }
}

extension Movie {
    static let sampleMovies: [Movie] = [
        Movie(
            id: UUID(),
            title: "1917",
            genre: "War / Drama",
            durationMinutes: 119,
            imdbScore: 8.3,
            rottenTomatoesPercent: 89,
            metacriticPercent: 78,
            posterImageName: "1917",
            dominantColor: Color(red: 0.58, green: 0.44, blue: 0.22)  // warm amber
        ),
        Movie(
            id: UUID(),
            title: "Joker",
            genre: "Crime / Thriller",
            durationMinutes: 122,
            imdbScore: 8.4,
            rottenTomatoesPercent: 69,
            metacriticPercent: 59,
            posterImageName: "joker",
            dominantColor: Color(red: 0.62, green: 0.28, blue: 0.06)  // burnt orange
        ),
        Movie(
            id: UUID(),
            title: "Life of Pi",
            genre: "Adventure / Drama",
            durationMinutes: 127,
            imdbScore: 7.9,
            rottenTomatoesPercent: 87,
            metacriticPercent: 79,
            posterImageName: "life_of_pir",
            dominantColor: Color(red: 0.06, green: 0.42, blue: 0.60)  // ocean blue
        ),
        Movie(
            id: UUID(),
            title: "The Nun",
            genre: "Horror / Mystery",
            durationMinutes: 96,
            imdbScore: 5.3,
            rottenTomatoesPercent: 24,
            metacriticPercent: 45,
            posterImageName: "nun",
            dominantColor: Color(red: 0.14, green: 0.26, blue: 0.20)  // dark forest green
        ),
        Movie(
            id: UUID(),
            title: "Tenet",
            genre: "Action / Sci-Fi",
            durationMinutes: 150,
            imdbScore: 7.3,
            rottenTomatoesPercent: 70,
            metacriticPercent: 69,
            posterImageName: "tenet",
            dominantColor: Color(red: 0.28, green: 0.35, blue: 0.58)  // steel blue-purple
        )
    ]
}
