import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var store: SurahStore
    @State private var page = 0
    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch page {
                case 0: welcome
                case 1: habit
                case 2: study
                default: watch
                }
            }
            .id(page)
            .transition(.opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Color.green : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 14)

            Divider()

            HStack {
                Toggle(isOn: $state.showOnboardingAgain) {
                    Text("Show this onboarding on next launch")
                        .font(.callout)
                }
                .toggleStyle(.checkbox)

                Spacer()

                if page > 0 {
                    Button("Back") { page -= 1 }
                        .buttonStyle(.bordered)
                }

                if page < pageCount - 1 {
                    Button("Next") { page += 1 }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button("Open the surah") { state.finishOnboarding() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(18)
        }
        .frame(width: 660, height: 540)
    }

    // MARK: - Pages

    private var welcome: some View {
        VStack(spacing: 14) {
            pageHeader("book.fill", "Surah Al-Mulk", "\(store.data.nameArabic) · 30 ayahs · Makkan")

            Text(store.data.nameArabic)
                .font(.system(size: 76, weight: .semibold))
                .foregroundStyle(.green)

            Text("“Indeed there is a surah in the Qur'an of thirty verses which intercedes for a person until he is forgiven.”")
                .font(.callout.italic())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 54)

            Text("Read it in Uthmani script with English, Urdu and Telugu translations — and keep a daily chain.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 54)
        }
    }

    private var habit: some View {
        VStack(spacing: 16) {
            pageHeader("flame.fill", "Your daily habit", "A five-minute chain, protected by a reminder")

            HStack(spacing: 14) {
                card("clock.badge.checkmark", "Quick Pass", "the last 3 lines — your daily minimum")
                card("bell.badge", "7:00 PM", "daily reminder, changeable to 4 PM")
                card("flame.fill", "Streak", "calendar view of every day you read")
            }

            VStack(alignment: .leading, spacing: 10) {
                point("Press “Pass” in Quick Pass to mark the day, or finish a full read.")
                point("Streaks shows your current run, best run and month calendar.")
                point("You can change the reminder time any time in Streaks or Settings.")
            }
            .padding(.horizontal, 46)
        }
    }

    private var study: some View {
        VStack(spacing: 16) {
            pageHeader("brain.head.profile", "Study tools", "Memorise, vocabulary, grammar and translations")

            HStack(spacing: 12) {
                card("brain.head.profile", "Memorise", "one ayah per month + 7/30/90 day revisions")
                card("textformat.abc", "Vocabulary", "333 words · 224 unique · one word per day")
                card("character.bubble", "Translations", "English · اردو · తెలుగు")
            }

            VStack(alignment: .leading, spacing: 10) {
                point("The Grammar tab shows roots, affixes and i‘rāb for every word.")
                point("Fast Read steps through all 333 words at 0.25×–4×.")
                point("Track views assign dates and schedule your revisions.")
            }
            .padding(.horizontal, 46)
        }
    }

    private var watch: some View {
        VStack(spacing: 16) {
            pageHeader("play.rectangle.fill", "Watch & browse", "Recitation video and quran.com")

            HStack(spacing: 14) {
                card("play.circle.fill", "Video", "Surah Al-Mulk by Sheikh Sudais (YouTube)")
                card("globe", "Quran.com", "live page quran.com/al-mulk")
                card("questionmark.circle", "Help", "full Q&A inside the app")
            }

            VStack(alignment: .leading, spacing: 10) {
                point("Everything is offline — only audio, video and the web tab need the internet.")
                point("No account, no analytics: your streaks and plans live on this Mac only.")
            }
            .padding(.horizontal, 46)
        }
    }

    // MARK: - Pieces

    private func pageHeader(_ symbol: String, _ title: String, _ subtitle: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 42))
                .foregroundStyle(.green)
            Text(title).font(.title2.bold())
            Text(subtitle).font(.callout).foregroundStyle(.secondary)
        }
        .padding(.top, 26)
        .frame(maxWidth: .infinity)
    }

    private func card(_ symbol: String, _ title: String, _ detail: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title)
                .foregroundStyle(.green)
            Text(title).font(.callout.weight(.semibold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }

    private func point(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.callout)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
