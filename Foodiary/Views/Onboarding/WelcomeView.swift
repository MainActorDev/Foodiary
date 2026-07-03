import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    var onGetStarted: () -> Void

    private let foodEmojis = ["🥗", "🍳", "🍱", "🍌", "🍽️"]
    private let cardTints: [Color] = [
        Color(hex: "DBEAFE"),
        Color(hex: "FEF3C7"),
        Color(hex: "FEE2E2"),
        Color(hex: "E0E7FF"),
        Color(hex: "D1FAE5"),
    ]

    @State private var deck: [Int] = [0, 1, 2]
    @State private var nextCardIndex = 3
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Card deck — 3 cards in a gentle fan
            ZStack {
                ForEach(Array(deck.enumerated()), id: \.element) { position, cardID in
                    glassCard(emoji: foodEmojis[cardID], tint: cardTints[cardID])
                        .rotationEffect(.degrees(rotationFor(position)))
                        .offset(y: offsetFor(position))
                        .zIndex(Double(2 - position))
                }
            }
            .frame(width: 180, height: 200)
            .animation(.spring(response: 0.55, dampingFraction: 0.75), value: deck)

            Spacer().frame(height: 36)

            Text(L10n["app.name"])
                .font(FoodiaryTypography.pulseTitle)
                .foregroundColor(FoodiaryDesign.pulseInk)

            Spacer().frame(height: 8)

            Text(L10n["onboarding.welcome.tagline"])
                .font(FoodiaryTypography.pulseBody)
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: onGetStarted) {
                Text(L10n["onboarding.welcome.get_started"])
            }
            .buttonStyle(PulsePrimaryButtonStyle())
            .padding(.horizontal, 60)
            .padding(.bottom, 32)

            Text(L10n["onboarding.welcome.disclaimer"])
                .font(FoodiaryTypography.pulseCaption)
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FoodiaryDesign.pulseBackground)
        .onAppear { startDeckCycle() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Glass Card

    private func glassCard(emoji: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(tint.opacity(0.30))
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.5), lineWidth: 1)

            Text(emoji)
                .font(.system(size: 48))
        }
        .frame(width: 140, height: 160)
        .shadow(color: Color(hex: "141428").opacity(0.08), radius: 20, x: 0, y: 10)
    }

    // MARK: - Fan layout

    private func rotationFor(_ position: Int) -> Double {
        switch position {
        case 0: return -5   // top card
        case 1: return 0    // middle
        case 2: return 5    // bottom
        default: return 0
        }
    }

    private func offsetFor(_ position: Int) -> CGFloat {
        switch position {
        case 0: return -12
        case 1: return 4
        case 2: return 20
        default: return 0
        }
    }

    // MARK: - Card dealing cycle

    private func startDeckCycle() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                    cycleDeck()
                }
            }
        }
    }

    private func cycleDeck() {
        // Top card leaves, cards shift up, new card enters at bottom
        deck.removeFirst()
        deck.append(nextCardIndex)
        nextCardIndex = (nextCardIndex + 1) % foodEmojis.count
        // Wrap if we've gone through all cards
        if nextCardIndex == 0 { nextCardIndex = 5 % foodEmojis.count }
    }
}
