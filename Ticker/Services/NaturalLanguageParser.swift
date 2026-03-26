import Foundation

struct ParsedEvent {
    let title: String
    let startDate: Date
    let duration: TimeInterval
    var endDate: Date { startDate.addingTimeInterval(duration) }
}

/// Parses natural language event descriptions using Apple's NSDataDetector
/// for date/time recognition + simple duration extraction.
///
/// Strategy: find dates/times via NSDataDetector, extract duration via pattern matching,
/// then everything remaining is the title. No fragile regex removal chains.
enum NaturalLanguageParser {

    static func parse(_ input: String) -> ParsedEvent? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        // Step 1: Extract duration FIRST (NSDataDetector doesn't handle "for 2 hours" as duration)
        let (durationValue, textAfterDuration) = extractDuration(from: text)

        // Step 2: Use NSDataDetector to find date/time in the remaining text
        let (detectedDate, textAfterDate) = extractDate(from: textAfterDuration)

        // Step 3: Clean up the remaining text to get the title
        let title = cleanTitle(textAfterDate)
        guard !title.isEmpty else { return nil }

        // Step 4: Build the final date
        // We need at least a time. If NSDataDetector found nothing, bail out.
        guard let date = detectedDate else { return nil }

        let duration = durationValue ?? 1800 // default 30 min

        return ParsedEvent(title: title, startDate: date, duration: duration)
    }

    // MARK: - Date Extraction (NSDataDetector)

    private static func extractDate(from text: String) -> (Date?, String) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return (nil, text)
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = detector.matches(in: text, options: [], range: range)

        guard let match = matches.first, let date = match.date else {
            return (nil, text)
        }

        // Remove the matched date text from the string
        let matchRange = Range(match.range, in: text)!
        var remaining = text
        remaining.replaceSubrange(matchRange, with: "")

        // If detected date is in the past and it's today, push to tomorrow
        let calendar = Calendar.current
        if date < Date.now && calendar.isDateInToday(date) {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)
            return (tomorrow, remaining)
        }

        return (date, remaining)
    }

    // MARK: - Duration Extraction

    private static func extractDuration(from text: String) -> (TimeInterval?, String) {
        var remaining = text

        // Compound: "1h30m", "1 hour 30 min", "1h 30min"
        if let match = remaining.range(of: #"(\d+)\s*(?:h|hr|hrs|hour|hours)\s*(\d+)\s*(?:m|min|mins|minute|minutes)"#, options: [.regularExpression, .caseInsensitive]) {
            let matched = String(remaining[match])
            let nums = matched.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if nums.count == 2, let h = Int(nums[0]), let m = Int(nums[1]) {
                remaining.removeSubrange(match)
                return (TimeInterval(h * 3600 + m * 60), remaining)
            }
        }

        // Hours: "2h", "2 hours", "2hour", "1.5h", "1.5 hours"
        if let match = remaining.range(of: #"(\d+\.?\d*)\s*(?:h|hr|hrs|hour|hours)\b"#, options: [.regularExpression, .caseInsensitive]) {
            let matched = String(remaining[match])
            let numStr = matched.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
            if let hours = Double(numStr), hours > 0 {
                remaining.removeSubrange(match)
                return (TimeInterval(hours * 3600), remaining)
            }
        }

        // Minutes: "30m", "30 min", "45 minutes", "30mins"
        if let match = remaining.range(of: #"(\d+)\s*(?:m|min|mins|minute|minutes)\b"#, options: [.regularExpression, .caseInsensitive]) {
            let matched = String(remaining[match])
            let numStr = matched.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let mins = Int(numStr), mins > 0 {
                remaining.removeSubrange(match)
                return (TimeInterval(mins * 60), remaining)
            }
        }

        return (nil, remaining)
    }

    // MARK: - Title Cleanup

    private static func cleanTitle(_ text: String) -> String {
        var result = text

        // Remove common dangling prepositions at word boundaries
        let fillers = [
            #"\bfor\s*$"#,          // trailing "for"
            #"^\s*for\b"#,          // leading "for"
            #"\bfrom\s*$"#,         // trailing "from"
            #"^\s*from\b"#,         // leading "from"
            #"\bat\s*$"#,           // trailing "at"
            #"^\s*at\b"#,           // leading "at"
            #"\bon\s*$"#,           // trailing "on"
            #"^\s*on\b"#,           // leading "on"
            #"\bin\s*$"#,           // trailing "in"
            #"\bstarting\s*$"#,     // trailing "starting"
            #"\blasting\s*$"#,      // trailing "lasting"
            #"\bthe\s*$"#,          // trailing "the"
        ]

        for pattern in fillers {
            if let match = result.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                result.removeSubrange(match)
            }
        }

        // Collapse multiple spaces and trim
        while result.contains("  ") {
            result = result.replacingOccurrences(of: "  ", with: " ")
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
