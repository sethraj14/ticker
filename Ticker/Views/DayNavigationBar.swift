import SwiftUI

struct DayNavigationBar: View {
    let dateLabel: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void
    var isPro: Bool = false

    var body: some View {
        ZStack {
            // Center: date label (always perfectly centered)
            HStack(spacing: 4) {
                Button(action: onToday) {
                    Text(dateLabel)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .buttonStyle(.plain)

                if !isPro {
                    ProBadge()
                }
            }

            // Left/right: navigation arrows
            HStack(spacing: 0) {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(isPro ? 0.5 : 0.2))
                        .frame(width: 30, height: 30)
                        .background(.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(!isPro)
                .accessibilityLabel(isPro ? "Previous day" : "Previous day — requires Pro")

                Spacer()

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(isPro ? 0.5 : 0.2))
                        .frame(width: 30, height: 30)
                        .background(.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(!isPro)
                .accessibilityLabel(isPro ? "Next day" : "Next day — requires Pro")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
