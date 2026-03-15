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

/// Custom menu bar icon — a minimalist clock with a tick mark
/// Renders as a template image (monochrome, adapts to light/dark)
struct TickerMenuBarIcon: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 1.5

            // Clock circle
            let circlePath = Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            context.stroke(circlePath, with: .foreground, lineWidth: 1.5)

            // Minute hand (pointing to 12 — the "tick" position)
            var minuteHand = Path()
            minuteHand.move(to: center)
            minuteHand.addLine(to: CGPoint(x: center.x, y: center.y - radius * 0.65))
            context.stroke(minuteHand, with: .foreground, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

            // Hour hand (pointing to ~2 o'clock)
            var hourHand = Path()
            hourHand.move(to: center)
            let hourAngle = Double.pi * 2 * (2.0 / 12.0) - Double.pi / 2
            hourHand.addLine(to: CGPoint(
                x: center.x + cos(hourAngle) * radius * 0.45,
                y: center.y + sin(hourAngle) * radius * 0.45
            ))
            context.stroke(hourHand, with: .foreground, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

            // Small tick dot at 12 o'clock
            let dotRadius: CGFloat = 1.2
            let dotY = center.y - radius + 3
            let dotRect = CGRect(x: center.x - dotRadius, y: dotY - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
            context.fill(Path(ellipseIn: dotRect), with: .foreground)
        }
        .frame(width: 16, height: 16)
    }
}
