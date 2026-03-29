import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    var namespace: Namespace.ID
    var onDismiss: () -> Void

    // Controls staggered fade-in of content after poster expands
    @State private var titleVisible       = false
    @State private var ratingsVisible     = false
    @State private var descriptionVisible = false
    @State private var castVisible        = false
    @State private var buttonVisible      = false

    // Tracks drag distance for swipe-down-to-dismiss
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {

            // ── Scrollable content ────────────────────────────────────────────
            // The ScrollView is the layout anchor so its width is always screen-
            // width. Background layers are attached here so the matchedGeometry-
            // Effect image's animated layout frame never affects the ZStack's
            // sizing (which was causing content to shift off the left edge).
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Push content down so the top of the poster stays visible
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.44)

                    // Title + genre/duration
                    VStack(alignment: .leading, spacing: 6) {
                        Text(movie.title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)

                        Text("\(movie.genre)  •  \(movie.formattedDuration)")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 16)

                    // Ratings
                    RatingsRowView(movie: movie)
                        .padding(.top, 20)
                        .opacity(ratingsVisible ? 1 : 0)
                        .offset(y: ratingsVisible ? 0 : 16)

                    // Description
                    Text(movie.description)
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.75))
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 20)
                        .opacity(descriptionVisible ? 1 : 0)
                        .offset(y: descriptionVisible ? 0 : 16)

                    // Cast — negative horizontal padding escapes the outer 24pt
                    // inset so the horizontal scroll can reach the screen edges
                    CastScrollView(cast: movie.cast)
                        .padding(.horizontal, -24)
                        .padding(.top, 24)
                        .opacity(castVisible ? 1 : 0)
                        .offset(y: castVisible ? 0 : 16)

                    Spacer().frame(height: 32)
                }
                // Single source of 24 pt horizontal inset for all content
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
            .background {
                // ── Hero poster (matchedGeometryEffect destination) ───────────
                // isSource: false — the carousel card is always the source.
                // Placed in .background so its animated layout frame never
                // widens the ZStack and displaces the ScrollView.
                Image(movie.posterImageName)
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(
                        id: "poster-\(movie.id)",
                        in: namespace,
                        isSource: false
                    )
                    .clipped()
                    .ignoresSafeArea()

                // ── Dark gradient for readability ─────────────────────────────
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

                // ── Subtle material blur ───────────────────────────────────────
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(0.20)
                    .ignoresSafeArea()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Pinned Buy Ticket button that doesn't scroll away
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
        // Apply drag offset to the whole view for swipe-down feel
        .offset(y: dragOffset)
        // Swipe-down-to-dismiss gesture.
        // minimumDistance prevents conflict with horizontal scroll inside cast section.
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
            // Stagger each content block's fade-in after the poster has expanded (0.3s head start)
            withAnimation(.easeOut(duration: 0.35).delay(0.30)) { titleVisible       = true }
            withAnimation(.easeOut(duration: 0.35).delay(0.38)) { ratingsVisible     = true }
            withAnimation(.easeOut(duration: 0.35).delay(0.46)) { descriptionVisible = true }
            withAnimation(.easeOut(duration: 0.35).delay(0.54)) { castVisible        = true }
            withAnimation(.easeOut(duration: 0.35).delay(0.54)) { buttonVisible      = true }
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
    MovieDetailView(movie: Movie.sampleMovies[1], namespace: ns, onDismiss: {})
}
