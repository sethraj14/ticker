import SwiftUI

@main
struct TickerApp: App {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
        } label: {
            if viewModel.menuBarLabel == "No meetings" {
                TickerMenuBarIcon()
            } else {
                HStack(spacing: 4) {
                    TickerMenuBarIcon()
                    Text(viewModel.menuBarLabel)
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}

/// Custom menu bar icon — countdown timer with arc
/// A circle with a countdown-style arc gap and a small indicator dot
struct TickerMenuBarIcon: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 1.5

            // Countdown arc (270 degrees — like 3/4 of a timer remaining)
            var arc = Path()
            arc.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(200),
                clockwise: false
            )
            context.stroke(arc, with: .foreground, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

            // Gap indicator dot at the end of the arc gap (where countdown "ends")
            let dotAngle = Double.pi * 200 / 180 - Double.pi / 2
            let dotX = center.x + cos(dotAngle) * radius
            let dotY = center.y + sin(dotAngle) * radius
            let dotRect = CGRect(x: dotX - 1.5, y: dotY - 1.5, width: 3, height: 3)
            context.fill(Path(ellipseIn: dotRect), with: .foreground)

            // Center vertical line (like a timer button/stem)
            var stem = Path()
            stem.move(to: CGPoint(x: center.x, y: center.y - radius - 2))
            stem.addLine(to: CGPoint(x: center.x, y: center.y - radius + 3))
            context.stroke(stem, with: .foreground, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

            // Small hand pointing from center to ~1 o'clock
            var hand = Path()
            hand.move(to: center)
            let handAngle = -Double.pi / 3 // ~1 o'clock
            hand.addLine(to: CGPoint(
                x: center.x + cos(handAngle) * radius * 0.5,
                y: center.y + sin(handAngle) * radius * 0.5
            ))
            context.stroke(hand, with: .foreground, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

            // Center dot
            let centerDot = CGRect(x: center.x - 1, y: center.y - 1, width: 2, height: 2)
            context.fill(Path(ellipseIn: centerDot), with: .foreground)
        }
        .frame(width: 16, height: 16)
    }
}
