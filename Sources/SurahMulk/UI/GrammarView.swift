import SwiftUI

struct GrammarView: View {
    @EnvironmentObject var store: SurahStore
    @State private var expanded: String? = nil
    @State private var ayahFilter = 0

    private var roots: [(root: String, count: Int)] {
        var counts: [String: Int] = [:]
        for ayah in store.ayahs {
            for word in ayah.words where !word.root.isEmpty {
                counts[word.root, default: 0] += 1
            }
        }
        return counts.map { (root: $0.key, count: $0.value) }.sorted { $0.count > $1.count }
    }

    private var filtered: [Ayah] {
        ayahFilter == 0 ? store.ayahs : store.ayahs.filter { $0.n == ayahFilter }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                rootCloud
                ayahPicker
                wordGrid
            }
            .padding(28)
            .frame(maxWidth: 980)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grammar · word morphology")
                .font(.title2.bold())
            Text("Every word of Al-Mulk with its root, attached prefixes and suffixes, i‘rāb (syntax) and ṣarf (form). Tap a word for the full analysis.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private var rootCloud: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Roots (\(roots.count))")
                .font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(roots, id: \.root) { item in
                    Text("\(item.root) ×\(item.count)")
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.green.opacity(0.18)))
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private var ayahPicker: some View {
        Picker("Ayah", selection: $ayahFilter) {
            Text("All").tag(0)
            ForEach(store.ayahs) { ayah in
                Text("\(ayah.n)").tag(ayah.n)
            }
        }
        .pickerStyle(.segmented)
    }

    private var wordGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(filtered) { ayah in
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ayah \(ayah.n)")
                        .font(.headline)
                        .foregroundStyle(.green)

                    FlowLayout(spacing: 10) {
                        ForEach(Array(ayah.words.enumerated()), id: \.offset) { index, word in
                            wordCard(ayah: ayah.n, index: index, word: word)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private func wordCard(ayah: Int, index: Int, word: Word) -> some View {
        let key = "\(ayah)-\(index)"
        let isOpen = expanded == key

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(word.ar)
                    .font(.system(size: 26, weight: .medium))
                if !word.root.isEmpty {
                    Text(word.root)
                        .font(.caption.monospaced())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.green.opacity(0.25)))
                }
            }

            Text(word.tr)
                .font(.caption)
                .foregroundStyle(.secondary)

            if isOpen {
                detail(word)
                    .environment(\.layoutDirection, .leftToRight)
            }
        }
        .padding(12)
        .frame(maxWidth: 340, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(isOpen ? .green.opacity(0.15) : Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) {
                expanded = isOpen ? nil : key
            }
        }
    }

    private func detail(_ word: Word) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider()
            label("Meaning", word.en)
            if !word.pre.isEmpty { label("Prefixes", word.pre.joined(separator: " · ")) }
            if !word.suf.isEmpty { label("Suffixes", word.suf.joined(separator: " · ")) }
            if !word.irab.isEmpty { label("I‘rāb", word.irab.joined(separator: " · ")) }
            if !word.sarf.isEmpty { label("Ṣarf", word.sarf.joined(separator: " · ")) }
            if !word.count.isEmpty { label("Features", word.count.joined(separator: " · ")) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func label(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .leading)
            Text(value)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
