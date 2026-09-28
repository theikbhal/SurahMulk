import SwiftUI

/// The daily minimum: the last three lines (ayat) you were on, in big type.
struct QuickPassView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var progress: ProgressStore
    @ObservedObject private var audio = AyahAudio.shared
    @State private var anchor = 3

    private var window: ClosedRange<Int> {
        let end = max(1, min(store.data.totalAyahs, anchor))
        return max(1, end - 2)...end
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(Array(window), id: \.self) { n in
                        if let ayah = store.ayah(n) {
                            line(ayah)
                        }
                    }
                }
                .padding(34)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
            }
            Divider()
            footer
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear { anchor = max(3, state.readAyah) }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Pass · last 3 lines")
                    .font(.title2.bold())
                Text("Your daily minimum — a pass through these three keeps the streak alive.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label("Streak \(progress.currentStreak)", systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(.orange)
        }
        .padding(20)
        .background(.bar)
    }

    private var footer: some View {
        HStack(spacing: 14) {
            Button {
                anchor = max(3, window.lowerBound - 1)
            } label: { Label("Previous", systemImage: "chevron.left") }
                .buttonStyle(.bordered)
                .disabled(window.lowerBound <= 1)

            Text("Ayat \(window.lowerBound)–\(window.upperBound) of \(store.data.totalAyahs)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)

            Button {
                anchor = min(store.data.totalAyahs, window.upperBound + 1)
                state.readAyah = window.upperBound
            } label: { Label("Next", systemImage: "chevron.right") }
                .buttonStyle(.bordered)
                .disabled(window.upperBound >= store.data.totalAyahs)

            Spacer()

            if progress.todayDone {
                Label("Today's pass done", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else {
                Button {
                    progress.markTodayDone()
                } label: {
                    Label("Pass — mark today done", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(16)
        .background(.bar)
    }

    private func line(_ ayah: Ayah) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ayah.ar)
                .font(.system(size: state.arabicSize + 6, weight: .semibold))
                .lineSpacing(16)
                .environment(\.layoutDirection, .rightToLeft)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                Button {
                    audio.toggle(ayah.audio, key: "quick-\(ayah.n)")
                } label: {
                    Image(systemName: audio.isPlaying("quick-\(ayah.n)") ? "stop.fill" : "play.fill")
                        .font(.caption)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(.green))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                Text("\(ayah.n)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)

                Text(ayah.en)
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.quaternary.opacity(0.25)))
        .onTapGesture {
            state.readAyah = ayah.n
            anchor = ayah.n
        }
    }
}
