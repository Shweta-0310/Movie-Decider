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

    // Hero transition namespace — shared with CarouselView → MoviePosterCard → MovieDetailView
    @Namespace private var heroNamespace

    // Detail sheet state
    @State private var showDetail: Bool  = false
    @State private var detailMovie: Movie? = nil

    var currentMovie: Movie { movies[selectedIndex] }

    // Mask gradient: opaque at top → transparent at bottom.
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
        ZStack {
            // ── Main content ──────────────────────────────────────────────────
            mainContent

            // ── Detail overlay ────────────────────────────────────────────────
            // zIndex(1) is required: without it SwiftUI may reorder layers during
            // the removal animation causing the hero to snap instead of animate.
            if showDetail, let movie = detailMovie {
                MovieDetailView(
                    movie: movie,
                    namespace: heroNamespace,
                    onDismiss: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showDetail = false
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom),
                    removal:   .move(edge: .bottom)
                ))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.8), value: showDetail)
    }

    // ── Main screen ───────────────────────────────────────────────────────────

    private var mainContent: some View {
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

            // Carousel — passes namespace so each card can participate in the hero transition.
            // showingDetailForMovieID makes the active card invisible (not removed) while
            // the detail view is open, so matchedGeometryEffect has its source frame.
            CarouselView(
                movies: movies,
                selectedIndex: $selectedIndex,
                namespace: heroNamespace,
                showingDetailForMovieID: showDetail ? detailMovie?.id : nil
            )
            .padding(.top, 16)

            // Title, ratings, CTA
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

                    // Tapping Buy Ticket triggers the hero transition with haptic feedback
                    BuyTicketButton {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        detailMovie = currentMovie
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showDetail = true
                        }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 36)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color(red: 0.0863, green: 0.0863, blue: 0.0863)

                currentMovie.dominantColor
                    .mask(maskGradient)
                    .animation(.easeInOut(duration: 0.50), value: selectedIndex)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
