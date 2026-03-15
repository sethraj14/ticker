import SwiftUI

@main
struct TickerApp: App {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
        } label: {
            if viewModel.menuBarLabel == "No meetings" {
                Image(systemName: "calendar")
            } else {
                Text(viewModel.menuBarLabel)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
