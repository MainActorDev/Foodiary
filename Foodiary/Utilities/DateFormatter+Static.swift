import Foundation

/// Static cached DateFormatter instances.
///
/// Creating `DateFormatter()` is expensive — each instance allocates
/// a new formatter. These cached statics are safe to use across
/// the app (DateFormatter is thread-safe since iOS 7).
extension DateFormatter {
    /// yyyy-MM-dd — used for meal plan date keys.
    static let dateKey: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// MMM d — used for week range start labels.
    static let weekLabel: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    /// d — day-only format for week range end.
    static let weekLabelDayOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    /// E — short day of week (Mon, Tue…).
    static let dayOfWeekShort: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f
    }()

    /// EEEE — full day name (Monday, Tuesday…).
    static let fullDayName: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f
    }()

    /// Indonesian locale full date (SELASA, 23 JUNI 2026).
    static let indonesianDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f
    }()
}
