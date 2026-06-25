import SwiftUI

// MARK: - Ring Button Styles

struct RingButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.accent
    var fgColor: Color = .white
    var cornerRadius: CGFloat = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(bgColor)
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.04 : 0.06), radius: 2, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RingSecondaryButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(FoodiaryDesign.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.03 : 0.04), radius: 2, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RingStepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(FoodiaryDesign.black)
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RingIconButtonStyle: ButtonStyle {
    var isDanger: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isDanger ? .white : FoodiaryDesign.black)
            .frame(width: isDanger ? 28 : 32, height: isDanger ? 28 : 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDanger ? FoodiaryDesign.black : FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Pulse v2 Button Styles

struct PulsePrimaryButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.pulsePrimary
    var fgColor: Color = .white
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bgColor)
                    .shadow(color: bgColor.opacity(configuration.isPressed ? 0.12 : 0.24), radius: 12, x: 0, y: configuration.isPressed ? 4 : 8)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PulseSecondaryButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(FoodiaryDesign.pulseInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
                    .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(configuration.isPressed ? 0.03 : 0.06), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PulseIconButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.pulseSurface
    var fgColor: Color = FoodiaryDesign.pulseInk
    var size: CGFloat = 40

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(fgColor)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size / 2.5, style: .continuous)
                    .fill(bgColor)
                    .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(configuration.isPressed ? 0.03 : 0.06), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: size / 2.5, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
