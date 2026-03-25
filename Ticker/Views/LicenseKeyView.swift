import SwiftUI

struct LicenseKeyView: View {
    @ObservedObject private var license = LicenseManager.shared
    @State private var keyInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LICENSE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            if license.isPro {
                activatedView
            } else {
                activateView
            }
        }
    }

    // MARK: - Activated State

    private var activatedView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ticker Pro")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    if let email = license.licenseEmail {
                        Text(email)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }

                Spacer()

                ProBadge()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))

            Button {
                Task { await license.deactivate() }
            } label: {
                Text("Deactivate License")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.red.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(.red.opacity(0.15), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Activate State

    private var activateView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("License key", text: $keyInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))

                Button {
                    Task { await license.activate(key: keyInput) }
                } label: {
                    Text("Activate")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
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
                .disabled(keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || license.isValidating)
            }

            if license.isValidating {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Validating...")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            if let error = license.validationError {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundStyle(.red.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }

            Button {
                if let url = URL(string: LicenseManager.checkoutURL) {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("Buy License — $7.99")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }
}
