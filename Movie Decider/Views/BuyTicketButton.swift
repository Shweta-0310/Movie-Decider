import SwiftUI

struct BuyTicketButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text("Buy Ticket")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.70), lineWidth: 1.5)
                )
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BuyTicketButton()
    }
}
