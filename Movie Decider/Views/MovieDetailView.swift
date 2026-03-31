import SwiftUI

struct MovieDetailView: View {
    let movies: [Movie]
    let initialIndex: Int
    var namespace: Namespace.ID
    var onMovieChange: (Int) -> Void
    var onDismiss: () -> Void

    // Current position in the movies array
    @State private var currentIndex: Int = 0

    // Controls staggered fade-in of content after poster expands
    @State private var titleVisible       = false
    @State private var ratingsVisible     = false
    @State private var descriptionVisible = false
    @State private var castVisible        = false
    @State private var buttonVisible      = false

    // Dark gradient fades in after the poster flies into place
    @State private var bgOpacity: Double = 0
    // Corner radius animates from card (22pt) → full bleed (0pt) during hero expansion
    @State private var posterCornerRadius: CGFloat = 22

    // Tracks drag distance for swipe-down-to-dismiss
    @State private var dragOffset: CGFloat = 0

    // Horizontal swipe navigation state
    @State private var swipeTranslation: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var posterSwipeReady = false
    // Single offset applied to the entire poster strip during a commit.
    // All adjacent posters are permanently in the hierarchy, so no view is
    // ever inserted mid-animation — eliminating the SwiftUI timing freeze.
    @State private var pagerOffset: CGFloat = 0

    private var currentMovie: Movie { movies[currentIndex] }

    var body: some View {
        ZStack(alignment: .top) {

            // ── Dark gradient for readability (fades in after poster settles) ─
            LinearGradient(
                stops: [
                    .init(color: .clear,               location: 0.0),
                    .init(color: .black.opacity(0.30), location: 0.3),
                    .init(color: .black.opacity(0.75), location: 0.6),
                    .init(color: .black.opacity(0.92), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(bgOpacity)

            // ── Subtle material blur ──────────────────────────────────────────
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(bgOpacity * 0.20)
                .ignoresSafeArea()

            // ── Scrollable content ────────────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Top dead-zone: carries the horizontal swipe gesture so it
                    // never competes with the cast horizontal ScrollView below.
                    Color.clear
                        .frame(height: UIScreen.main.bounds.height * 0.44)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onChanged { value in
                                    let dx = value.translation.width
                                    let dy = value.translation.height
                                    guard abs(dx) > abs(dy), !isTransitioning else { return }
                                    // Rubber-band resistance at boundaries
                                    if dx < 0 && currentIndex >= movies.count - 1 {
                                        swipeTranslation = dx * 0.25
                                    } else if dx > 0 && currentIndex <= 0 {
                                        swipeTranslation = dx * 0.25
                                    } else {
                                        swipeTranslation = dx
                                    }
                                }
                                .onEnded { value in
                                    let dx = value.translation.width
                                    if dx < -80, currentIndex < movies.count - 1 {
                                        commitSwipe(to: currentIndex + 1)
                                    } else if dx > 80, currentIndex > 0 {
                                        commitSwipe(to: currentIndex - 1)
                                    } else {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            swipeTranslation = 0
                                        }
                                    }
                                }
                        )

                    // Content — keyed on movie id so SwiftUI crossfades when it changes
                    VStack(alignment: .leading, spacing: 0) {

                        // Title + genre/duration
                        VStack(alignment: .leading, spacing: 6) {
                            Text(currentMovie.title)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)

                            Text("\(currentMovie.genre)  •  \(currentMovie.formattedDuration)")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.55))
                        }
                        .opacity(titleVisible ? 1 : 0)
                        .offset(y: titleVisible ? 0 : 10)

                        // Ratings
                        RatingsRowView(movie: currentMovie)
                            .padding(.top, 20)
                            .opacity(ratingsVisible ? 1 : 0)
                            .offset(y: ratingsVisible ? 0 : 10)

                        // Description
                        Text(currentMovie.description)
                            .font(.body)
                            .foregroundColor(Color.white.opacity(0.75))
                            .lineSpacing(5)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 20)
                            .opacity(descriptionVisible ? 1 : 0)
                            .offset(y: descriptionVisible ? 0 : 10)

                        // Cast — negative horizontal padding escapes the outer 24pt
                        // inset so the horizontal scroll can reach the screen edges
                        CastScrollView(cast: currentMovie.cast)
                            .padding(.horizontal, -24)
                            .padding(.top, 24)
                            .opacity(castVisible ? 1 : 0)
                            .offset(y: castVisible ? 0 : 10)

