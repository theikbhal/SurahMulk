import SwiftUI

struct HelpView: View {
    private struct QA: Identifiable {
        let id = UUID()
        let q: String
        let a: String
    }

    private let questions: [QA] = [
        QA(
            q: "What is the daily minimum?",
            a: "Open Quick Pass and look through the last three lines, then press “Pass — mark today done”. That keeps the streak alive. A full read, a fast-read run or a drill also counts."
        ),
        QA(
            q: "When do I get the reminder?",
            a: "By default at 7:00 PM every day. Change it to 4:00 PM, both, or off in Streaks → Daily reminder, or in Settings (gear icon). macOS delivers it even when the app is closed."
        ),
        QA(
            q: "How does the streak work?",
            a: "One mark per day you read anything. Streaks counts consecutive days; the calendar shows every mark; “Days read” is the lifetime total."
        ),
        QA(
            q: "How is the memorise plan scheduled?",
            a: "One ayah per month, starting with the month you begin. Mark an ayah “Memorised” and revisions are scheduled for +7, +30 and +90 days — tick them off as you revise."
        ),
        QA(
            q: "What is the word of the day?",
            a: "The Vocabulary tab assigns one of the 224 unique word forms to each day, with a status (new / learning / known) and a +1, +7, +30 revision plan. The track view shows your assigned dates."
        ),
        QA(
            q: "What do the vocabulary numbers mean?",
            a: "333 total word occurrences, 224 unique word forms and 109 repeated occurrences (333 − 224). Tap a repeated word to see every ayah it appears in."
        ),
        QA(
            q: "What is in the Grammar tab?",
            a: "Every word with its root, attached prefixes and suffixes, i‘rāb (syntax) and ṣarf (form), plus a root-frequency cloud over the whole surah."
        ),
        QA(
            q: "Which translations are included?",
            a: "Saheeh (English), Maulana Muhammad Junagarhi (Urdu) and Maulana Abder-Rahim (Telugu), all bundled offline. Translations → “Side by side” compares all three."
        ),
        QA(
            q: "What are Video and Quran.com?",
            a: "Video plays the Sheikh Sudais recitation of Surah Al-Mulk (YouTube). Quran.com is a live in-app browser on quran.com/al-mulk."
        ),
        QA(
            q: "Does the app track me?",
            a: "No. Everything — readings, streaks, plans, settings — stays in local files on your Mac. No account, no analytics, reading works offline."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Help")
                        .font(.title2.bold())
                    Text("Surah Mulk · read, memorise, and keep the chain.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 4)

                ForEach(questions) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.q)
                            .font(.headline)
                        Text(item.a)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.25)))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Keyboard")
                        .font(.headline)
                    Text("⌘1–⌘9 switch the first nine tabs · ⌘⇧O replay onboarding · ␣ play/pause in Fast Read · ⌘↩ mark today done in Quick Pass")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.25)))

                Text("More docs: README.md · docs/INSTALL.md · docs/DEVELOPMENT.md in the repository.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(28)
            .frame(maxWidth: 820)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}
