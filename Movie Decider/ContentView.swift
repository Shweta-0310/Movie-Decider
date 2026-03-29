//
//  ContentView.swift
//  Movie Decider
//
//  Created by Shweta Yadav on 29/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    private let movies = Movie.sampleMovies

    var currentMovie: Movie { movies[selectedIndex] }

    // Mask gradient: opaque at top → transparent at bottom.
    // The dominant color sits on top of #161616; this mask controls
    // how much of it shows at each point across the full screen height.
    private var maskGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black,               location: 0.00),
                .init(color: .black,               location: 0.25),
                .init(color: .black.opacity(0.75), location: 0.50),
                .init(color: .black.opacity(0.35), location: 0.75),
                .init(color: .black.opacity(0.08), location: 0.92),
                .init(color: .clear,               location: 1.00),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                }

                Spacer()

                Text("Movies")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                Button { } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // Movie carousel
            CarouselView(movies: movies, selectedIndex: $selectedIndex)
                .padding(.top, 16)

            // Detail + CTA
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack {
                        VStack(spacing: 6) {
                            Text(currentMovie.title)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("\(currentMovie.genre)  •  \(currentMovie.formattedDuration)")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.55))
                        }
                        .id(currentMovie.id)
                        .transition(.opacity)
                    }
                    .padding(.top, 20)
                    .animation(.easeInOut(duration: 0.35), value: selectedIndex)

                    ZStack {
                        RatingsRowView(movie: currentMovie)
                            .id("ratings-\(currentMovie.id)")
                            .transition(.opacity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .animation(.easeInOut(duration: 0.35), value: selectedIndex)

                    BuyTicketButton()
                        .padding(.top, 28)
                        .padding(.bottom, 36)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ↓ Background is attached here so .ignoresSafeArea() on it
        //   guarantees it bleeds behind the Dynamic Island / status bar
        //   while the VStack content above still respects the safe area.
        .background {
            ZStack {
                // Base — always #161616
                Color(red: 0.0863, green: 0.0863, blue: 0.0863)

                // Dominant colour fades from full at top → gone at bottom
                currentMovie.dominantColor
                    .mask(maskGradient)
                    .animation(.easeInOut(duration: 0.50), value: selectedIndex)
            }
            .ignoresSafeArea()   // the ONLY place .ignoresSafeArea() is needed
        }
    }
}

#Preview {
    ContentView()
}
