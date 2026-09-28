import SwiftUI

struct SettingsPane: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Settings")
                    .font(.title2.bold())
                Spacer()
                Button("Close") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }

            GroupBox("Reader") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Arabic font size")
                        Slider(value: $state.arabicSize, in: 18...72, step: 2)
                        Text("\(Int(state.arabicSize))")
                            .monospacedDigit()
                            .frame(width: 34, alignment: .trailing)
                    }
                }
                .padding(6)
            }

            GroupBox("Daily reminder") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Remind me at", selection: $state.reminder) {
                        ForEach(AppState.Reminder.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Notifications are delivered by macOS even when the app is closed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(6)
            }

            GroupBox("Progress") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Streak \(progress.currentStreak) · best \(progress.bestStreak) · \(progress.doneCount) days read · \(progress.memorisedCount) ayat memorised")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button("Replay onboarding") {
                            state.showOnboardingAgain = true
                            state.showOnboarding = true
                            dismiss()
                        }

                        Spacer()

                        Button("Reset all progress", role: .destructive) {
                            confirmReset = true
                        }
                        .alert("Reset all progress?", isPresented: $confirmReset) {
                            Button("Reset", role: .destructive) {
                                progress.reset()
                                dismiss()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Streak, calendar marks, memorise plan and word-of-the-day tracking will be erased.")
                        }
                    }
                }
                .padding(6)
            }

            GroupBox("Links") {
                HStack {
                    Button("GitHub repository") {
                        open("https://github.com/theikbhal/SurahMulk")
                    }
                    Button("quran.com/al-mulk") {
                        open("https://quran.com/al-mulk")
                    }
                    Spacer()
                    Text("v1.0.0 · MIT")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(6)
            }

            Spacer()
        }
        .padding(20)
    }

    private func open(_ string: String) {
        if let url = URL(string: string) {
            NSWorkspace.shared.open(url)
        }
    }
}
