import SwiftUI

struct UpgradePrompt: View {
    let feature: String
    private var checkoutURL: String { LicenseManager.checkoutURL }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                Text("Unlock with Pro")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.5))

            Text(feature)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)

            Button {
                if let url = URL(string: checkoutURL) {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("Upgrade — $7.99")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.white.opacity(0.1), lineWidth: 1))
        )
    }
}
