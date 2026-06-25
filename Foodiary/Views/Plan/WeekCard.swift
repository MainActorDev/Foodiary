import SwiftUI

// MARK: - Week Card
///
/// Week navigator with previous/next buttons, week label,
/// and 7 day pills with 5 visual states.

struct WeekCard: View {
    @Binding var weekOffset: Int
    @Binding var selectedPlanDate: Date
    let weekStart: Date
    let weekLabel: String
    let weekDays: [Date]
    var hasMealData: (Date) -> (hasPlan: Bool, totalCal: Int)
    let targetCalories: Int

    var body: some View {
        VStack(spacing: 14) {
            // Header row
            HStack(spacing: 8) {
                Button(action: { weekOffset -= 1; selectedPlanDate = weekStartFor(offset: weekOffset) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                        .frame(width: 32, height: 32)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
                }

                Text(weekLabel)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .frame(maxWidth: .infinity)

                Button(action: { weekOffset += 1; selectedPlanDate = weekStartFor(offset: weekOffset) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                        .frame(width: 32, height: 32)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
                }
            }

            // Day pills
            HStack(spacing: 7) {
                ForEach(weekDays, id: \.self) { day in
                    DayPill(
                        day: day,
                        isSelected: Calendar.current.isDate(day, inSameDayAs: selectedPlanDate),
                        hasMealData: hasMealData,
                        targetCalories: targetCalories,
                        onSelect: { selectedPlanDate = day }
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(FoodiaryDesign.pulseSurface)
                .shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14)
        )
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1))
    }

    private func weekStartFor(offset: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        guard let thisMonday = calendar.date(byAdding: .day, value: mondayOffset, to: today),
              let result = calendar.date(byAdding: .day, value: offset * 7, to: thisMonday) else { return today }
        return result
    }
}

// MARK: - Day Pill

struct DayPill: View {
    let day: Date
    let isSelected: Bool
    var hasMealData: (Date) -> (hasPlan: Bool, totalCal: Int)
    let targetCalories: Int
    var onSelect: () -> Void

    private var dayState: DayState {
        let isToday = Calendar.current.isDateInToday(day)
        let isPast = day < Calendar.current.startOfDay(for: Date())
        let (hasData, totalCal) = hasMealData(day)
        let isOver = totalCal > targetCalories && hasData

        if isSelected { return .active }
        if isOver { return .over }
        if !hasData && isPast { return .empty }
        if !hasData && !isToday { return .future }
        if isToday && !isSelected { return .today }
        return .default
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 3) {
                Text(DateFormatter.dayOfWeekShort.string(from: day))
                    .font(.system(size: 9, weight: .black)).tracking(0.7).textCase(.uppercase)
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.system(size: 16, weight: .bold))
                Circle()
                    .fill(dayState == .over ? FoodiaryDesign.pulseDanger.opacity(0.6) : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8).padding(.horizontal, 3)
            .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(dayStateBg))
            .foregroundColor(dayStateFg)
        }
        .buttonStyle(.plain)
    }

    enum DayState { case active, today, future, empty, over, `default` }

    private var dayStateBg: Color {
        switch dayState {
        case .active: return FoodiaryDesign.pulsePrimaryDark
        case .future: return FoodiaryDesign.pulseDayFuture
        case .empty: return FoodiaryDesign.pulseDayEmpty
        case .over: return Color(hex: "FEF2F2")
        case .today: return FoodiaryDesign.pulseSurfaceSoft
        case .default: return FoodiaryDesign.pulseSurfaceSoft
        }
    }

    private var dayStateFg: Color {
        switch dayState {
        case .active: return .white
        case .future: return FoodiaryDesign.pulseDayFutureFg
        case .empty: return FoodiaryDesign.pulseDayEmptyFg
        case .over: return FoodiaryDesign.pulseDanger
        case .today: return FoodiaryDesign.pulseInk
        case .default: return FoodiaryDesign.pulseMuted
        }
    }
}
