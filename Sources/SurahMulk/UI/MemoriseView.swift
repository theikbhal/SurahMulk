import SwiftUI

struct MemoriseView: View {
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var progress: ProgressStore
    @State private var drill: Int? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                planHeader
                planList
            }
            .padding(28)
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .sheet(isPresented: Binding(
            get: { drill != nil },
            set: { if !$0 { drill = nil } }
        )) {
            if let ayahNumber = drill {
                DrillView(ayahNumber: ayahNumber)
                    .environmentObject(store)
                    .environmentObject(progress)
                    .frame(width: 760, height: 520)
            }
        }
    }

    private var planHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Memorise plan · one ayah a month")
                    .font(.title2.bold())
                Spacer()
                Text("\(progress.memorisedCount) / \(store.data.totalAyahs) memorised")
                    .font(.headline)
                    .foregroundStyle(.green)
            }

            ProgressView(value: Double(progress.memorisedCount), total: Double(store.data.totalAyahs))
                .tint(.green)

            Text("Each ayah is assigned to a month, starting with the month you began. Mark an ayah memorised and a revision plan of +7, +30 and +90 days is scheduled automatically.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private var planList: some View {
        VStack(spacing: 10) {
            ForEach(store.ayahs) { ayah in
                planRow(ayah)
            }
        }
    }

    private func planRow(_ ayah: Ayah) -> some View {
        let entry = progress.memoriseEntry(forAyah: ayah.n)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("\(ayah.n)")
                    .font(.callout.weight(.bold))
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(.green.opacity(0.85)))
                    .foregroundStyle(.white)

                Text(shorten(ayah.en))
                    .font(.callout)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(monthLabel(entry.assigned))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("", selection: statusBinding(for: ayah.n)) {
                    Text("Planned").tag("planned")
                    Text("Learning").tag("learning")
                    Text("Memorised").tag("memorised")
                }
                .labelsHidden()
                .frame(width: 210)

                Button("Drill") {
                    drill = ayah.n
                }
                .buttonStyle(.bordered)
            }

            if entry.status == "memorised" {
                let dates = progress.memoriseRevisionDays(ayah: ayah.n)
                HStack(spacing: 8) {
                    ForEach(Array(zip(progress.memoRevisionOffsets, dates)), id: \.0) { offset, day in
                        let done = entry.revisionsDone.contains(offset)
                        Button {
                            progress.toggleMemoriseRevision(ayah: ayah.n, offset: offset)
                        } label: {
                            Label("+\(offset)d · \(shortDate(day))", systemImage: done ? "checkmark.circle.fill" : "circle")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(done ? .green : .secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.2)))
    }

    private func statusBinding(for ayah: Int) -> Binding<String> {
        Binding(
            get: { progress.memoriseEntry(forAyah: ayah).status },
            set: { progress.setMemorise($0, ayah: ayah) }
        )
    }

    private func shorten(_ text: String) -> String {
        text.count > 90 ? String(text.prefix(90)) + "…" : text
    }

    private func monthLabel(_ day: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: ProgressStore.dayFormat.date(from: day) ?? Date())
    }

    private func shortDate(_ day: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: ProgressStore.dayFormat.date(from: day) ?? Date())
    }
}

/// Reveal-on-tap drill: hide the ayah, uncover words one at a time.
struct DrillView: View {
    let ayahNumber: Int
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var revealed = 0

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Drill · ayah \(ayahNumber)")
                    .font(.title3.bold())
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }

            if let ayah = store.ayah(ayahNumber) {
                Text(ayah.en)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                FlowLayout(spacing: 10) {
                    ForEach(Array(ayah.words.enumerated()), id: \.offset) { index, word in
                        Text(word.ar)
                            .font(.system(size: 30, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(index < revealed ? Color.green.opacity(0.15) : Color.secondary.opacity(0.25))
                            )
                            .onTapGesture {
                                if index >= revealed { revealed = index + 1 }
                            }
                    }
                }
                .environment(\.layoutDirection, .rightToLeft)

                Spacer()

                HStack {
                    Button("Reveal all") { revealed = ayah.words.count }
                    Button("Hide all") { revealed = 0 }
                    Spacer()
                    Button("Mark memorised") {
                        progress.setMemorise("memorised", ayah: ayahNumber)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding(24)
    }
}
