import SwiftUI

struct VocabView: View {
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var progress: ProgressStore
    @EnvironmentObject var state: AppState
    @State private var selectedForm: String? = nil
    @State private var todayIndex: Int = 0

    private var todayWord: VocabularyIndex.Entry? {
        store.vocabulary.entry(at: todayIndex)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stats
                if let word = todayWord {
                    wordOfTheDay(word)
                }
                track
                wordList
            }
            .padding(28)
            .frame(maxWidth: 940)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear {
            let entry = progress.ensureTodayWord(wordCount: store.vocabulary.entries.count)
            todayIndex = entry.wordIndex
        }
    }

    // MARK: - Stats

    private var stats: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Vocabulary")
                    .font(.title2.bold())
                Spacer()
                Text("one word every day")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                tile("\(store.data.stats.total)", "total occurrences", "text.alignleft")
                tile("\(store.data.stats.unique)", "unique word forms", "cube")
                tile("\(store.data.stats.repeated)", "repeated occurrences", "repeat")
            }

            FlowLayout(spacing: 8) {
                ForEach(store.vocabulary.top) { entry in
                    Button {
                        selectedForm = selectedForm == entry.form ? nil : entry.form
                    } label: {
                        Text("\(entry.form) ×\(entry.count)")
                            .font(.callout)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.green.opacity(selectedForm == entry.form ? 0.85 : 0.18)))
                            .foregroundStyle(selectedForm == entry.form ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if let form = selectedForm, let entry = store.vocabulary.entry(forForm: form) {
                occurrences(entry)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private func tile(_ value: String, _ label: String, _ symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(.green)
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.2)))
    }

    private func occurrences(_ entry: VocabularyIndex.Entry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(entry.form) · \(entry.count)×")
                .font(.headline)
            ForEach(entry.occurrences) { occ in
                Button {
                    state.readAyah = occ.ayah
                    state.tab = .read
                } label: {
                    Text("67:\(occ.ayah) — \(occ.word.tr) · \(occ.word.en)")
                        .font(.callout)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(.quaternary.opacity(0.2)))
    }

    // MARK: - Word of the day

    private func wordOfTheDay(_ entry: VocabularyIndex.Entry) -> some View {
        let day = progress.today
        let vocab = progress.vocabEntry(forDay: day)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Word of the day · \(day)")
                    .font(.headline)
                Spacer()
                Text("\(vocab.wordIndex % max(1, store.vocabulary.entries.count) + 1) / \(store.vocabulary.entries.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .center, spacing: 24) {
                VStack(spacing: 4) {
                    Text(entry.word.ar)
                        .font(.system(size: 54, weight: .semibold))
                        .environment(\.layoutDirection, .rightToLeft)
                    Text(entry.word.tr)
                        .font(.title3.italic())
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.word.en)
                        .font(.title3)
                    Text("root: \(entry.word.root.isEmpty ? "—" : entry.word.root) · appears \(entry.count)×")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Button("Open in Read") {
                        state.readAyah = entry.ayah
                        state.tab = .read
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                Picker("Status", selection: vocabStatus(day: day)) {
                    Text("New").tag("new")
                    Text("Learning").tag("learning")
                    Text("Known").tag("known")
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)

                Spacer()

                ForEach(Array(zip(progress.vocabRevisionOffsets, progress.vocabRevisionDays(day: day))), id: \.0) { offset, revisionDay in
                    let done = vocab.revisionsDone.contains(offset)
                    Button {
                        progress.toggleVocabRevision(day: day, offset: offset)
                    } label: {
                        Label("+\(offset)d", systemImage: done ? "checkmark.circle.fill" : "circle")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)
                    .tint(done ? .green : .secondary)
                    .help("Revision due \(revisionDay)")
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.green.opacity(0.10)))
    }

    private func vocabStatus(day: String) -> Binding<String> {
        Binding(
            get: { progress.vocabEntry(forDay: day).status },
            set: { progress.setVocab($0, day: day) }
        )
    }

    // MARK: - Track view

    private var track: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Track view · assigned dates")
                .font(.headline)

            ForEach(0..<14, id: \.self) { back in
                let day = back == 0 ? progress.today : dayOffset(-back)
                let vocab = progress.vocabEntry(forDay: day)
                let entry = store.vocabulary.entry(at: vocab.wordIndex)

                HStack(spacing: 12) {
                    Text(day)
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(day == progress.today ? .primary : .secondary)
                        .frame(width: 92, alignment: .leading)

                    Text(entry?.form ?? "—")
                        .font(.callout.weight(.semibold))
                        .frame(width: 110, alignment: .leading)

                    Text(entry?.word.en ?? "")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer()

                    Text(statusLabel(vocab.status))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(statusColor(vocab.status).opacity(0.2)))
                        .foregroundStyle(statusColor(vocab.status))

                    Text("\(vocab.revisionsDone.count)/\(progress.vocabRevisionOffsets.count) revisions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.15)))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    // MARK: - Word list

    private var wordList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("All \(store.vocabulary.entries.count) word forms")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 10)], spacing: 10) {
                ForEach(store.vocabulary.entries) { entry in
                    HStack(spacing: 8) {
                        Text(entry.word.ar)
                            .font(.system(size: 22, weight: .medium))
                            .environment(\.layoutDirection, .rightToLeft)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(entry.word.en.isEmpty ? entry.form : entry.word.en)
                                .font(.caption)
                                .lineLimit(1)
                            Text(entry.count > 1 ? "\(entry.count)× · repeats" : "single use")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.15)))
                    .onTapGesture {
                        selectedForm = entry.form
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    // MARK: - Helpers

    private func dayOffset(_ days: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return ProgressStore.dayString(date)
    }

    private func statusLabel(_ status: String) -> String {
        switch status {
        case "known": "Known"
        case "learning": "Learning"
        default: "New"
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "known": .green
        case "learning": .orange
        default: .secondary
        }
    }
}
