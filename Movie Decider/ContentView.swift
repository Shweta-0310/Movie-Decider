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
    // More stops produce a smoother, cinematic colour wash instead of a
    // hard-edged band.
    private var maskGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black,               location: 0.00),
                .init(color: .black,               location: 0.18),
                .init(color: .black.opacity(0.88), location: 0.32),
                .init(color: .black.opacity(0.68), location: 0.46),
                .init(color: .black.opacity(0.45), location: 0.60),
                .init(color: .black.opacity(0.22), location: 0.75),
                .init(color: .black.opacity(0.06), location: 0.90),
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
            if showDetail, detailMovie != nil {
                MovieDetailView(
                    movies: movies,
                    initialIndex: movies.firstIndex(where: { $0.id == detailMovie!.id }) ?? 0,
                    namespace: heroNamespace,
                    onMovieChange: { newIndex in
                        selectedIndex = newIndex
                        // detailMovie intentionally NOT updated here — keeps
                        // showingDetailForMovieID pointing to the originally-opened
                        // card so the hero dismiss animation always flies back correctly.
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showDetail = false
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .identity,          // poster flies freely via matchedGeometryEffect
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
            Spacer()

            CarouselView(
                movies: movies,
                selectedIndex: $selectedIndex,
                namespace: heroNamespace,
                showingDetailForMovieID: showDetail ? detailMovie?.id : nil,
                onTap: { movie in
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    detailMovie = movie
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                        showDetail = true
                    }
                }
            )

            // Title and ratings
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

            Spacer()
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
