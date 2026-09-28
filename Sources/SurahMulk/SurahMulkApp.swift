import SwiftUI

@main
struct SurahMulkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = AppState()
    @StateObject private var store = SurahStore()
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(state)
                    .environmentObject(store)
                    .environmentObject(progress)

                if state.showOnboarding {
                    OnboardingView()
                        .environmentObject(state)
                        .environmentObject(store)
                        .environmentObject(progress)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Color(nsColor: .windowBackgroundColor)
                                .ignoresSafeArea()
                        )
                        .transition(.opacity)
                }
            }
            .frame(minWidth: 960, minHeight: 640)
            .onReceive(NotificationCenter.default.publisher(for: .openTab)) { note in
                if let tab = note.object as? AppState.Tab {
                    state.tab = tab
                }
            }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Replay Onboarding") {
                    state.showOnboardingAgain = true
                    state.showOnboarding = true
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = ReminderManager.shared
        NSApp.setActivationPolicy(.regular)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
