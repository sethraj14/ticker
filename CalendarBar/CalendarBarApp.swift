import SwiftUI

@main
struct CalendarBarApp: App {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
                .frame(width: 320, height: 480)
        } label: {
            Text(viewModel.menuBarLabel)
        }
        .menuBarExtraStyle(.window)
    }
}
