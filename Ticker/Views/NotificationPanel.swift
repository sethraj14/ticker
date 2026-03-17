import SwiftUI
import AppKit

// MARK: - Floating Panel (NSPanel subclass)

final class FloatingNotificationPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
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

        collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle, .fullScreenAuxiliary]
        isReleasedWhenClosed = false
    }

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
            self.secondsRemaining = max(Int(ceil(event.startDate.timeIntervalSinceNow)), 0)

            self.setupPanel()
            self.startCountdown()

            // Auto-dismiss: 45s for 1-min warning, 12s for others
            let dismissDelay: TimeInterval = leadMinutes <= 1 ? 45 : 12
            self.dismissTimer?.invalidate()
            self.dismissTimer = Timer.scheduledTimer(withTimeInterval: dismissDelay, repeats: false) { [weak self] _ in
                self?.dismiss()
            }
        }
    }

    /// Test method — show notification immediately with a sample event
    func showTest() {
        let testEvent = CalendarEvent(
            id: "test-\(UUID().uuidString)",
            title: "Team Standup",
            startDate: Date.now.addingTimeInterval(120),
            endDate: Date.now.addingTimeInterval(1920),
            meetingURL: URL(string: "https://meet.google.com/test"),
            source: .google,
            calendarColor: .blue,
            attendees: ["John", "Alice"],
            location: nil,
            notes: nil
        )
        show(event: testEvent, leadMinutes: 2)
    }

    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let panel = self.panel else { return }

            self.dismissTimer?.invalidate()
            self.countdownTimer?.invalidate()

            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                panel.animator().alphaValue = 0
                // Slide up while fading
                var frame = panel.frame
                frame.origin.y += 20
                panel.animator().setFrame(frame, display: true)
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
                // Keep showing "NOW" for 5 more seconds then dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    self?.dismiss()
                }
                self.countdownTimer?.invalidate()
            }
        }
    }

    private func setupPanel() {
        guard let screen = NSScreen.main else { return }
        let panelWidth: CGFloat = 360
        let panelHeight: CGFloat = 140
        let padding: CGFloat = 20

        let x = screen.visibleFrame.maxX - panelWidth - padding
        let y = screen.visibleFrame.maxY - panelHeight - padding

        let frame = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)

        if panel == nil {
            panel = FloatingNotificationPanel(contentRect: frame)
        }

        let bannerView = NotificationBannerView(controller: self)
        let hostingView = NSHostingView(rootView: bannerView)
        hostingView.frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)

        panel?.contentView = hostingView

        // Start above and slide down
        var startFrame = frame
        startFrame.origin.y += 30
        panel?.setFrame(startFrame, display: false)
        panel?.alphaValue = 0
        panel?.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel?.animator().setFrame(frame, display: true)
            panel?.animator().alphaValue = 1
        }

        // Play notification sound
        NSSound(named: .init("Funk"))?.play()
    }
}

// MARK: - Banner View

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
        HStack(spacing: 0) {
            // Left: Countdown timer block
            countdownBlock(event: event)
                .frame(width: 90)

            // Divider line
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical, 16)

            // Right: Event info + actions
            VStack(alignment: .leading, spacing: 0) {
                // Header label
                HStack {
                    Circle()
                        .fill(event.calendarColor)
                        .frame(width: 6, height: 6)
                    Text(controller.secondsRemaining <= 0 ? "HAPPENING NOW" : "STARTING SOON")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(controller.secondsRemaining <= 0 ? .orange : .white.opacity(0.5))
                        .tracking(1.2)
                    Spacer()
                    // Close button
                    Button {
                        controller.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(width: 20, height: 20)
                            .background(.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)

                // Meeting title
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.bottom, 4)

                // Time range
                Text(event.timeRangeLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 12)

                // Join button — always visible
                if let url = event.meetingURL {
                    Button {
                        NSWorkspace.shared.open(url)
                        controller.dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 11))
                            Text("Join Meeting")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [event.calendarColor, event.calendarColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                } else {
                    // No meeting URL — show time info instead
                    Text("No meeting link available")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Dark glass background
                VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow)
                // Dark overlay for better contrast
                Color.black.opacity(0.35)
                // Subtle accent glow at the top
                LinearGradient(
                    colors: [event.calendarColor.opacity(0.15), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 10)
    }

    // MARK: - Countdown Block

    private func countdownBlock(event: CalendarEvent) -> some View {
        VStack(spacing: 4) {
            if controller.secondsRemaining <= 0 {
                // NOW state
                Text("NOW")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
            } else if controller.secondsRemaining <= 60 {
                // Seconds countdown
                Text("\(controller.secondsRemaining)")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: controller.secondsRemaining)

                Text("seconds")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            } else {
                // Minutes countdown
                let mins = Int(ceil(Double(controller.secondsRemaining) / 60))
                Text("\(mins)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(mins == 1 ? "minute" : "minutes")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.1))
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            controller.secondsRemaining <= 60
                                ? Color.orange
                                : event.calendarColor
                        )
                        .frame(width: geo.size.width * countdownProgress, height: 3)
                        .animation(.linear(duration: 1), value: controller.secondsRemaining)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .padding(.vertical, 14)
    }

    private var countdownProgress: CGFloat {
        let secs = controller.secondsRemaining
        if secs <= 0 { return 0 }
        let total = Double(controller.leadMinutes * 60)
        guard total > 0 else { return 0 }
        return CGFloat(Double(secs) / total)
    }
}
