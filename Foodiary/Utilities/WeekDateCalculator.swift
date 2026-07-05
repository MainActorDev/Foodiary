import Foundation

/// Calendar-based week calculations using Monday–Sunday weeks.
///
/// Takes explicit `calendar` and `today` for testability —
/// pass frozen values in tests, production uses `.current` and `Date()`.
struct WeekDateCalculator {
    let calendar: Calendar
    let today: Date

    init(calendar: Calendar = .current, today: Date = Date()) {
        self.calendar = calendar
        self.today = today
    }

    // MARK: - Week boundaries

    /// Start (Monday 00:00) of the week containing `today`.
    var currentWeekStart: Date {
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        return calendar.date(byAdding: .day, value: mondayOffset, to: today) ?? today
    }

    /// Start (Monday) of the week at `offset` weeks from the current week.
    /// 0 = this week, -1 = last week, +1 = next week.
    func weekStart(offset: Int) -> Date {
        guard let result = calendar.date(byAdding: .day, value: offset * 7, to: currentWeekStart) else {
            return today
        }
        return result
    }

    /// All 7 dates (Mon–Sun) for the week at the given offset.
    func daysInWeek(offset: Int) -> [Date] {
        let start = weekStart(offset: offset)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    // MARK: - Queries

    /// True if `date` falls in a week before the current week.
    /// Days in the current week (even past days) return false.
    func isBeforeCurrentWeek(_ date: Date) -> Bool {
        calendar.compare(date, to: currentWeekStart, toGranularity: .day) == .orderedAscending
    }
}
