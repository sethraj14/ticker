import SwiftUI

struct DayNavigationBar: View {
    let dateLabel: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
            }
            .buttonStyle(.plain)
            .frame(width: 32, height: 32)

            Spacer()

            Button(action: onToday) {
                Text(dateLabel)
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
            }
            .buttonStyle(.plain)
            .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
