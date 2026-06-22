import SwiftUI

struct StepperField: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    var onBounce: (() -> Void)?

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                value = max(range.lowerBound, value - step)
                onBounce?()
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { isPressed = false }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(FoodiaryDesign.pulseSurfaceSoft))
            }
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.5), value: isPressed)

            Spacer()

            Button(action: {
                value = min(range.upperBound, value + step)
                onBounce?()
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { isPressed = false }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(FoodiaryDesign.pulsePrimary))
            }
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.5), value: isPressed)
        }
    }
}
