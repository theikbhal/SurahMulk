import Foundation

final class ProgressStore: ObservableObject {
    struct MemoriseEntry: Codable, Hashable {
        var assigned: String
        var status: String // planned | learning | memorised
        var memorisedOn: String?
        var revisionsDone: [Int]
    }

    struct VocabEntry: Codable, Hashable {
        var day: String
        var wordIndex: Int
        var status: String // new | learning | known
        var revisionsDone: [Int]
    }

    @Published private(set) var dailyDone: Set<String>
    @Published private(set) var memorise: [String: MemoriseEntry]
    @Published private(set) var vocab: [String: VocabEntry]

    let memoRevisionOffsets = [7, 30, 90]
    let vocabRevisionOffsets = [1, 7, 30]

    private let planStart: String
    private var wordCount = 224

    private static let file: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("SurahMulk")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("progress.json")
    }()

    private struct Snapshot: Codable {
        var dailyDone: [String] = []
        var memorise: [String: MemoriseEntry] = [:]
        var vocab: [String: VocabEntry] = [:]
        var planStart: String = ""
    }

    init() {
        let snapshot = (try? JSONDecoder().decode(
            Snapshot.self,
            from: Data(contentsOf: ProgressStore.file)
        )) ?? Snapshot()

        dailyDone = Set(snapshot.dailyDone)
        memorise = snapshot.memorise
        vocab = snapshot.vocab
        planStart = snapshot.planStart.isEmpty ? ProgressStore.dayString(Date()) : snapshot.planStart
        save()
    }

    // MARK: - Dates

    static let dayFormat: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static let monthFormat: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func dayString(_ date: Date) -> String { dayFormat.string(from: date) }

    var today: String { ProgressStore.dayString(Date()) }

    private func date(of day: String) -> Date { ProgressStore.dayFormat.date(from: day) ?? Date() }

    private func addDays(_ day: String, _ days: Int) -> String {
        ProgressStore.dayString(Calendar.current.date(byAdding: .day, value: days, to: date(of: day)) ?? Date())
    }

    func daysBetween(_ from: String, _ to: String) -> Int {
        let comps = Calendar.current.dateComponents([.day], from: date(of: from), to: date(of: to))
        return comps.day ?? 0
    }

    // MARK: - Daily pass / streak

    var todayDone: Bool { dailyDone.contains(today) }

    func markTodayDone() {
        guard !todayDone else { return }
        dailyDone.insert(today)
        save()
    }

    var currentStreak: Int {
        var day = today
        if !dailyDone.contains(day) {
            day = addDays(day, -1)
            guard dailyDone.contains(day) else { return 0 }
        }
        var streak = 0
        while dailyDone.contains(day) {
            streak += 1
            day = addDays(day, -1)
        }
        return streak
    }

    var bestStreak: Int {
        let days = dailyDone.sorted()
        var best = 0
        var run = 0
        var previous: String?
        for day in days {
            run = (previous != nil && daysBetween(previous!, day) == 1) ? run + 1 : 1
            best = max(best, run)
            previous = day
        }
        return best
    }

    var doneCount: Int { dailyDone.count }

    func isDone(_ day: String) -> Bool { dailyDone.contains(day) }

    /// Days with activity inside a month, keyed "yyyy-MM-dd".
    func daysDone(inMonth month: String) -> Set<String> {
        Set(dailyDone.filter { $0.hasPrefix(month) })
    }

    /// Ayahs marked memorised.
    var memorisedCount: Int { memorise.values.filter { $0.status == "memorised" }.count }

    var knownWords: Int { vocab.values.filter { $0.status == "known" }.count }

    // MARK: - Memorise plan: one ayah per month

    /// First day of the month the given ayah is assigned to (ayah 1 = plan start month).
    func assignedDay(forAyah n: Int) -> String {
        var comps = DateComponents()
        comps.day = 1
        let base = date(of: planStart)
        let startMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: base)) ?? base
        let offset = max(0, n - 1)
        let monthDate = Calendar.current.date(byAdding: .month, value: offset, to: startMonth) ?? startMonth
        let first = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: monthDate)) ?? monthDate
        return ProgressStore.dayString(first)
    }

    func memoriseEntry(forAyah n: Int) -> MemoriseEntry {
        if let entry = memorise[String(n)] { return entry }
        let entry = MemoriseEntry(assigned: assignedDay(forAyah: n), status: "planned", memorisedOn: nil, revisionsDone: [])
        return entry
    }

    func setMemorise(_ status: String, ayah: Int) {
        var entry = memoriseEntry(forAyah: ayah)
        entry.status = status
        if status == "memorised" && entry.memorisedOn == nil {
            entry.memorisedOn = today
            entry.revisionsDone = []
        }
        if status != "memorised" {
            entry.memorisedOn = nil
        }
        memorise[String(ayah)] = entry
        save()
    }

    func memoriseRevisionDays(ayah: Int) -> [String] {
        guard let on = memoriseEntry(forAyah: ayah).memorisedOn else { return [] }
        return memoRevisionOffsets.map { addDays(on, $0) }
    }

    func toggleMemoriseRevision(ayah: Int, offset: Int) {
        var entry = memoriseEntry(forAyah: ayah)
        if let idx = entry.revisionsDone.firstIndex(of: offset) {
            entry.revisionsDone.remove(at: idx)
        } else {
            entry.revisionsDone.append(offset)
        }
        memorise[String(ayah)] = entry
        save()
    }

    // MARK: - Vocabulary: one word per day

    func wordIndex(forDay day: String) -> Int {
        if let entry = vocab[day] { return entry.wordIndex }
        let offset = max(0, daysBetween(planStart, day))
        return wordCount > 0 ? offset % wordCount : 0
    }

    func vocabEntry(forDay day: String) -> VocabEntry {
        if let entry = vocab[day] { return entry }
        let offset = max(0, daysBetween(planStart, day))
        let index = wordCount > 0 ? offset % wordCount : 0
        return VocabEntry(day: day, wordIndex: index, status: "new", revisionsDone: [])
    }

    func ensureTodayWord(wordCount: Int) -> VocabEntry {
        self.wordCount = max(1, wordCount)
        if let entry = vocab[today] { return entry }
        let entry = vocabEntry(forDay: today)
        vocab[today] = entry
        save()
        return entry
    }

    func setVocab(_ status: String, day: String) {
        var entry = vocabEntry(forDay: day)
        entry.status = status
        vocab[day] = entry
        save()
    }

    func vocabRevisionDays(day: String) -> [String] {
        vocabRevisionOffsets.map { addDays(day, $0) }
    }

    func toggleVocabRevision(day: String, offset: Int) {
        var entry = vocabEntry(forDay: day)
        if let idx = entry.revisionsDone.firstIndex(of: offset) {
            entry.revisionsDone.remove(at: idx)
        } else {
            entry.revisionsDone.append(offset)
        }
        vocab[day] = entry
        save()
    }

    func reset() {
        dailyDone = []
        memorise = [:]
        vocab = [:]
        save()
    }

    // MARK: - Persistence

    private func save() {
        let snapshot = Snapshot(
            dailyDone: dailyDone.sorted(),
            memorise: memorise,
            vocab: vocab,
            planStart: planStart
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: ProgressStore.file)
    }
}
