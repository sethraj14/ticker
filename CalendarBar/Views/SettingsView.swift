import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var viewModel: CalendarViewModel

    @State private var newLeadTime: String = ""
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showSettings = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.plain)

                Text("Settings")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showSettings = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Accounts
            sectionHeader("Accounts")

            HStack {
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
                Text("Google Calendar")
                    .font(.system(size: 12))
                Spacer()
                if viewModel.isAuthenticated {
                    Text("Connected")
                        .font(.system(size: 11))
                        .foregroundStyle(.green)
                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                } else {
                    Button("Sign In") {
                        viewModel.authenticate()
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                }
            }

            HStack {
                Image(systemName: "apple.logo")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                Text("Apple Calendar")
                    .font(.system(size: 12))
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
                        .controlSize(.mini)
                } else {
                    Button("Enable") {
                        viewModel.eventKitService.requestAccess()
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }

            Divider()

            // Notifications
            sectionHeader("Notifications")

            VStack(alignment: .leading, spacing: 6) {
                Text("Notify before meeting:")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                ForEach(viewModel.notificationService.leadTimes, id: \.self) { minutes in
                    HStack {
                        Text("\(minutes) min before")
                            .font(.system(size: 12))
                        Spacer()
                        Button {
                            var times = viewModel.notificationService.leadTimes
                            times.removeAll { $0 == minutes }
                            viewModel.notificationService.leadTimes = times
                            viewModel.rescheduleNotifications()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 6) {
                    TextField("min", text: $newLeadTime)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                        .font(.system(size: 11))

                    Button("Add") {
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
                    .font(.system(size: 11))
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .disabled(Int(newLeadTime) == nil)
                }
            }

            Divider()

            // General
            sectionHeader("General")

            Toggle("Launch at login", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .font(.system(size: 12))
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

            Spacer()

            HStack {
                Text("CalendarBar v0.1.0")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(16)
        .frame(width: 320, height: 480)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.secondary)
            .tracking(1)
    }
}
