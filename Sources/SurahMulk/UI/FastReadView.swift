import Combine
import Foundation
import SwiftUI

/// Steps through the surah word by word at a chosen rate.
final class FastReader: ObservableObject {
    @Published var index = 0
    @Published var playing = false
    @Published var rate: Double = 1.0

    private var timer: Timer?
    private(set) var words: [Word] = []

    func load(_ words: [Word]) {
        stop()
        self.words = words
        index = 0
    }

    var current: Word? {
        guard index < words.count else { return nil }
        return words[index]
    }

    var finished: Bool { !words.isEmpty && index >= words.count }

    func toggle() {
        playing ? pause() : play()
    }

    func play() {
        guard !words.isEmpty else { return }
        if finished { index = 0 }
        playing = true
        schedule()
    }

    func pause() {
        playing = false
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        pause()
        index = 0
    }

    func step(_ delta: Int) {
        index = max(0, min(words.count - 1, index + delta))
    }

    private func schedule() {
        timer?.invalidate()
        let interval = max(0.06, 0.45 / rate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.index + 1 >= self.words.count {
                self.pause()
                self.index = self.words.count
                NotificationCenter.default.post(name: .fastReadFinished, object: nil)
            } else {
                self.index += 1
            }
        }
    }
}

struct FastReadView: View {
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var state: AppState
    @EnvironmentObject var progress: ProgressStore
    @StateObject private var reader = FastReader()
    @State private var ayahOfIndex: [Int: Int] = [:]

    private let rates: [Double] = [0.5, 1, 1.5, 2, 3, 4]

    var body: some View {
        VStack(spacing: 0) {
            controls
            Divider()
            content
            Divider()
            footer
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear { loadSurah() }
        .onReceive(NotificationCenter.default.publisher(for: .fastReadFinished)) { _ in
            progress.markTodayDone()
        }
    }

    private func loadSurah() {
        var words: [Word] = []
        var map: [Int: Int] = [:]
        for ayah in store.ayahs {
            for word in ayah.words {
                map[words.count] = ayah.n
                words.append(word)
            }
        }
        ayahOfIndex = map
        reader.load(words)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Text("Fast read")
                .font(.headline)

            Button {
                reader.toggle()
            } label: {
                Image(systemName: reader.playing ? "pause.fill" : "play.fill")
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .keyboardShortcut(.space, modifiers: [])

            Button { reader.step(-1) } label: { Image(systemName: "backward.end") }
                .buttonStyle(.bordered)
            Button { reader.step(1) } label: { Image(systemName: "forward.end") }
                .buttonStyle(.bordered)
            Button { reader.stop(); loadSurah() } label: { Image(systemName: "gobackward") }
                .buttonStyle(.bordered)
                .help("Restart")

            Spacer()

            ForEach(rates, id: \.self) { value in
                Button("\(formatted(value))×") {
                    reader.rate = value
                }
                .buttonStyle(.bordered)
                .fontWeight(reader.rate == value ? .bold : .regular)
                .tint(reader.rate == value ? .green : nil)
            }

            Slider(value: $reader.rate, in: 0.25...4, step: 0.25)
                .frame(width: 160)

            Text("\(Int(reader.rate * 100) / 100)×")
                .font(.callout.monospacedDigit())
                .frame(width: 44, alignment: .leading)
        }
        .padding(14)
        .background(.bar)
    }

    private func formatted(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.2g", value)
    }

    private var content: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(store.ayahs) { ayah in
                        ayahRow(ayah)
                            .id(ayah.n)
                    }
                }
                .padding(28)
                .frame(maxWidth: 940)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: reader.index) { _, _ in
                if let ayah = currentAyah {
                    proxy.scrollTo(ayah, anchor: .center)
                    state.readAyah = ayah
                }
            }
        }
    }

    private var currentAyah: Int? { ayahOfIndex[reader.index] }

    private func ayahRow(_ ayah: Ayah) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ayah.ar)
                .font(.system(size: state.arabicSize, weight: .medium))
                .lineSpacing(12)
                .environment(\.layoutDirection, .rightToLeft)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Text("\(ayah.n)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(ayah.en)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(currentAyah == ayah.n ? Color.green.opacity(0.14) : Color.secondary.opacity(0.2))
        )
    }

    private var footer: some View {
        HStack(spacing: 14) {
            Text(progress.todayDone ? "Today done ✓" : "Finish a run to mark today read")
                .font(.callout)
                .foregroundStyle(progress.todayDone ? .green : .secondary)

            Spacer()

            if let word = reader.current {
                Text(word.tr)
                    .font(.headline)
                Text(word.en)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text(word.ar)
                    .font(.title3)
                    .environment(\.layoutDirection, .rightToLeft)
            } else if reader.finished {
                Label("Finished — today marked read", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }

            Text("\(min(reader.index, reader.words.count)) / \(reader.words.count)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.bar)
    }
}

extension Notification.Name {
    static let fastReadFinished = Notification.Name("fastReadFinished")
}
