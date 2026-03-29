import SwiftUI
import UIKit

struct Movie: Identifiable, Sendable {
    let id: UUID
    let title: String
    let genre: String
    let durationMinutes: Int
    let imdbScore: Double
    let rottenTomatoesPercent: Int
    let metacriticPercent: Int
    let posterImageName: String
    let description: String
    let cast: [CastMember]

    /// Extracted at runtime from the poster image — no hardcoded colors needed.
    var dominantColor: Color {
        UIImage(named: posterImageName)?.dominantColor
            ?? Color(red: 0.2, green: 0.2, blue: 0.3)
    }

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
            description: "Two British soldiers are sent on a near-impossible mission to deliver a message that could save 1,600 of their fellow soldiers from walking into a deadly trap. Shot to appear as one continuous take, it is a visceral and immersive experience.",
            cast: [
                CastMember(id: UUID(), name: "George MacKay",          imageName: ""),
                CastMember(id: UUID(), name: "Dean-Charles Chapman",   imageName: ""),
                CastMember(id: UUID(), name: "Mark Strong",            imageName: ""),
                CastMember(id: UUID(), name: "Andrew Scott",           imageName: ""),
            ]
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
            description: "In Gotham City, mentally troubled comedian Arthur Fleck embarks on a downward spiral of social alienation and violent revolution. A psychologically complex origin story of Batman's most iconic nemesis.",
            cast: [
                CastMember(id: UUID(), name: "Joaquin Phoenix",   imageName: ""),
                CastMember(id: UUID(), name: "Robert De Niro",    imageName: ""),
                CastMember(id: UUID(), name: "Zazie Beetz",       imageName: ""),
                CastMember(id: UUID(), name: "Frances Conroy",    imageName: ""),
            ]
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
            description: "After a shipwreck, a young man survives 227 days adrift in the Pacific Ocean aboard a lifeboat with a Bengal tiger named Richard Parker. A visually stunning meditation on faith, survival, and the stories we tell ourselves.",
            cast: [
                CastMember(id: UUID(), name: "Suraj Sharma",      imageName: ""),
                CastMember(id: UUID(), name: "Irrfan Khan",       imageName: ""),
                CastMember(id: UUID(), name: "Rafe Spall",        imageName: ""),
                CastMember(id: UUID(), name: "Adil Hussain",      imageName: ""),
            ]
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
            description: "A priest with a troubled past and a novitiate on the verge of her final vows investigate the apparent suicide of a nun in Romania. The origin story of the demon Valak from The Conjuring universe.",
            cast: [
                CastMember(id: UUID(), name: "Taissa Farmiga",    imageName: ""),
                CastMember(id: UUID(), name: "Demián Bichir",     imageName: ""),
                CastMember(id: UUID(), name: "Jonas Bloquet",     imageName: ""),
                CastMember(id: UUID(), name: "Bonnie Aarons",     imageName: ""),
            ]
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
            description: "Armed with only one word — Tenet — a CIA operative journeys through a twilight world of international espionage to prevent an attack that could annihilate the present. Time itself runs both forwards and backwards.",
            cast: [
                CastMember(id: UUID(), name: "John David Washington", imageName: ""),
                CastMember(id: UUID(), name: "Robert Pattinson",      imageName: ""),
                CastMember(id: UUID(), name: "Elizabeth Debicki",     imageName: ""),
                CastMember(id: UUID(), name: "Kenneth Branagh",       imageName: ""),
            ]
        ),
    ]
}
