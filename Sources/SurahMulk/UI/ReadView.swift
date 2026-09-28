import SwiftUI

struct ReadView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var progress: ProgressStore
    @ObservedObject private var audio = AyahAudio.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header

                    ForEach(store.ayahs) { ayah in
                        ayahBlock(ayah)
                            .id(ayah.n)
                    }
                }
                .padding(30)
                .frame(maxWidth: 880, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .safeAreaInset(edge: .top) { toolbar }
            .background(Color(nsColor: .textBackgroundColor))
            .onAppear {
                proxy.scrollTo(state.readAyah, anchor: .top)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Surah Al-Mulk")
                        .font(.largeTitle.bold())
                    Text("سُورَةُ ٱلْمُلْك · \(store.data.revelation) · \(store.data.totalAyahs) ayahs · Makkan")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(store.data.nameArabic)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(.green)
            }

            Text(store.data.basmala)
                .font(.system(size: 30, weight: .semibold))
                .frame(maxWidth: .infinity)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.vertical, 6)
        }
        .padding(.bottom, 4)
    }

    private var toolbar: some View {
        HStack(spacing: 10) {
            Text("Arabic size")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                state.arabicSize = max(18, state.arabicSize - 2)
            } label: { Image(systemName: "minus.magnifyingglass") }
                .buttonStyle(.bordered)
                .disabled(state.arabicSize <= 18)
            Text("\(Int(state.arabicSize))")
                .font(.callout.monospacedDigit())
                .frame(width: 34)
            Button {
                state.arabicSize = min(72, state.arabicSize + 2)
            } label: { Image(systemName: "plus.magnifyingglass") }
                .buttonStyle(.bordered)
                .disabled(state.arabicSize >= 72)

            Spacer()

            if progress.todayDone {
                Label("Read today", systemImage: "checkmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.green)
            } else {
                Button {
                    progress.markTodayDone()
                } label: {
                    Label("Mark today read", systemImage: "checkmark.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func ayahBlock(_ ayah: Ayah) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ayah.ar)
                .font(.system(size: state.arabicSize, weight: .medium))
                .lineSpacing(14)
                .environment(\.layoutDirection, .rightToLeft)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                Button {
                    audio.toggle(ayah.audio, key: "ayah-\(ayah.n)")
                } label: {
                    Image(systemName: audio.isPlaying("ayah-\(ayah.n)") ? "stop.fill" : "play.fill")
                        .font(.caption)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(.green.opacity(0.85)))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .help("Play this ayah (al-Afasy)")

                Text("\(ayah.n)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 18)

                VStack(alignment: .leading, spacing: 6) {
                    Text(ayah.en)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(ayah.words.map(\.tr).filter { !$0.isEmpty }.joined(separator: " "))
                        .font(.callout.italic())
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(state.readAyah == ayah.n ? Color.green.opacity(0.12) : Color.secondary.opacity(0.25))
        )
        .onTapGesture {
            state.readAyah = ayah.n
        }
    }
}
