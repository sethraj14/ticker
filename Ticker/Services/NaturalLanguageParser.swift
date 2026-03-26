import Foundation

struct ParsedEvent {
    let title: String
    let startDate: Date
    let duration: TimeInterval // in seconds
    var endDate: Date { startDate.addingTimeInterval(duration) }
}

enum NaturalLanguageParser {
    /// Parse natural language like "Team sync tomorrow 3pm 45min"
    static func parse(_ input: String) -> ParsedEvent? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        var remaining = text

        // Extract duration (look for patterns like "45min", "1h", "1h30m", "30m")
        let duration = extractDuration(from: &remaining)

        // Extract time (look for "3pm", "15:00", "3:30pm", "10am")
        let time = extractTime(from: &remaining)

        // Extract date reference (today, tomorrow, day names like "Friday", "next Monday")
        let dateRef = extractDateReference(from: &remaining)

        // Whatever's left is the title
        let title = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }

        // Time is required
        guard let time else { return nil }
        let calendar = Calendar.current
        let targetDate = dateRef ?? Date.now

        // Combine date + time
        var components = calendar.dateComponents([.year, .month, .day], from: targetDate)
        components.hour = time.hour
        components.minute = time.minute

        guard let startDate = calendar.date(from: components) else { return nil }

        // If the resulting date is in the past and no explicit date was given, assume tomorrow
        let finalDate: Date
        if startDate < Date.now && dateRef == nil {
            finalDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        } else {
            finalDate = startDate
        }

        return ParsedEvent(
            title: title,
            startDate: finalDate,
            duration: duration ?? 1800 // default 30 min
        )
    }

    // MARK: - Duration Extraction

    /// Extract duration patterns: "45min", "45m", "1h", "1h30m", "1.5h", "90min",
    /// "2 hours", "2hour", "30 minutes", "1 hr", "1.5 hours"
    private static func extractDuration(from text: inout String) -> TimeInterval? {
        // Match compound: "1h30m", "1h 30m", "1 hour 30 min", "1h 30min"
        if let match = text.range(of: #"(\d+)\s*h(?:r|rs|our|ours)?\s*(\d+)\s*m(?:in(?:ute)?s?)?"#, options: .regularExpression) {
            let matched = String(text[match])
            let nums = matched.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if nums.count == 2, let h = Int(nums[0]), let m = Int(nums[1]) {
                text.removeSubrange(match)
                return TimeInterval(h * 3600 + m * 60)
            }
        }
        // Match hours: "1.5h", "2h", "1hr", "2 hours", "2hour", "1.5 hours", "1 hr"
        if let match = text.range(of: #"(\d+\.?\d*)\s*h(?:r|rs|our|ours)?"#, options: .regularExpression) {
            let matched = String(text[match])
            let numStr = matched.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
            if let hours = Double(numStr) {
                text.removeSubrange(match)
                return TimeInterval(hours * 3600)
            }
        }
        // Match minutes: "45min", "45m", "30 min", "30 minutes", "45 mins"
        if let match = text.range(of: #"(\d+)\s*m(?:in(?:ute)?s?)?"#, options: .regularExpression) {
            let matched = String(text[match])
            let numStr = matched.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let mins = Int(numStr) {
                text.removeSubrange(match)
                return TimeInterval(mins * 60)
            }
        }
        return nil
    }

    // MARK: - Time Extraction

    /// Extract time patterns: "3pm", "3:30pm", "15:00", "10am"
    private static func extractTime(from text: inout String) -> (hour: Int, minute: Int)? {
        // Match "3:30pm", "12:00am", "10:15 AM"
        if let match = text.range(of: #"(\d{1,2}):(\d{2})\s*(am|pm|AM|PM)"#, options: .regularExpression) {
            let matched = String(text[match])
            let parts = matched.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).filter { !$0.isEmpty }
            let isPM = matched.lowercased().contains("pm")
            if parts.count >= 2, var hour = Int(parts[0]), let minute = Int(parts[1]) {
                if isPM && hour < 12 { hour += 12 }
                if !isPM && hour == 12 { hour = 0 }
                text.removeSubrange(match)
                return (hour, minute)
            }
        }
        // Match "3pm", "10am", "12 PM"
        if let match = text.range(of: #"(\d{1,2})\s*(am|pm|AM|PM)"#, options: .regularExpression) {
            let matched = String(text[match])
            let numStr = matched.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let isPM = matched.lowercased().contains("pm")
            if var hour = Int(numStr) {
                if isPM && hour < 12 { hour += 12 }
                if !isPM && hour == 12 { hour = 0 }
                text.removeSubrange(match)
                return (hour, 0)
            }
        }
        // Match 24h format "15:00", "09:30"
        if let match = text.range(of: #"(\d{1,2}):(\d{2})"#, options: .regularExpression) {
            let matched = String(text[match])
            let parts = matched.split(separator: ":").compactMap { Int($0) }
            if parts.count == 2, parts[0] < 24, parts[1] < 60 {
                text.removeSubrange(match)
                return (parts[0], parts[1])
            }
        }
        return nil
    }

    // MARK: - Date Reference Extraction

    /// Extract date reference: "today", "tomorrow", "Monday", "next Friday", etc.
    private static func extractDateReference(from text: inout String) -> Date? {
        let calendar = Calendar.current
        let hasNext = text.lowercased().contains("next")

        if let match = text.range(of: #"\bday after tomorrow\b"#, options: [.regularExpression, .caseInsensitive]) {
            text.removeSubrange(match)
            return calendar.date(byAdding: .day, value: 2, to: Date.now)
        }
        if let match = text.range(of: #"\btomorrow\b"#, options: [.regularExpression, .caseInsensitive]) {
            text.removeSubrange(match)
            return calendar.date(byAdding: .day, value: 1, to: Date.now)
        }
        if let match = text.range(of: #"\btoday\b"#, options: [.regularExpression, .caseInsensitive]) {
            text.removeSubrange(match)
            return Date.now
        }

        // Day names: "Monday", "Tuesday", etc. (next occurrence)
        let dayNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        for (index, name) in dayNames.enumerated() {
            let pattern = #"\bnext\s+"# + name + #"\b"#
            if let match = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                text.removeSubrange(match)
                let today = calendar.component(.weekday, from: Date.now)
                let targetDay = index + 1
                var daysAhead = targetDay - today
                if daysAhead <= 0 { daysAhead += 7 }
                daysAhead += 7 // "next" always means next week
                return calendar.date(byAdding: .day, value: daysAhead, to: Date.now)
            }

            let simplePattern = #"\b"# + name + #"\b"#
            if let match = text.range(of: simplePattern, options: [.regularExpression, .caseInsensitive]) {
                text.removeSubrange(match)
                let today = calendar.component(.weekday, from: Date.now)
                let targetDay = index + 1
                var daysAhead = targetDay - today
                if daysAhead <= 0 { daysAhead += 7 }
                return calendar.date(byAdding: .day, value: daysAhead, to: Date.now)
            }
        }

        return nil
    }
}
