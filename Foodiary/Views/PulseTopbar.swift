import SwiftUI

// MARK: - Pulse Topbar (matches prototype .topbar)

struct PulseTopbar: View {
    let overline: String
    let title: String
    var icon: PulseTopbarIcon? = .bell
    var onIconTap: (() -> Void)?

    enum PulseTopbarIcon {
        case bell, plus, chart, user, gear
        var systemName: String {
            switch self {
            case .bell: return "bell.fill"
            case .plus: return "plus"
            case .chart: return "chart.line.uptrend.xyaxis"
            case .user: return "person.fill"
            case .gear: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(overline)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .tracking(1.0)
                    .textCase(.uppercase)
                Text(title)
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .tracking(-1)
            }

            Spacer()

            if let icon = icon {
                Button { onIconTap?() } label: {
                    Image(systemName: icon.systemName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(FoodiaryDesign.pulseInk)
                        .frame(width: 45, height: 45)
                        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(FoodiaryDesign.pulseSurface))
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(FoodiaryDesign.pulseStroke.opacity(0.10), lineWidth: 1))
                        .shadow(color: FoodiaryDesign.pulseShadow.opacity(0.07), radius: 12, x: 0, y: 6)
                }
            }
        }
        .padding(.vertical, 12)
    }
}
