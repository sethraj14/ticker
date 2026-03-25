import SwiftUI

@main
struct TickerApp: App {
    @StateObject private var viewModel = CalendarViewModel()

    init() {
        // Prevent App Nap — keeps the app alive when popover is closed.
        // Without this, macOS may suspend or terminate the process as "idle",
        // causing the menu bar icon to disappear.
        ProcessInfo.processInfo.disableAutomaticTermination("Menu bar app must stay running")
        ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleSystemSleepDisabled],
            reason: "Live countdown timer requires continuous execution"
        )
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
        } label: {
            if viewModel.menuBarLabel == "No meetings" {
                Image(systemName: "timer")
            } else {
                HStack(spacing: 0) {
                    Image(systemName: "timer")
                    Text(" \(viewModel.menuBarLabel)")
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
