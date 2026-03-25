import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentStep: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Group {
                switch currentStep {
                case 0:
                    welcomeStep
                case 1:
                    connectCalendarStep
                default:
                    doneStep
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(currentStep)

            Spacer()

            stepIndicator

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            HStack {
                Spacer()
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .accessibilityLabel("Quit Ticker")
            }
        }
        // Auto-advance from step 1 when OAuth completes
        .onChange(of: viewModel.googleService.accounts.isEmpty) { isEmpty in
            if !isEmpty && currentStep == 1 {
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentStep = 2
                }
            }
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                Image(systemName: "timer")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(.white.opacity(0.8))
            }

            VStack(spacing: 8) {
                Text("Welcome to Ticker")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Your next meeting, always in sight.\nLive countdown in your menu bar.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentStep = 1
                }
            } label: {
                Text("Get Started")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: 220)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Step 1: Connect Calendar

    private var connectCalendarStep: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.2), .teal.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(.green.opacity(0.8))
            }

            VStack(spacing: 8) {
                Text("Connect Your Calendar")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Sign in with Google to see your\nmeetings in the menu bar.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(spacing: 12) {
                Button {
                    viewModel.addAccount()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Sign in with Google")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: 220)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        currentStep = 2
                    }
                } label: {
                    Text("Skip for now")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Step 2: Done

    private var doneStep: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.25), .green.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.green.opacity(0.85))
            }

            VStack(spacing: 8) {
                Text("You're all set!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Ticker is running in your menu bar.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }

            featureList

            Button {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                withAnimation(.easeInOut(duration: 0.25)) {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Start Using Ticker")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: 220)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Feature List

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Free features
            featureRow(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                label: "Live countdown timer",
                isPro: false
            )
            featureRow(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                label: "One-click meeting join",
                isPro: false
            )
            featureRow(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                label: "Calendar day view",
                isPro: false
            )

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
                .padding(.vertical, 2)

            // Pro features
            featureRow(
                icon: "lock.fill",
                iconColor: .white.opacity(0.25),
                label: "Multiple accounts",
                isPro: true
            )
            featureRow(
                icon: "lock.fill",
                iconColor: .white.opacity(0.25),
                label: "Notifications",
                isPro: true
            )
            featureRow(
                icon: "lock.fill",
                iconColor: .white.opacity(0.25),
                label: "Day navigation",
                isPro: true
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
        )
    }

    private func featureRow(icon: String, iconColor: Color, label: String, isPro: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(iconColor)
                .frame(width: 18)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(isPro ? .white.opacity(0.35) : .white.opacity(0.75))
            if isPro {
                Spacer()
                ProBadge()
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(index == currentStep ? Color.blue : Color.white.opacity(0.2))
                    .frame(width: index == currentStep ? 18 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: currentStep)
            }
        }
        .padding(.bottom, 12)
    }
}
