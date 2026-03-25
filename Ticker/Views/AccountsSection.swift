import SwiftUI

// MARK: - Accounts Section

struct AccountsSection: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.googleService.accounts) { account in
                HStack(spacing: 10) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.email)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                        Text("Connected")
                            .font(.system(size: 10))
                            .foregroundStyle(.green.opacity(0.7))
                    }

                    Spacer()

                    Button {
                        viewModel.removeAccount(account)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(width: 22, height: 22)
                            .background(.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove account \(account.email)")
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))
            }

            if LicenseManager.shared.isPro || viewModel.googleService.accounts.isEmpty {
                Button {
                    viewModel.addAccount()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text("Add Google Account")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    if let url = URL(string: LicenseManager.checkoutURL) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text("Add Google Account")
                            .font(.system(size: 12, weight: .medium))
                        ProBadge()
                    }
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.08), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            // Apple Calendar
            if LicenseManager.shared.isPro {
                HStack(spacing: 10) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Calendar")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                        Text(viewModel.eventKitService.isAuthorized ? "Enabled" : "Not connected")
                            .font(.system(size: 11))
                            .foregroundStyle(viewModel.eventKitService.isAuthorized ? .green.opacity(0.7) : .white.opacity(0.3))
                    }

                    Spacer()

                    if viewModel.eventKitService.isAuthorized {
                        Toggle("", isOn: Binding(
                            get: { viewModel.eventKitService.isEnabled },
                            set: { newValue in
                                viewModel.eventKitService.isEnabled = newValue
                                viewModel.fetchEvents()
                            }
                        ))
                        .toggleStyle(.switch)
                        .controlSize(.small)
                    } else {
                        Button("Enable") {
                            viewModel.eventKitService.requestAccess()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.blue)
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))
            } else {
                Button {
                    if let url = URL(string: LicenseManager.checkoutURL) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(width: 22)

                        Text("Apple Calendar")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))

                        ProBadge()

                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.04)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