                        Spacer().frame(height: 32)
                    }
                    .id(currentMovie.id)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
                }
                // Single source of 24 pt horizontal inset for all content
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Pinned Buy Ticket button that doesn't scroll away.
            // Lives in safeAreaInset so it is completely outside the scroll content
            // and the swipe translation — it never moves.
            .safeAreaInset(edge: .bottom) {
                BuyTicketButton()
                    .padding(.vertical, 16)
                    .background {
                        // Gradient: transparent at top → black at bottom
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.92)],
                            startPoint: .top,
                            endPoint: UnitPoint(x: 0.5, y: 0.5)
                        )
                        .ignoresSafeArea()
                    }
                    .opacity(buttonVisible ? 1 : 0)
            }

            // ── Dismiss controls ──────────────────────────────────────────────
            // Drag indicator pill at the top
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 40, height: 4)
                .padding(.top, 10)

            // Close button — always visible, top trailing
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.45), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 54)   // clears Dynamic Island
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ── Hero poster (matchedGeometryEffect destination) ───────────────────
        // Three-layer background:
        //   Layer 1 — Hero with matchedGeometryEffect for open/close animation.
        //             Fades out once posterSwipeReady is true.
        //   Layer 2 — Pre-pager crossfade overlay (same as original), only while
        //             posterSwipeReady is false and currentIndex != initialIndex.
        //   Layer 3 — Horizontal pager with prev/current/next posters offset by
        //             swipeTranslation. Active once posterSwipeReady is true.
        .background {
            let sw = UIScreen.main.bounds.width
            let sh = UIScreen.main.bounds.height
            ZStack {
                // Immediate opaque base
                Color.black

                // Layer 1: Hero — stable matchedGeometryEffect, fades out once pager ready
                Image(movies[initialIndex].posterImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: sw, height: sh)
                    .matchedGeometryEffect(
                        id: "poster-\(movies[initialIndex].id)",
                        in: namespace,
                        isSource: false
                    )
                    .clipShape(RoundedRectangle(cornerRadius: posterCornerRadius))
                    .opacity(posterSwipeReady ? 0 : 1)

                // Layer 2: Pre-pager crossfade — only while hero active and movie changed.
                if currentIndex != initialIndex && !posterSwipeReady {
                    Image(currentMovie.posterImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: sw, height: sh)
                        .clipped()
                        .transition(.opacity)
                }

                // Layer 3: Pager strip — all adjacent posters stay in the hierarchy so
                // no view is inserted mid-animation (eliminates the freeze/jerk bug).
                if posterSwipeReady {
                    let lo = max(0, currentIndex - 1)
                    let hi = min(movies.count - 1, currentIndex + 1)
                    ZStack {
                        ForEach(lo...hi, id: \.self) { idx in
                            Image(movies[idx].posterImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: sw, height: sh)
                                .clipped()
                                .offset(x: CGFloat(idx - currentIndex) * sw + pagerOffset)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.20), value: posterSwipeReady)
        }
        // Apply vertical drag offset for swipe-down-to-dismiss feel.
        // swipeTranslation is intentionally NOT applied here — the poster background
        // stays fixed while only the content area logically changes movie.
        .offset(y: dragOffset)
        // Swipe-down-to-dismiss gesture on the outer ZStack.
        // Guards to vertical-only so it never conflicts with the horizontal
        // swipe gesture on the top dead-zone above.
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    // Only respond to predominantly downward drags
                    guard value.translation.height > abs(value.translation.width) else { return }
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 || value.predictedEndTranslation.height > 250 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .onAppear {
            currentIndex = initialIndex
            // 1. Corner radius: 22 → 0, using the same spring as the hero so the
            //    clip shape and position/size stay in perfect sync throughout the flight.
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                posterCornerRadius = 0
            }
            // 2. Dark overlay + blur are GPU-expensive; starting them while the hero
            //    spring is still in heavy motion drops frames and looks jerky.
            //    Delay until the spring has fully settled (~0.50 s).
            withAnimation(.easeOut(duration: 0.35).delay(0.50)) {
                bgOpacity = 1.0
            }
            // 3. Content elements cascade-fade in after the overlay appears
            animateContentIn(delay: 0.55)
            withAnimation(.easeOut(duration: 0.35).delay(0.72)) { buttonVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.20)) {
                    posterSwipeReady = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func animateContentIn(delay: Double) {
        withAnimation(.easeOut(duration: 0.35).delay(delay))        { titleVisible       = true }
        withAnimation(.easeOut(duration: 0.35).delay(delay + 0.08)) { ratingsVisible     = true }
        withAnimation(.easeOut(duration: 0.35).delay(delay + 0.16)) { descriptionVisible = true }
        withAnimation(.easeOut(duration: 0.35).delay(delay + 0.24)) { castVisible        = true }
    }

    private func resetAnimationStates() {
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
            titleVisible       = false
            ratingsVisible     = false
            descriptionVisible = false
            castVisible        = false
            // buttonVisible intentionally NOT reset — button never flashes between movies
        }
    }

    private func commitSwipe(to newIndex: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isTransitioning = true

        if posterSwipeReady {
            let w = UIScreen.main.bounds.width
            // Slide the whole strip: negative = going forward, positive = going back.
            let targetOffset: CGFloat = newIndex > currentIndex ? -w : w

            withAnimation(.spring(response: 0.42, dampingFraction: 0.92)) {
                pagerOffset = targetOffset
            }

            // After the spring settles, atomically re-anchor the strip to the new index.
            // At settle time the new poster is at (1 * w) + (-w) = 0 (centre).
            // After reset it is at (0 * w) + 0 = 0 — identical position, no visual jump.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    currentIndex = newIndex
                    pagerOffset  = 0
                }
                onMovieChange(newIndex)
                resetAnimationStates()
                animateContentIn(delay: 0.05)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
                    isTransitioning = false
                }
            }
        } else {
            // Hero is still visible — use original spring-snap + delayed index update.
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                swipeTranslation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // Explicit animation so Layer 2's crossfade still fades in smoothly.
                withAnimation(.easeInOut(duration: 0.30)) { currentIndex = newIndex }
                onMovieChange(newIndex)
                resetAnimationStates()
                animateContentIn(delay: 0.05)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
                    isTransitioning = false
                }
            }
        }
    }
}

// ── Private sub-views ─────────────────────────────────────────────────────────

private struct CastScrollView: View {
    let cast: [CastMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(cast) { member in
                        CastMemberCard(member: member)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

private struct CastMemberCard: View {
    let member: CastMember

    var body: some View {
        VStack(spacing: 8) {
            Group {
                if member.imageName.isEmpty {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(Color.white.opacity(0.35))
                } else {
                    Image(member.imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 68, height: 68)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

            Text(member.name)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 76)
        }
    }
}

#Preview {
    @Previewable @Namespace var ns
    MovieDetailView(
        movies: Movie.sampleMovies,
        initialIndex: 1,
        namespace: ns,
        onMovieChange: { _ in },
        onDismiss: {}
    )
}
