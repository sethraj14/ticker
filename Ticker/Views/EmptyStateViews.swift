import SwiftUI

// MARK: - Empty State Views

struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.15), .blue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.blue.opacity(0.7))
            }

            Text("All clear")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            Text("No events scheduled for this day")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoMeetingsView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.15), .orange.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: "sun.max")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.orange.opacity(0.7))
            }

            Text("No meetings")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            Text("Enjoy your free day")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
