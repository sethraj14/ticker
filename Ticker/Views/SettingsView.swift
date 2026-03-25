import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var viewModel: CalendarViewModel

    @State private var newLeadTime: String = ""
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showSettings = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(height: 30)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Settings")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                // Invisible spacer to center title
                Text("Back")
                    .font(.system(size: 13))
                    .hidden()
                    .padding(.leading, 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    // Accounts Section
                    settingsSection("Google Accounts") {
                        AccountsSection(viewModel: viewModel)
                    }

                    // Notifications Section
                    if LicenseManager.shared.isPro {
                        settingsSection("Notifications") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Remind me before meetings:")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.4))

                                ForEach(viewModel.notificationService.leadTimes, id: \.self) { minutes in
                                    HStack {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.orange.opacity(0.7))
                                        Text("\(minutes) \(minutes == 1 ? "minute" : "minutes") before")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.white.opacity(0.7))
                                        Spacer()
                                        Button {
                                            var times = viewModel.notificationService.leadTimes
                                            times.removeAll { $0 == minutes }
                                            viewModel.notificationService.leadTimes = times
                                            viewModel.rescheduleNotifications()
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(.red.opacity(0.6))
                                                .font(.system(size: 16))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.06)))
                                }

                                HStack(spacing: 8) {
                                    TextField("Minutes", text: $newLeadTime)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                        .font(.system(size: 12))

                                    Button("Add Reminder") {
                                        if let minutes = Int(newLeadTime), minutes > 0, minutes <= 120 {
                                            var times = viewModel.notificationService.leadTimes
                                            if !times.contains(minutes) {
                                                times.append(minutes)
                                                times.sort(by: >)
                                                viewModel.notificationService.leadTimes = times
                                                viewModel.rescheduleNotifications()
                                            }
                                            newLeadTime = ""
                                        }
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.blue)
                                    .buttonStyle(.plain)
                                    .disabled(Int(newLeadTime) == nil)
                                }
                                .padding(.top, 4)
                            }
                        }

                        // Preview Section
                        settingsSection("Preview") {
                            Button {
                                NotificationWindowController.shared.showTest()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.badge")
                                        .font(.system(size: 13))
                                    Text("Test Notification")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.1), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Text("NOTIFICATIONS")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.3))
                                    .tracking(1)
                                ProBadge()
                            }
                            UpgradePrompt(feature: "Get notified before meetings start")
                        }
                    }

                    // General Section
                    settingsSection("General") {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "sunrise")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(width: 20)
                                Text("Launch at login")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Toggle("", isOn: $launchAtLogin)
                                    .toggleStyle(.switch)
                                    .controlSize(.small)
                                    .onChange(of: launchAtLogin) { newValue in
                                        do {
                                            if newValue {
                                                try SMAppService.mainApp.register()
                                            } else {
                                                try SMAppService.mainApp.unregister()
                                            }
                                        } catch {
                                            launchAtLogin = !newValue
                                        }
                                    }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))
                        }
                    }

                    Divider()
                        .background(.white.opacity(0.08))

                    LicenseKeyView()

                    // Footer
                    HStack {
                        Spacer()
                        Text("Ticker v0.1.0")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.15))
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(16)
            }
        }
        .frame(width: 340, height: 520)
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            content()
        }
    }
}
