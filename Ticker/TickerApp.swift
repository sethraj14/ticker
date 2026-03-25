import SwiftUI

@main
struct TickerApp: App {
    @StateObject private var viewModel = CalendarViewModel()
    @StateObject private var licenseManager = LicenseManager.shared

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
