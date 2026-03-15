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
                    .frame(height: 30)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Settings")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                // Invisible spacer to center title
                Text("Back")
                    .font(.system(size: 13))
                    .hidden()
                    .padding(.leading, 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Accounts Section
                    settingsSection("Accounts") {
                        VStack(spacing: 10) {
                            // Google
                            HStack(spacing: 10) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.blue)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Google Calendar")
                                        .font(.system(size: 13, weight: .medium))
                                    if viewModel.isAuthenticated {
                                        Text("Connected")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.green)
                                    }
                                }

                                Spacer()

                                if viewModel.isAuthenticated {
                                    Button("Sign Out") {
                                        viewModel.signOut()
                                    }
                                    .font(.system(size: 12))
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                } else {
                                    Button("Sign In") {
                                        viewModel.authenticate()
                                    }
                                    .font(.system(size: 12))
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))

                            // Apple Calendar
                            HStack(spacing: 10) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 20))
                                    .frame(width: 22)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Apple Calendar")
                                        .font(.system(size: 13, weight: .medium))
                                    Text(viewModel.eventKitService.isAuthorized ? "Enabled" : "Not connected")
                                        .font(.system(size: 11))
                                        .foregroundStyle(viewModel.eventKitService.isAuthorized ? .green : .secondary)
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
                                    .font(.system(size: 12))
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
                        }
                    }

                    // Notifications Section
                    settingsSection("Notifications") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Remind me before meetings:")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)

                            ForEach(viewModel.notificationService.leadTimes, id: \.self) { minutes in
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.orange)
                                    Text("\(minutes) minutes before")
                                        .font(.system(size: 13))
                                    Spacer()
                                    Button {
                                        var times = viewModel.notificationService.leadTimes
                                        times.removeAll { $0 == minutes }
                                        viewModel.notificationService.leadTimes = times
                                        viewModel.rescheduleNotifications()
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red)
                                            .font(.system(size: 16))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 6).fill(.quaternary.opacity(0.3)))
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
                                .font(.system(size: 12))
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .disabled(Int(newLeadTime) == nil)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // General Section
                    settingsSection("General") {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "sunrise")
                                    .font(.system(size: 13))
                                    .frame(width: 20)
                                Text("Launch at login")
                                    .font(.system(size: 13))
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
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
                        }
                    }

                    // Footer
                    HStack {
                        Spacer()
                        Text("Ticker v0.1.0")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(14)
            }
        }
        .frame(width: 340, height: 520)
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)

            content()
        }
    }
}
