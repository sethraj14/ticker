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
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.06)))
                            }

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

                            // Apple Calendar
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
                        }
                    }

                    // Notifications Section
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
