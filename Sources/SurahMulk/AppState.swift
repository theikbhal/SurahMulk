import Foundation
import SwiftUI

final class AppState: ObservableObject {
    enum Tab: String, CaseIterable, Identifiable {
        case read, quickPass, streaks, memorise, vocab, grammar, translations, learn, fastRead, video, quranWeb, help
        var id: String { rawValue }

        var title: String {
            switch self {
            case .read: "Read"
            case .quickPass: "Quick Pass"
            case .streaks: "Streaks"
            case .memorise: "Memorise"
            case .vocab: "Vocabulary"
            case .grammar: "Grammar"
            case .translations: "Translations"
            case .learn: "Hadith & Benefits"
            case .fastRead: "Fast Read"
            case .video: "Video"
            case .quranWeb: "Quran.com"
            case .help: "Help"
            }
        }

        var symbol: String {
            switch self {
            case .read: "book.fill"
            case .quickPass: "clock.badge.checkmark"
            case .streaks: "flame.fill"
            case .memorise: "brain.head.profile"
            case .vocab: "textformat.abc"
            case .grammar: "point.3.connected.trianglepath.dotted"
            case .translations: "character.bubble"
            case .learn: "scroll.fill"
            case .fastRead: "gauge.with.needle"
            case .video: "play.rectangle.fill"
            case .quranWeb: "globe"
            case .help: "questionmark.circle"
            }
        }
    }

    enum Reminder: String, CaseIterable, Identifiable {
        case off, fourPM, sevenPM, both
        var id: String { rawValue }

        var title: String {
            switch self {
            case .off: "Off"
            case .fourPM: "4:00 PM"
            case .sevenPM: "7:00 PM"
            case .both: "4:00 PM + 7:00 PM"
            }
        }
    }

    @Published var tab: Tab = .read
    @Published var showOnboarding: Bool
    @Published var showOnboardingAgain: Bool {
        didSet { UserDefaults.standard.set(showOnboardingAgain, forKey: Keys.onboardingRepeat) }
    }

    @Published var arabicSize: Double {
        didSet { UserDefaults.standard.set(arabicSize, forKey: Keys.arabicSize) }
    }

    @Published var reminder: Reminder {
        didSet {
            UserDefaults.standard.set(reminder.rawValue, forKey: Keys.reminder)
            ReminderManager.shared.apply(reminder)
        }
    }

    @Published var readAyah: Int {
        didSet { UserDefaults.standard.set(readAyah, forKey: Keys.readAyah) }
    }

    private enum Keys {
        static let onboardingDone = "onboarding.done"
        static let onboardingRepeat = "onboarding.repeat"
        static let arabicSize = "reader.arabicSize"
        static let reminder = "reader.reminder"
        static let readAyah = "reader.lastAyah"
    }

    init() {
        let defaults = UserDefaults.standard
        let repeatOnboarding = defaults.bool(forKey: Keys.onboardingRepeat)
        showOnboardingAgain = repeatOnboarding
        showOnboarding = !defaults.bool(forKey: Keys.onboardingDone) || repeatOnboarding

        let size = defaults.double(forKey: Keys.arabicSize)
        arabicSize = size == 0 ? 30 : size

        reminder = Reminder(rawValue: defaults.string(forKey: Keys.reminder) ?? "") ?? .sevenPM

        let last = defaults.integer(forKey: Keys.readAyah)
        readAyah = last == 0 ? 1 : last
    }

    func finishOnboarding() {
        UserDefaults.standard.set(!showOnboardingAgain, forKey: Keys.onboardingDone)
        withAnimation(.easeInOut(duration: 0.25)) { showOnboarding = false }
        ReminderManager.shared.apply(reminder)
    }
}
