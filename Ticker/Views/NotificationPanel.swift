import SwiftUI
import AppKit

// MARK: - Floating Panel (NSPanel subclass)

final class FloatingNotificationPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        isMovableByWindowBackground = false
        titlebarAppearsTransparent = true
        titleVisibility = .hidden

        // Don't show in dock, app switcher, or mission control
        collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle, .fullScreenAuxiliary]

        // Rounded corners on the window
        isReleasedWhenClosed = false
    }

    // Allow the panel to become key for button clicks
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - Notification Window Controller

final class NotificationWindowController: NSObject, ObservableObject {
    static let shared = NotificationWindowController()

    private var panel: FloatingNotificationPanel?
    private var dismissTimer: Timer?
    private var countdownTimer: Timer?

    @Published var currentEvent: CalendarEvent?
    @Published var secondsRemaining: Int = 0
    @Published var leadMinutes: Int = 0

    private override init() {
        super.init()
    }

    func show(event: CalendarEvent, leadMinutes: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.currentEvent = event
            self.leadMinutes = leadMinutes

            // Calculate seconds until meeting starts
            let diff = event.startDate.timeIntervalSinceNow
            self.secondsRemaining = max(Int(ceil(diff)), 0)

            // Create or update panel
            self.setupPanel(event: event, leadMinutes: leadMinutes)

            // Start countdown
            self.startCountdown()

            // Auto-dismiss: 30s for 1-min warning, 8s for others
            let dismissDelay: TimeInterval = leadMinutes <= 1 ? 30 : 8
            self.dismissTimer?.invalidate()
            self.dismissTimer = Timer.scheduledTimer(withTimeInterval: dismissDelay, repeats: false) { [weak self] _ in
                self?.dismiss()
            }
        }
    }

    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let panel = self.panel else { return }

            self.dismissTimer?.invalidate()
            self.countdownTimer?.invalidate()

            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                panel.animator().alphaValue = 0
            }, completionHandler: { [weak self] in
                panel.orderOut(nil)
                panel.alphaValue = 1
                self?.currentEvent = nil
            })
        }
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let event = self.currentEvent else {
                self?.countdownTimer?.invalidate()
                return
            }
            let diff = event.startDate.timeIntervalSinceNow
            self.secondsRemaining = max(Int(ceil(diff)), 0)

            if self.secondsRemaining <= 0 {
                self.countdownTimer?.invalidate()
            }
        }
    }

    private func setupPanel(event: CalendarEvent, leadMinutes: Int) {
        // Position: top-right of main screen
        guard let screen = NSScreen.main else { return }
        let panelWidth: CGFloat = 340
        let panelHeight: CGFloat = 100
        let padding: CGFloat = 16

        let x = screen.visibleFrame.maxX - panelWidth - padding
        let y = screen.visibleFrame.maxY - panelHeight - padding

        let frame = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)

        if panel == nil {
            panel = FloatingNotificationPanel(contentRect: frame)
        } else {
            panel?.setFrame(frame, display: false)
        }

        let bannerView = NotificationBannerView(controller: self)
        let hostingView = NSHostingView(rootView: bannerView)
        hostingView.frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)

        panel?.contentView = hostingView

        // Animate in
        panel?.alphaValue = 0
        panel?.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel?.animator().alphaValue = 1
        }
    }
}

// MARK: - Notification Banner SwiftUI View

struct NotificationBannerView: View {
    @ObservedObject var controller: NotificationWindowController

    var body: some View {
        Group {
            if let event = controller.currentEvent {
                bannerContent(event: event)
            }
        }
    }

    private func bannerContent(event: CalendarEvent) -> some View {
        HStack(spacing: 12) {
            // Left: Color bar + countdown
            VStack(spacing: 2) {
                // Countdown circle
                ZStack {
                    Circle()
                        .stroke(event.calendarColor.opacity(0.2), lineWidth: 2.5)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: countdownProgress)
                        .stroke(event.calendarColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: controller.secondsRemaining)

                    VStack(spacing: 0) {
                        Text(countdownText)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                        if controller.secondsRemaining > 60 {
                            Text("min")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("sec")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Center: Event info
            VStack(alignment: .leading, spacing: 4) {
                Text(controller.secondsRemaining <= 0 ? "NOW" : "UPCOMING")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(controller.secondsRemaining <= 60 ? event.calendarColor : .secondary)
                    .tracking(1)

                Text(event.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Text(event.timeRangeLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            // Right: Actions
            VStack(spacing: 6) {
                if let url = event.meetingURL {
                    Button {
                        NSWorkspace.shared.open(url)
                        controller.dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 10))
                            Text("Join")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(event.calendarColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    controller.dismiss()
                } label: {
                    Text("Dismiss")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow)
                event.calendarColor.opacity(0.05)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
    }

    private var countdownText: String {
        let secs = controller.secondsRemaining
        if secs <= 0 { return "0" }
        if secs > 60 {
            return "\(Int(ceil(Double(secs) / 60)))"
        }
        return "\(secs)"
    }

    private var countdownProgress: CGFloat {
        let secs = controller.secondsRemaining
        if secs <= 0 { return 0 }
        let total = Double(controller.leadMinutes * 60)
        guard total > 0 else { return 0 }
        return CGFloat(Double(secs) / total)
    }
}
