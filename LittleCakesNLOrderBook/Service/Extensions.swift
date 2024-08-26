import Foundation

extension ISO8601DateFormatter {
    static var extended: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,   // Handles dates with milliseconds
            .withFractionalSeconds    // Optional: Handles milliseconds
        ]
        return formatter
    }
}

extension Date {
    func startOfDay() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
}
