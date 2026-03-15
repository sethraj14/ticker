import SwiftUI

@main
struct CalendarBarApp: App {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
                .frame(width: 340, height: 520)
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
