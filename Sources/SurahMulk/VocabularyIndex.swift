import Foundation

/// Unique word forms of the surah with every occurrence — powers the Vocabulary view.
struct VocabularyIndex {
    struct Occurrence: Identifiable, Hashable {
        let ayah: Int
        let index: Int
        let word: Word
        var id: String { "\(ayah)-\(index)" }
    }

    struct Entry: Identifiable, Hashable {
        let form: String
        let count: Int
        let occurrences: [Occurrence]
        var id: String { form }
        var ayah: Int { occurrences.first?.ayah ?? 1 }
        var word: Word { occurrences.first?.word ?? Word(ar: form, en: "", tr: "", audio: "") }
    }

    let entries: [Entry]
    let total: Int
    let repeatedCount: Int
    let top: [Entry]

    init(ayahs: [Ayah]) {
        var buckets: [String: [Occurrence]] = [:]
        var order: [String] = []

        for ayah in ayahs {
            for (index, word) in ayah.words.enumerated() {
                let form = VocabularyIndex.form(of: word.ar)
                if buckets[form] == nil {
                    order.append(form)
                    buckets[form] = []
                }
                buckets[form]?.append(Occurrence(ayah: ayah.n, index: index, word: word))
            }
        }

        let built = order.map { form -> Entry in
            let occurrences = buckets[form] ?? []
            return Entry(form: form, count: occurrences.count, occurrences: occurrences)
        }

        entries = built.sorted { lhs, rhs in
            lhs.count == rhs.count ? lhs.form < rhs.form : lhs.count > rhs.count
        }
        total = built.reduce(0) { $0 + $1.count }
        repeatedCount = total - built.count
        top = built.sorted { $0.count > $1.count }.prefix(8).map { $0 }
        _ = buckets
    }

    /// Canonical form: alef-wasla normalised, vowel marks removed (333 → 224 unique).
    static func form(of word: String) -> String {
        let mapped = word.replacingOccurrences(of: "ٱ", with: "ا")
        return mapped.filter { ($0.unicodeScalars.first?.value).map { (0x0621...0x064A).contains($0) } ?? false }
    }

    func entry(forForm form: String) -> Entry? {
        entries.first { $0.form == form }
    }

    func entry(at index: Int) -> Entry? {
        guard !entries.isEmpty else { return nil }
        let clamped = ((index % entries.count) + entries.count) % entries.count
        return entries[clamped]
    }
}
